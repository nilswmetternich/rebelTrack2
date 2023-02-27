#' Removes temporary columns added to calculate adjacency matrix.
#'
#' @param x A \code{RebelTrackDataFrameGid} object
#' @examples
#' library(rebeltrack)
#'
#' \dontrun{
#' dataset <- rebeltrack_load_dataset(type = UCDP_STATE_BASED)
#'
#' data <- rebeltrack_dataframe_gid(dataset,
#'                              period = "month",
#'                              balanced = TRUE)
#'
#' data <- rebeltrack_clean_up_gid(data)
#' }
#' @export
rebeltrack_clean_up_gid <- function(x){
  # drops columns used for spatial lagging to clean up before use.
  data <- subset(x@data, select = -c(vals,active_grids, grid_intersect))
  .rebeltrack_dataframe_gid(dataset = x@dataset, data = data)
}
