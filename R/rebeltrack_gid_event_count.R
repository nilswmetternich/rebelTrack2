#' Calculate Event Counts
#'
#' Calculate event counts grouped by \code{priogrid_gid} and \code{period} specified
#' when the \code{RebelTrackDataFrameGid} was created with \link{rebeltrack_dataframe_gid}.
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
#'                              period = "month",
#'                              balanced = TRUE)
#'
#' data <- rebeltrack_event_count_gid(data, event_count)
#' }
#' @include rebeltrack_measure_impl.R
#' @export
rebeltrack_event_count_gid <- function(x, var, fill = 0, lag = 0, weight = NULL) {
  .rebeltrack_measure_impl(
    x, group_col = "priogrid_gid",
    var = rlang::quo_name(rlang::enquo(var)), fill = fill, lag = lag, weight = weight,
    lag_engine = weighted_lag_gid, constructor = .rebeltrack_dataframe_gid,
    summarise = function(group) dplyr::summarize(group, .var = dplyr::n())
  )
}

