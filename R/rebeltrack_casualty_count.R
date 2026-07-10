#' Calculate Casualties
#'
#' Calculate the number of casualties grouped by \code{actor} and \code{period}
#' specified when the \code{RebelTrackDataFrame} was created with
#' \link{rebeltrack_dataframe}.
#'
#' @param x A \code{RebelTrackDataFrame} object
#' @param side One of \code{SIDE_A}/\code{SIDE_B}, \code{"A"}/\code{"B"},
#'   \code{"a"}/\code{"b"}, or \code{1}/\code{2}
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
#' data <- rebeltrack_casualty_count(data, SIDE_A, casualty_count)
#' }
#' @include rebeltrack_measure_impl.R
#' @export
rebeltrack_casualty_count <- function(x, side, var, fill = 0, lag = 0,
                                      weight = NULL) {
  .rebeltrack_measure_impl(
    x, group_col = "actor",
    var = rlang::quo_name(rlang::enquo(var)), fill = fill, lag = lag, weight = weight,
    lag_engine = weighted_lag, constructor = .rebeltrack_dataframe,
    make_group = .simple_group(function(events) dplyr::mutate(
      events, casualty_count = .data[[get_var_by_side("deaths_%s", side)]])),
    summarise = function(group) dplyr::summarize(group, .var = sum(casualty_count))
  )
}

