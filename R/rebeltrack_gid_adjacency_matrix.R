#' return matrix coordinates for monotonic prigrid gid code
#' @param gid gid number of prio grid cell
#' @keywords internal
gid_to_coords <- function(gid){
  # returns coords from gid in gid format
  # x, y where south west is 1, 1
  # complicated by prio not following standard matrix notation
  gid <- gid - 1
  y <- gid %/% 720
  x <- gid %% 720
  x <- x + 1
  y <- y + 1
  return(c(x, y))
}


#' Return monotonic prio grid gid code for pair of matrix coordinates
#' @param coords - vector of matrix coordinates
#' @keywords internal
coords_to_gid <- function(coords){
  # takes coords and turns into gid
  return(coords[1] + (coords[2]-1)*720)
}

#' Enforces periodic boundary conditions from mapping a spherical earth onto a grid.
#' @param gid - vector of matrix coordinates
#' @keywords internal
enforce_periodic_boundaries <- function(gid){
  coords <- gid_to_coords(gid)
  coords <- periodic_boundary_conditions(coords)
  gid <- coords_to_gid(coords)
  return(gid)
}

#' Periodic boundary conditions from mapping a spherical earth onto a grid. takes
#' coordinates and returns a valid coordinate.
#' @param gid - vector of matrix coordinates
#' @keywords internal
periodic_boundary_conditions <- function(coords){
  # enforces periodic boundary conditions
  if (coords[1] > 720){
    coords[1] <- coords[1] - 720
  }
  if (coords[1] < 1){
    coords[1] <- coords[1] + 720
  }
  if (coords[2] > 360){
    coords[2] <- coords[2] - 360
  }
  if (coords[2] < 1){
    coords[2] <- coords[2] + 360
  }
  return(coords)
}

#' Finds neigbours in square grid surrounding prio grid cell.
#' Lagged square is of side length 2*order +1
#' Returns list of neighbouring grid cells.
#'
#' Note that the grid the lag is calculated for is NOT considered as part of this lag.
#' I.E there are NO SELF CONNECTIONS IN THE RESULTING ADJACENCY MATRIX
#' @param gid - prio grid cell to lag surrounding area
#' @param order - controls the degree to which the spatial lag extends. corresponds to the radius of the lag
#' @keywords internal
lag_neighbours <- function(gid, order){
  # function to find list of gids included in lag.
  # at current we remove all negative indices
  # THIS MEANS THAT OVERLAPS ARE NOT CONSIDERED BY DEFINITION i.e edge cases where adjaceny could be between 1 and 720
  # are not considered.

  d <- 2 * order + 1
  # First check if lag will overlap with border
  horizontal_bounds <- c(-order : order)
  vertical_bounds <- seq(-order * 720 , 720 * order, by = 720)
  # for increments of prio grid size.
  mesh = matlab::meshgrid(horizontal_bounds, vertical_bounds)
  ans <- c(gid + mesh$x + mesh$y)
  for (i in 1:length(ans)){
    ans[i] <- enforce_periodic_boundaries(ans[i])
    # enforces boundary conditions and corrects - makes periodic.
  }
  ans <- ans[ans != gid]
  return(list(ans))
}

#' @keywords internal
active_cells <- function(x){
  # fimds the number of grid cell that are currently active - so can use these for adjacency matrix
  group <- x@dataset@events %>%
    dplyr::group_by(period_start) # just find if there are events
  # TODO: we may need to add a mutate here
  group_summary <- dplyr::summarize(
    group, .var = dplyr::distinct(priogrid_gid)) # distinct values for a period

  .rebeltrack_dataframe_gid(dataset = x@dataset, data = data)

}

#' @keywords internal
lag_for_active <- function(x){
  # lags for active units in dataframe
  x <- active_cells(x) # finds active units.

}

.vectorized_lag_neighbours <- Vectorize(lag_neighbours)

#' Vectorizes lag_neighbours for use in mutate functions
#' @param gid - prio grid cell to lag surrounding area
#' @param order - controls the degree to which the spatial lag extends. corresponds to the radius of the lag
#' @keywords internal
vectorized_lag_neighbours <- function(gid, order){
  # must take direct reference to the column
  lag <- .vectorized_lag_neighbours(gid, order)
  # lag <- aperm(lag, c(2,1)) # re arrange the permutation
  return(lag)
}

#' Adds column of nearest neigbours as list to dataframe - this differs from R best practice
#' but is common as an adjacency list in network packages - this is the most efficient representation
#' considering the structure of the adjacency.
#' @param x rebeltrack_dataframe_gid
#' @param order order of the spatial lag to apply
#' @keywords internal
add_neighbour_column <- function(x, order = 1){
  x <- dplyr::mutate(x@data, vals = vectorized_lag_neighbours(priogrid_gid, order))
}

#' Summarises the starting period and produces list of all priogrid_gid with entry
#' in the dataset - note that this may produce a denser matrix when balacned = TRUE.
#' this is handled in weighted_lag_gid
#' @param x a RebelTrackDataFrameGid object
#' @keywords internal
summarise_active_grids <- function(x){
  out <- x %>% dplyr::group_by(period_start) %>% dplyr::summarize(active_grids = I(list(unique(priogrid_gid))))

}

#' adds active grids for given time period as new column
#' @keywords internal
total_active_grids <- function(x){
  out <- x %>% dplyr::group_by(period_start) %>% dplyr::mutate(active_grids = I(list(unique(priogrid_gid))))
}

#' @keywords internal
list_set_intersect <- function(x, y){
  x <- intersect(x, y)
}

vectorized_intersect <- Vectorize(list_set_intersect)

