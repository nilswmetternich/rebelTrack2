#' Actors Present per Priogrid_gid
#'
#' Calculate the number of actors active in each \code{priogrid} and
#' \code{period} specified when the \code{RebelTrackDataFrameGid} was created with
#' \link{rebeltrack_dataframe_gid}. Equivalent of rebeltrack_grids_affected
#'
#' @param x A \code{RebelTrackDataFrameGid} object
#' @param var Name of the variable to create
#' @param fill Default value when no events are observed in the specified period.
#' @param lag An integer giving the number of positions to lead or lag by.
#' @param weight A weight matrix to apply.
#' @examples
#' library(rebeltrack)
#'
#' \dontrun{
#' dataset <- rebeltrack_load_dataset(type = UCDP_STATE_BASED)
#'
#' data <- rebeltrack_dataframe_gid(dataset,
#'                              side = SIDE_B,
#'                              period = "month",
#'                              balanced = TRUE)
#'
#' data <- rebeltrack_gid_actors_present(data, actors_present)
#' }
#' @export
rebeltrack_actors_present_gid <- function(x, var, fill = 0, lag = 0, weight = NULL) {
  group <- x@dataset@events %>%
    dplyr::group_by(priogrid_gid, period_start)

  group_summary <- dplyr::summarize(
    group, .var = dplyr::n_distinct(side_a) + dplyr::n_distinct(side_b))

  data <- x %>%
    weighted_lag_gid(rlang::quo_name(rlang::enquo(var)),
                 group,
                 group_summary,
                 fill,
                 lag,
                 weight)

  .rebeltrack_dataframe_gid(dataset = x@dataset, data = data)
}
