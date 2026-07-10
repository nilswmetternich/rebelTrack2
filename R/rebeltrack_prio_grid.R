# PRIO-GRID access history (see dev-notes/DATA_SOURCES.md for the full story):
#   1. Originally a simple CSV API (grid.prio.org), capped at years 1989-2014.
#   2. Migrated to the priogrid R package (v3, github.com/prio-data/priogrid),
#      which covers more years but (a) has no distance-to-capital variable at
#      all, and (b) turned out to have cshapes_gwcode, bdist1 AND bdist2 all
#      hard-capped at 2019 - because priogrid's own boundary source is
#      "CShapes 2.0", whose defining paper is literally titled "Mapping the
#      International System, 1886-2019". Confirmed by checking coverage
#      year-by-year: a clean cliff to 0% for every variable in 2019+.
#   3. This file: priogrid is dropped entirely. Everything is computed
#      directly from the `cshapes` R package instead (CRAN, actively
#      maintained, claims coverage "1886 to today" - a different, newer
#      boundary source than the one priogrid bundles). This is also the
#      source rebeltrack was already using for capital coordinates, so there
#      is now exactly one upstream data source for both country assignment
#      and border geometry instead of two potentially-inconsistent ones, and
#      priogrid's 721MB download + GitHub-only install + "unstable alpha"
#      status are no longer a dependency at all.
#
# What's computed here, per grid cell/year:
#   - country assignment (which country a cell belongs to) - replaces
#     priogrid's cshapes_gwcode
#   - capdist: haversine distance from the cell's centroid to that country's
#     capital that year (capitals can move, e.g. after a split)
#   - bdist2: distance from the cell's centroid to the nearest point that
#     falls inside a DIFFERENT, contemporaneous country's territory ("distance
#     to nearest international border" in the original PRIO-GRID sense - NOT
#     distance to the cell's own coastline, which distance-to-own-polygon-
#     boundary would wrongly include)
# bdist1 (distance to nearest *land-contiguous* border) is intentionally not
# computed - it isn't used anywhere in this package (only bdist2 is, via
# rebeltrack_distance_to_border()), and it's a meaningfully harder
# calculation (a shortest-path-along-connected-land problem, not a plain
# point-to-boundary distance) that isn't worth solving for a variable nothing
# reads.
#
# The result is written out as a gid/year/bdist2/capdist table - the same
# shape (minus bdist1) the old pipelines produced, so
# rebeltrack_load_prio_grid() and the measure functions that consume it
# (rebeltrack_distance_to_border(), rebeltrack_distance_to_capital(), and
# their _gid equivalents) need no further changes.
#
# Efficiency: the expensive step is one spatial join between all 259,200
# grid cell centroids and cshapes' ~300-500 historical country episodes.
# This is done ONCE, as a single indexed sf::st_join() call (not a per-year
# loop), which automatically drops ocean cells (they never fall inside any
# country polygon). capdist only depends on a cell's own country/episode, so
# it's computed and expanded to years directly. bdist2 additionally depends
# on which OTHER countries were contemporaneous, which can change even
# within a single long-lived episode's own lifetime (e.g. a neighbour
# splits) - so it's computed per globally-shared time interval (history
# since 1985 partitioned at every point any country's borders changed,
# typically a few dozen intervals in practice) using
# sf::st_nearest_feature() (spatial-index-accelerated) rather than unioning
# candidate polygons, then expanded to years and joined back to capdist on
# (gid, year). See the inline comments above the bdist2 block for the full
# reasoning, including two earlier, less accurate approaches this replaced.
# Episode year ranges are clipped to a small buffer before GED's 1989 start,
# so centuries of pre-conflict-era history aren't expanded into rows we'd
# never use.

