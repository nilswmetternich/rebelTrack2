#' Calculate Event Counts
#'
#' Calculate event counts grouped by \code{actor} and \code{period} specified
#' when the \code{RebelTrackDataFrame} was created with \link{rebeltrack_dataframe}.
#'
#' @param x A \code{RebelTrackDataFrame} object
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
#' data <- rebeltrack_dataframe(dataset,
#'                              side = SIDE_B,
#'                              period = "month",
#'                              balanced = TRUE)
#'
#' data <- rebeltrack_event_count(data, event_count)
#' }
#' @include rebeltrack_measure_impl.R
#' @export
rebeltrack_event_count <- function(x, var, fill = 0, lag = 0, weight = NULL) {
  .rebeltrack_measure_impl(
    x, group_col = "actor",
    var = rlang::quo_name(rlang::enquo(var)), fill = fill, lag = lag, weight = weight,
    lag_engine = weighted_lag, constructor = .rebeltrack_dataframe,
    summarise = function(group) dplyr::summarize(group, .var = dplyr::n())
  )
}

