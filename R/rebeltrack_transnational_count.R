#' Transnational Count
#'
#' Calculate the number of countries where the \code{actor} is active in the
#' given \code{period}
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
#' data <- rebeltrack_transnational_count(data, transnational_ratio)
#' }
#' @include rebeltrack_measure_impl.R
#' @export
rebeltrack_transnational_count <- function(x, var, fill = 0, lag = 0,
                                           weight = NULL) {
  .rebeltrack_measure_impl(
    x, group_col = "actor",
    var = rlang::quo_name(rlang::enquo(var)), fill = fill, lag = lag, weight = weight,
    lag_engine = weighted_lag, constructor = .rebeltrack_dataframe,
    summarise = function(group) dplyr::summarize(group, .var = dplyr::n_distinct(country_id))
  )
}

