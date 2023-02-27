#' Days Affected by Events
#'
#' Calculate the number of days affected by events grouped by \code{actor} and
#' \code{period} specified when the \code{RebelTrackDataFrame} was created with
#' \link{rebeltrack_dataframe}.
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
#' data <- rebeltrack_days_affected(data, days_affected)
#' }
#' @export
rebeltrack_days_affected <- function(x, var, fill = 0, lag = 0, weight = NULL) {
  group <- x@dataset@events %>%
    dplyr::group_by(actor, period_start)

  #Does this actually deal with the duration or not??
  #By summarising with only distinct date starts we do not quantify the duration of the conflict at all
  #this actually measures the number of distinct days on which conflicts started.
  #i.e starts on monday tuesday wednesday
  group_summary <- dplyr::summarize(group, .var = dplyr::n_distinct(date_start))

  data <- x %>%
    weighted_lag(rlang::quo_name(rlang::enquo(var)),
                 group,
                 group_summary,
                 fill,
                 lag,
                 weight)

  .rebeltrack_dataframe(dataset = x@dataset, data = data)
}

