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
#' @export
rebeltrack_transnational_count <- function(x, var, fill = 0, lag = 0,
                                           weight = NULL) {
  group <- x@dataset@events %>%
    dplyr::group_by(actor, period_start)

  group_summary <- dplyr::summarize(group, .var = dplyr::n_distinct(country_id))

  data <- x %>%
    weighted_lag(rlang::quo_name(rlang::enquo(var)),
                 group,
                 group_summary,
                 fill,
                 lag,
                 weight)

  .rebeltrack_dataframe(dataset = x@dataset, data = data)
}