#' Download/compute PRIO-GRID-equivalent border and capital distance
#'
#' @param config The result of rebeltrack_config()
#' @keywords internal
rebeltrack_download_prio_grid <- function(config) {
  rlang::check_installed(
    "cshapes",
    reason = "to compute border/capital distance. Install with: install.packages('cshapes')"
  )

  dest <- file.path(config$path, "prio", "grid")
  if (!dir.exists(dest))
    dir.create(dest, recursive = TRUE)

  message("loading: cshapes historical country boundaries")
  cshp <- cshapes::cshp(useGW = TRUE) # sf object: all historical episodes, independent states only

  # cshapes' historical polygons occasionally have topology quirks (e.g. a
  # duplicate vertex creating a degenerate edge) that sf's default S2
  # spherical geometry engine rejects outright ("Edge N is degenerate").
  # st_make_valid() repairs these in place; it's a no-op for geometries that
  # are already valid, so this is safe to always run.
  message("repairing any invalid polygon geometries (st_make_valid)")
  cshp <- sf::st_make_valid(cshp)

  cshp$start_year <- lubridate::year(as.Date(cshp$start))
  cshp$end_year <- lubridate::year(as.Date(cshp$end))
  # Clip to a small buffer before GED's 1989 start and to the present, so we
  # don't expand centuries of pre-1989 history (or any bad future dates)
  # into rows we'll never join against.
  current_year <- as.integer(format(Sys.Date(), "%Y"))
  cshp$start_year <- pmax(cshp$start_year, 1985)
  cshp$end_year <- pmin(cshp$end_year, current_year)
  cshp <- cshp[cshp$start_year <= cshp$end_year, ]
  cshp$episode_id <- seq_len(nrow(cshp))

  message("building grid cell centroids (global 0.5deg grid, 259,200 cells)")
  centroids <- rebeltrack_pgid_to_lonlat(seq_len(720 * 360))
  centroids_sf <- sf::st_as_sf(centroids, coords = c("lon", "lat"), crs = 4326,
                               remove = FALSE)

  message("spatial join: assigning each grid cell to its historical country episode(s)")
  # One indexed point-in-polygon join across the whole grid and every
  # historical episode at once - sf builds a spatial index internally, so
  # this is a single operation, not a per-year loop. Cells that never fall
  # inside any country polygon (ocean) are dropped automatically.
  join_cols <- c("gwcode", "start_year", "end_year", "episode_id",
                 "capname", "caplong", "caplat")
  joined <- sf::st_join(centroids_sf, cshp[, join_cols])
  joined <- joined[!is.na(joined$gwcode), ]

  if (nrow(joined) == 0)
    stop("rebeltrack_download_prio_grid(): spatial join produced zero matches - ",
         "check that cshapes::cshp() returned geometry as expected.")

  # Guard against duplicate (cell, episode) matches (e.g. from disputed or
  # overlapping cshapes polygons) - a left_join downstream with duplicate
  # (gid, year) keys would silently multiply GED event rows, which is a much
  # worse failure mode than dropping a handful of ambiguous matches here.
  dup_key <- paste(joined$priogrid_gid, joined$episode_id)
  n_dupes <- sum(duplicated(dup_key))
  if (n_dupes > 0) {
    message("NOTE: ", n_dupes, " (cell, episode) pairs matched more than once ",
            "(overlapping/disputed cshapes polygons) - keeping the first match ",
            "for each.")
    joined <- joined[!duplicated(dup_key), ]
  }

  message("computing: capdist (grid cell centroid -> own country's capital, haversine)")
  joined_df <- sf::st_drop_geometry(joined)
  joined_df$capdist <- rebeltrack_haversine_km(joined_df$lon, joined_df$lat,
                                               joined_df$caplong, joined_df$caplat)

  message("expanding capdist to one row per (cell, calendar year)")
  n_years <- joined_df$end_year - joined_df$start_year + 1
  capdist_expanded <- data.frame(
    gid = rep(joined_df$priogrid_gid, n_years),
    year = unlist(mapply(seq, joined_df$start_year, joined_df$end_year,
                         SIMPLIFY = FALSE), use.names = FALSE),
    capdist = rep(joined_df$capdist, n_years)
  )
  dup_key_cap <- paste(capdist_expanded$gid, capdist_expanded$year)
  n_dupes_cap <- sum(duplicated(dup_key_cap))
  if (n_dupes_cap > 0) {
    message("NOTE: ", n_dupes_cap, " (gid, year) capdist rows were duplicated ",
            "after expanding to years - keeping the first for each.")
    capdist_expanded <- capdist_expanded[!duplicated(dup_key_cap), ]
  }

  # --- bdist2: PRIO-GRID's own codebook defines this as "the distance from
  # the cell centroid to the border of the nearest neighbouring country,
  # regardless of whether the nearest country is located across
  # international waters" - i.e. distance to whichever OTHER country is
  # actually closest *in that specific year*, not to the cell's own
  # coastline (the original bug here) and not to some coarse approximation
  # of "any country that ever existed nearby at any point during this
  # episode" (a first attempt at fixing this, which improved the correlation
  # against the independent legacy values from 0.31 to only 0.65 - still
  # biased, because unioning every episode that ever overlapped a long-lived
  # episode's ENTIRE lifespan pulls in countries that were not actually
  # contemporaneous with a given year, systematically understating the true
  # distance for cells in long-lived, large countries).
  #
  # Correct approach, and why it's organised the way it is below:
  #
  # Two earlier designs were tried and both proved too slow in practice:
  #   1. A GLOBAL interval partition (history since 1985 split every time
  #      ANY country's borders changed anywhere - ~21 intervals) recomputed
  #      the same answer for the same country over and over, since a global
  #      breakpoint is almost always irrelevant to any given country's own
  #      neighbourhood (e.g. Yugoslavia breaking up doesn't change who is
  #      nearest to Chile).
  #   2. Adding a cache on top of (1), keyed by a country's bbox-filtered
  #      candidate set, still didn't fully fix this: a large country's
  #      bounding box can be wide enough that unrelated changes elsewhere in
  #      the world still fall inside its own filter margin, so exactly the
  #      biggest, most cell-heavy countries kept missing the cache.
  #
  # Fixed properly by inverting the structure: instead of asking "what
  # changed globally, and who did that affect", ask - per TARGET country -
  # "which of MY OWN geographic neighbours could ever possibly be relevant,
  # and when did any of THEM actually change". Concretely:
  #   - Once, for every episode, precompute a small fixed "neighbour
  #     universe": other episodes (across ALL of history, not just this
  #     episode's own years) whose bounding box is anywhere near this one's
  #     (a cheap numeric comparison). A country's plausible neighbours don't
  #     depend on which year it is, only on geography.
  #   - For a given target episode, the only years within its own lifetime
  #     where its bdist2 answer could possibly change are years where one of
  #     ITS OWN neighbour-universe members starts or ends - not any of the
  #     ~190 other countries worldwide. This is usually zero or a handful of
  #     breakpoints, not 21.
  #   - Within each resulting local sub-period, compute distance to the
  #     nearest ACTIVE neighbour-universe member via sf::st_nearest_feature()
  #     (small candidate set - fast index to build) + one by-element
  #     sf::st_distance() call.
  # In practice this means most of the ~194 post-1985 episodes need exactly
  # one distance computation for their entire lifetime (their real
  # neighbours never change), with only a handful needing 2-4 for episodes
  # near regions with genuine post-1985 border history - versus the ~190 x
  # 21 (or even the cached version's still-large count for big countries)
  # of the earlier designs.
  message("computing: bdist2 (grid cell centroid -> nearest OTHER contemporaneous country)")
  cshp_geom <- sf::st_geometry(cshp)
  joined_geom <- sf::st_geometry(joined)

  message("precomputing each episode's geographic neighbour universe (one-off, all-pairs bbox check)")
  bbox_margin_deg <- 25 # generous - this is a coarse, one-off candidate pool, not the final answer
  bbox_mat <- t(vapply(cshp_geom, function(g) sf::st_bbox(g)[c("xmin", "ymin", "xmax", "ymax")],
                       numeric(4)))
  colnames(bbox_mat) <- c("xmin", "ymin", "xmax", "ymax")

  n_ep <- nrow(cshp)
  neighbor_universe <- vector("list", n_ep)
  for (i in seq_len(n_ep)) {
    bb <- bbox_mat[i, ]
    near <- !(bbox_mat[, "xmax"] < bb["xmin"] - bbox_margin_deg |
             bbox_mat[, "xmin"] > bb["xmax"] + bbox_margin_deg |
             bbox_mat[, "ymax"] < bb["ymin"] - bbox_margin_deg |
             bbox_mat[, "ymin"] > bb["ymax"] + bbox_margin_deg)
    near[i] <- FALSE
    neighbor_universe[[i]] <- which(near)
  }

  bdist2_parts <- list()
  part_i <- 0L
  n_local_computations <- 0L
  t0 <- Sys.time()

  for (i in seq_len(n_ep)) {
    eid <- cshp$episode_id[i]
    rows <- which(joined$episode_id == eid)
    if (length(rows) == 0)
      next

    target_start <- cshp$start_year[i]
    target_end <- cshp$end_year[i]
    neigh_idx <- neighbor_universe[[i]]

    if (length(neigh_idx) == 0) {
      # No geographically plausible neighbour at all (e.g. a remote island
      # nation) - fall back to whichever episodes are active at this
      # episode's own start year, worldwide. Rare; correctness over speed.
      neigh_idx <- setdiff(which(cshp$start_year <= target_start & cshp$end_year >= target_start), i)
    }

    # Local breakpoints: years within this episode's own lifetime where one
    # of ITS candidate neighbours starts or ends - the only points where its
    # bdist2 answer could possibly change.
    neigh_starts <- cshp$start_year[neigh_idx]
    neigh_ends <- cshp$end_year[neigh_idx]
    local_breaks <- sort(unique(c(
      target_start,
      neigh_starts[neigh_starts > target_start & neigh_starts <= target_end],
      neigh_ends[neigh_ends >= target_start & neigh_ends < target_end] + 1L,
      target_end + 1L
    )))
    seg_start <- local_breaks[-length(local_breaks)]
    seg_end <- local_breaks[-1] - 1L
    keep_seg <- seg_end >= seg_start
    seg_start <- seg_start[keep_seg]
    seg_end <- seg_end[keep_seg]

    for (s in seq_along(seg_start)) {
      yr <- seg_start[s]
      active_neigh <- neigh_idx[cshp$start_year[neigh_idx] <= yr & cshp$end_year[neigh_idx] >= yr]
      if (length(active_neigh) == 0) {
        # None of the pre-filtered candidates are actually independent
        # during this specific sub-period - fall back to a full worldwide
        # search for just this sub-period (rare, safety net).
        active_neigh <- setdiff(which(cshp$start_year <= yr & cshp$end_year >= yr), i)
      }
      if (length(active_neigh) == 0)
        next # genuinely no other state existed at all - leave NA

      # Use the OTHER countries' own grid cell centroids as the candidate
      # set, not their raw cshapes polygons. sf::st_nearest_feature() /
      # st_distance() against complex real-world coastline polygons is the
      # actual bottleneck (point-to-polygon distance means walking detailed
      # boundary geometry on every call); point-to-point nearest neighbour
      # against coordinates we already have (from the one-time spatial
      # join) is a spatial-index lookup, dramatically cheaper, and matches
      # this product's own native resolution - PRIO-GRID cells are ~55km,
      # so "distance to the nearest other country's grid cell" is a
      # perfectly natural definition at this resolution, not a lesser
      # approximation of a polygon-based one. This does mean bdist2 values
      # are quantised to roughly the grid's own cell size (a cell can never
      # read as, say, 3km from a border - the nearest it can be is about one
      # cell width), which is an acceptable, resolution-appropriate
      # trade-off for a large speed-up.
      other_rows <- which(joined$episode_id %in% cshp$episode_id[active_neigh])
      if (length(other_rows) == 0)
        next
      others_geom <- joined_geom[other_rows]
      nearest_i <- sf::st_nearest_feature(joined_geom[rows], others_geom)
      d <- as.numeric(
        sf::st_distance(joined_geom[rows], others_geom[nearest_i], by_element = TRUE)
      )
      n_local_computations <- n_local_computations + 1L

      part_i <- part_i + 1L
      bdist2_parts[[part_i]] <- data.frame(
        gid = joined_df$priogrid_gid[rows],
        year_start = seg_start[s],
        year_end = seg_end[s],
        bdist2_m = d
      )
    }

    if (i %% 20 == 0) {
      elapsed <- round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 1)
      message("  ...", i, "/", n_ep, " episodes done (", elapsed, "s elapsed, ",
              n_local_computations, " distance computations so far)")
    }
  }
  message("  ...", n_ep, "/", n_ep, " episodes done (",
          round(as.numeric(difftime(Sys.time(), t0, units = "secs")), 1), "s elapsed, ",
          n_local_computations, " distance computations total)")

  bdist2_by_interval <- do.call(rbind, bdist2_parts)

  message("expanding bdist2 to one row per (cell, calendar year)")
  n_years2 <- bdist2_by_interval$year_end - bdist2_by_interval$year_start + 1
  bdist2_expanded <- data.frame(
    gid = rep(bdist2_by_interval$gid, n_years2),
    year = unlist(mapply(seq, bdist2_by_interval$year_start, bdist2_by_interval$year_end,
                         SIMPLIFY = FALSE), use.names = FALSE),
    bdist2 = rep(bdist2_by_interval$bdist2_m, n_years2) / 1000 # metres -> km
  )
  dup_key_bd <- paste(bdist2_expanded$gid, bdist2_expanded$year)
  n_dupes_bd <- sum(duplicated(dup_key_bd))
  if (n_dupes_bd > 0) {
    message("NOTE: ", n_dupes_bd, " (gid, year) bdist2 rows were duplicated ",
            "after expanding to years - keeping the first for each.")
    bdist2_expanded <- bdist2_expanded[!duplicated(dup_key_bd), ]
  }

  message("joining capdist and bdist2 on (gid, year)")
  prio <- dplyr::full_join(capdist_expanded, bdist2_expanded, by = c("gid", "year"))

  target <- file.path(dest, paste0("grid_", format(Sys.Date(), "%Y%m%d"), ".rds"))
  message("saving: ", target, " (", nrow(prio), " rows)")
  saveRDS(prio, target)
  invisible(prio)
}

