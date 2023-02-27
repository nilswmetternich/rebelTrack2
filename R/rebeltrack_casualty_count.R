#' Calculate Casualties
#'
#' Calculate the number of casualties grouped by \code{actor} and \code{period}
#' specified when the \code{RebelTrackDataFrame} was created with
#' \link{rebeltrack_dataframe}.
#'
#' @param x A \code{RebelTrackDataFrame} object
#' @param side One of: {SIDE_A, SIDE_B} or {'A', 'B'} or {'a', 'b'} or {1, 2}
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
#' @export
rebeltrack_casualty_count <- function(x, side, var, fill = 0, lag = 0,
                                      weight = NULL) {
  group <- x@dataset@events %>%
    dplyr::mutate_(casualty_count = get_var_by_side("deaths_%s", side)) %>%
    dplyr::group_by(actor, period_start)

  group_summary <- dplyr::summarize(group, .var = sum(casualty_count))

  data <- x %>%
    weighted_lag(rlang::quo_name(rlang::enquo(var)),
                 group,
                 group_summary,
                 fill,
                 lag,
                 weight)

  .rebeltrack_dataframe(dataset = x@dataset, data = data)
}