#' Finds active neighbours by finding intersect between active neighbours and
#' possible current neighbours.
#' @param x a RebelTrackDataFrameGid object
#' @keywords internal
active_neighbours <- function(x){
  active <- add_neighbour_column(x)
  active_grids <- summarise_active_grids(active)
  active<- merge(active, active_grids)
  active <- active %>% dplyr::mutate(grid_intersect = I(vectorized_intersect(active_grids, vals)))
  .rebeltrack_dataframe_gid(dataset = x@dataset, data = active)
}

#' @keywords internal
extract_summary <- function(x){
  # takes relevant dataframe with neighborus found and computes into a summary of information with date, gid and neighbours
  group <- x %>% dplyr::group_by(priogrid_gid, period_start) %>% dplyr::summarise(new_var = grid_intersect[1])#filter(dplyr::row_number()==1)
}

#' @keywords internal
unique_events <- function(x){
  # is dataframe of events - gives one event per gid month
  unique <- x %>% dplyr::group_by(priogrid_gid, period_start) %>%  dplyr::filter(dplyr::row_number() == 1)
}



#' @keywords internal
labelled_matrix <- function(dim = 3, gid_vec){
  mat <- matrix(0, dim, dim, dimnames = list(gid_vec, gid_vec)) # gid vec to refer to matrix
  return(mat)


}

#' @keywords internal
adj_list_to_mat <- function(gid, adj, mat){
  # for (i in adj) {
  #   mat[sprintf("%i", gid), sprintf("%i", i)] = 1 #over list of adjacent for each gid
  #   # going for column ordered.
  # }
  mat[cbind(sprintf("%i", gid), sprintf("%i", adj))] = 1
  return(mat)
}

#' @keywords internal
looped_adj_list_to_mat <- function(unique_gids, gid, adj){
  # unique gids should be all possible gids
  # loops over adj list as bodge
  mat <- labelled_matrix(length(unique_gids), unique_gids)
  # for (i in 1:length(gid)){
  #   mat <- adj_list_to_mat(gid[i], adj[i], mat) # over writes matrix
  # }
  # finding where numeric(0)s are in adj
  mask <- sapply(1:length(adj), function(x) (length(adj[[x]]) > 0))
  # now remove the numeric(0)s in adj
  # browser()
  gid <- gid[mask]
  adj <- adj[mask]
  # browser()

  gid <- sapply(gid, as.character)
  adj <- lapply(adj,as.character)
  # browser()
  joined <- lapply(1:length(gid), function(x) cbind(gid[x], adj[[x]]))
  # browser()
  joined <- Reduce(rbind, joined)

  # browser()
  mat[joined] = 1 # adj_list_to_mat replacement - do all in one loop
  # print(isSymmetric(mat)) # matrix is adjacency matrix so should be symmetric.
  return(mat)
}

#' @keywords internal
adj_wrapper <- function(x, unique_gids){
  mat <- looped_adj_list_to_mat(unique_gids, x$priogrid_gid, x$grid_intersect)
  return(slam::as.simple_triplet_matrix(mat))
}

#' Produces sparse adjacency matrix for priogrid gids
#'
#' Produces adjacency matrix for gid grouped objects. produces spatial lags based
#' on present and active objects. The provided dataframe should have been given additional
#' columns with active_neighbours
#' @param x A RebeltrackDataframeGid object
#' @return A slam package simple_sparse_array object of adjecency between active priogrids
#' @keywords internal
full_adj_matrix <- function(x){
 # naive iteration over grids. for loop is reasonably performant
  un <- unique(dplyr::arrange(x, priogrid_gid)$priogrid_gid)

  dim = length(un)

  start_date = unique(dplyr::arrange(x, period_start)$period_start)

  i = 1
  for (date in start_date){
    print(i)
    if (i == 1){
      mat <- adj_wrapper(x[x$period_start == date, ], un)
      # again this if statement is inneficient
    } else if (i == 2) {
      # to deal with adding new dimension

      mat_2 <- adj_wrapper(x[x$period_start == date, ], un)

      mat <- slam::abind_simple_sparse_array(mat, mat_2, MARGIN = -3L)

    } else{
      mat_2 <- adj_wrapper(x[x$period_start == date, ], un)

      mat <- slam::abind_simple_sparse_array(mat, mat_2, MARGIN = 3L)
    }

    i = i + 1
  }

  return(mat)
}
.vectorized_adj_list_to_mat <- Vectorize(adj_list_to_mat)

#' @keywords internal
vectorized_adj_list_to_mat <- function(gid, adj, mat){
  # trying to replicate pass by reference.
  return(.vectorized_adj_list_to_mat(gid, adj, mat))
}

#' Produces gid adjacency matrix
#'
#' @param x a RebelTrackDataFrameGid object
#' @return A slam package simple_sparse_array object of adjecency between active priogrids
#' @export
rebeltrack_adjacency_matrix_gid <- function(x){
  x <- active_neighbours(x)
  m <- full_adj_matrix(x@data)
  rm(x) # just to be explicit with gc (2gb in size)
  return(m)
}

#' #' @keywords internal
#' adj_matrix <- function(x){
#'   # function to define adjacency matrix for geographic
#'   # first we construct the empty matrix - can we do csr sparse?
#'   time_steps <- dplyr::n_distinct(x@dataset@events$period_start)
#'   n_grids <- dplyr::n_distinct(x@dataset@events$priogrid_gid)
#'   arr <- array(0, dim = c(n_grids, n_grids, time_steps)) # empty array of zeros.
#'   # we arrange the gids in ascending order
#'   # arrange by gids
#'   arranged <- dplyr::arrange(x@dataset@events, priogrid_gid)
#'   # unique gids
#'   gids <- unique(arranged) # arrange unique
#'   # summarise lists.
#'   # unique neighbours
#'   uniq <- unique_events(x@dataset@events)
#'
#'
#' }
