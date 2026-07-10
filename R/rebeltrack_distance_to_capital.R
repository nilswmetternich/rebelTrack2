#' Calculate Distance to Capital
#'
#' Calculate distance to capital of grouped by \code{actor} and \code{period}
#' specified when the \code{RebelTrackDataFrame} was created
#' with \link{rebeltrack_dataframe}.
#'
#' @param x A \code{RebelTrackDataFrame} object
#' @param var Name of the variable to create
#' @param fill Default value when no events are observed in the specified period.
#' @param lag An integer giving the number of positions to lead or lag by.
#' @param weight A weight matrix to apply.
#' @param func Name of function to apply (default = mean)
#' @param ... Additional arguments passed to \code{func}
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
#' data <- rebeltrack_distance_to_capital(data, capital_dist)
#' }
#' @include rebeltrack_measure_impl.R
#' @export
rebeltrack_distance_to_capital <- function(x, var, fill = NA, lag = 0,
                                           weight = NULL, func = mean, ...) {
  .rebeltrack_measure_impl(
    x, group_col = "actor",
    var = rlang::quo_name(rlang::enquo(var)), fill = fill, lag = lag, weight = weight,
    lag_engine = weighted_lag, constructor = .rebeltrack_dataframe,
    summarise = function(group) dplyr::summarize(
      group, .var = rebeltrack_summary_stats(capdist, func, na.rm = TRUE, ...))
  )
}