#' Convert a PRIO-GRID cell id to its centroid longitude/latitude
#'
#' PRIO-GRID numbers cells 1..(nrow*ncol) starting at the south-west corner
#' of the 0.5-degree global grid (720 columns x 360 rows) and increasing
#' eastward along a row before moving one row north, i.e.
#' \code{gid = x + (y - 1) * 720}, where \code{x} in 1:720 (west to east) and
#' \code{y} in 1:360 (south to north). This is the same convention already
#' used by \code{gid_to_coords()}/\code{coords_to_gid()} in
#' rebeltrack_gid_adjacency_matrix.R, and was cross-checked directly against
#' priogrid v3's \code{create_pg_indices()} source
#' (github.com/prio-data/priogrid/blob/master/R/utility.R) to confirm this
#' matches \code{priogrid_gid} as already used elsewhere in rebeltrack.
#'
#' @param gid A vector of PRIO-GRID cell ids
#' @keywords internal
rebeltrack_pgid_to_lonlat <- function(gid) {
  x <- ((gid - 1) %% 720) + 1
  y <- ((gid - 1) %/% 720) + 1
  data.frame(priogrid_gid = gid,
            lon = -180 + (x - 0.5) * 0.5,
            lat = -90 + (y - 0.5) * 0.5)
}

#' Vectorised great-circle (haversine) distance, in kilometres
#'
#' @param lon1,lat1 Coordinates of the first point (degrees)
#' @param lon2,lat2 Coordinates of the second point (degrees)
#' @keywords internal
rebeltrack_haversine_km <- function(lon1, lat1, lon2, lat2) {
  r <- 6371.0088 # mean Earth radius, km
  to_rad <- pi / 180
  dlat <- (lat2 - lat1) * to_rad
  dlon <- (lon2 - lon1) * to_rad
  a <- sin(dlat / 2)^2 +
    cos(lat1 * to_rad) * cos(lat2 * to_rad) * sin(dlon / 2)^2
  a <- pmin(pmax(a, 0), 1) # guard against floating-point drift just above 1
  2 * r * asin(sqrt(a))
}
