# Vectorized rewrite of rebeltrack_adjacency_matrix_gid(), replacing the
# original loop/list-column-based implementation. See dev-notes/STEP2_NOTES.md
# for the full writeup, including the equivalence check against the
# original that this replaced (dim, dimnames, and all 1064 nonzero entries
# matched exactly on a real 3-month sample; ~28x faster on that same
# sample, with the gap expected to grow on larger datasets since the old
# version allocated a dense gid x gid zero matrix per period).
#
# The rewrite exploits PRIO-GRID's row-major gid numbering (sequential from
# 1 at the south-west corner, west to east, wrapping to the next row after
# 720 cells) to replace three things that were each a per-row/per-cell R
# loop in the original:
#   1. Coordinate round-trip + branch-based boundary wrapping (previously
#      gid_to_coords()/coords_to_gid()/periodic_boundary_conditions()/
#      enforce_periodic_boundaries()/lag_neighbours(), plus a
#      matlab::meshgrid() dependency) -> pure vectorized modular
#      arithmetic in .gid_neighbor_edges(), computing every row's
#      neighbours in one shot instead of looping per candidate cell.
#   2. Per-row list-column set intersection (previously
#      add_neighbour_column()/summarise_active_grids()/a Vectorize()-based
#      vectorized_intersect()) -> a semi_join() of the long-format edge
#      list against the (gid, period_start) pairs actually present in the
#      data - the same "is this neighbour active in this period" test,
#      expressed as a join instead of a per-row set operation.
#   3. Dense per-period matrix allocation + character-string matrix
#      indexing (previously labelled_matrix()/adj_list_to_mat()/
#      looped_adj_list_to_mat(), stacked one period at a time via
#      slam::abind_simple_sparse_array() with awkward i==1/i==2/else
#      special-casing) -> integer row/col/period indices via match(), fed
#      directly into one slam::simple_sparse_array() call covering every
#      period at once.
#
# Also dropped in this rewrite: active_cells()/lag_for_active() (dead code
# - referenced an undefined `data` variable, unreachable from the exported
# function, never exercised by any test), a leftover `print(i)` debug
# statement, commented-out `browser()` calls and an old commented-out
# for-loop implementation, and the `matlab` dependency (its only use was
# meshgrid(), no longer needed).

#' Build a table of relative neighbor offsets for a square lag of the given
#' order, excluding the origin (no self-loops).
#'
#' @param order Radius of the square neighborhood (order = 1 is the 8
#'   surrounding cells, matching the fixed default the original spatial lag
#'   used).
#' @keywords internal
.neighbor_offsets <- function(order = 1L) {
  offsets <- expand.grid(dx = -order:order, dy = -order:order)
  offsets[!(offsets$dx == 0 & offsets$dy == 0), , drop = FALSE]
}

#' Vectorized computation of spatial neighbor gids.
#'
#' Exploits PRIO-GRID's row-major gid numbering - sequential from 1 at the
#' south-west corner, increasing west to east, wrapping to the next row up
#' after \code{n_cols} cells - to compute wrapped neighbor gids with plain
#' modular arithmetic instead of a per-cell coordinate round-trip inside an
#' R-level loop. \code{x \%\% n} already does the "add or subtract one grid
#' width/height" wraparound a branch-based approach would do by hand, and
#' generalizes correctly to any order.
#'
#' @param gids Vector of source priogrid_gid values (one row of output per
#'   gid per offset, i.e. \code{length(gids) * n_offsets} rows total).
#' @param order Radius of the square neighborhood.
#' @param n_cols Grid width (720 for standard 0.5-degree PRIO-GRID).
#' @param n_rows Grid height (360 for standard 0.5-degree PRIO-GRID).
#' @return A data frame with columns \code{priogrid_gid} (source, repeated)
#'   and \code{neighbor_gid}.
#' @keywords internal
.gid_neighbor_edges <- function(gids, order = 1L, n_cols = 720L, n_rows = 360L) {
  offsets <- .neighbor_offsets(order)
  n_off <- nrow(offsets)

  x <- ((gids - 1L) %% n_cols) + 1L
  y <- ((gids - 1L) %/% n_cols) + 1L

  gid_rep <- rep(gids, each = n_off)
  x_rep <- rep(x, each = n_off)
  y_rep <- rep(y, each = n_off)
  dx <- rep(offsets$dx, times = length(gids))
  dy <- rep(offsets$dy, times = length(gids))

  new_x <- ((x_rep + dx - 1L) %% n_cols) + 1L
  new_y <- ((y_rep + dy - 1L) %% n_rows) + 1L

  data.frame(
    priogrid_gid = gid_rep,
    neighbor_gid = new_x + (new_y - 1L) * n_cols
  )
}

#' Produces gid adjacency matrix
#'
#' Produces adjacency matrix for gid grouped objects: for every (gid,
#' period) row in \code{x@data}, which of its spatial neighbors are
#' themselves present in \code{x@data} for that same period. Produces
#' spatial lags based on present and active objects.
#'
#' @param x a RebelTrackDataFrameGid object
#' @param order Radius of the square spatial lag (order = 1 is the 8
#'   surrounding cells)
#' @return A slam package simple_sparse_array object of adjecency between
#'   active priogrids
#' @include rebeltrack_gid_dataframe.R
#' @export
rebeltrack_adjacency_matrix_gid <- function(x, order = 1L) {
  data <- x@data
  n_cols <- 720L
  n_rows <- 360L

  un <- sort(unique(data$priogrid_gid))
  periods <- sort(unique(data$period_start))
  n_gid <- length(un)
  n_period <- length(periods)
  gid_index <- stats::setNames(seq_along(un), as.character(un))

  edges <- .gid_neighbor_edges(data$priogrid_gid, order = order,
                               n_cols = n_cols, n_rows = n_rows)
  edges$period_start <- rep(data$period_start, each = nrow(edges) / nrow(data))

  # A neighbor only counts if it's actually present in x@data for that same
  # period - the source row always exists by construction (we're iterating
  # over x@data's own rows), so only the neighbor side needs filtering.
  active_presence <- dplyr::distinct(data, priogrid_gid, period_start)
  edges <- edges %>%
    dplyr::semi_join(active_presence,
                     by = c("neighbor_gid" = "priogrid_gid",
                            "period_start" = "period_start")) %>%
    dplyr::distinct()

  row_idx <- gid_index[as.character(edges$priogrid_gid)]
  col_idx <- gid_index[as.character(edges$neighbor_gid)]
  period_idx <- match(edges$period_start, periods)

  slam::simple_sparse_array(
    i = cbind(row_idx, col_idx, period_idx),
    v = rep(1, length(row_idx)),
    dim = c(n_gid, n_gid, n_period),
    dimnames = list(as.character(un), as.character(un), NULL)
  )
}
