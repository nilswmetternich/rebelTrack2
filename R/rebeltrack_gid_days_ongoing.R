#' Days Ongoing within Period
#'
#' Calculate the number of distinct calendar days, within each \code{period}
#' itself, affected by ongoing conflict - like \link{rebeltrack_days_affected_gid},
#' but each event's \code{date_start}-\code{date_end} span is clipped to the
#' boundaries of the period specified when the \code{RebelTrackDataFrameGid}
#' was created with \link{rebeltrack_dataframe_gid}, rather than counting
#' every day the event covers regardless of which period it falls in.
#'
#' Use this when you want "how many days of this period saw ongoing
#' conflict" (values are bounded by the period's own length). Use
#' \link{rebeltrack_days_affected_gid} when you want the full duration of
#' every event regardless of period boundaries (values can exceed the
#' period's length for a long-running event).
#'
#' @param x A \code{RebelTrackDataFrameGid} object
#' @param var Name of the variable to create
#' @param fill Default value when no events are observed in the specified period.
#' @param lag An integer giving the number of positions to lead or lag by.
#' @param weight A weight matrix to apply. Must be a gid weight matrix to maintain dimensionality
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
#' data <- rebeltrack_days_ongoing_gid(data, days_ongoing)
#' }
#' @include rebeltrack_measure_impl.R
#' @export
rebeltrack_days_ongoing_gid <- function(x, var, fill = 0, lag = 0, weight = NULL) {
  period_lookup <- as.data.frame(x) %>%
    dplyr::distinct(period_start, period_end)

  .rebeltrack_measure_impl(
    x, group_col = "priogrid_gid",
    var = rlang::quo_name(rlang::enquo(var)), fill = fill, lag = lag, weight = weight,
    lag_engine = weighted_lag_gid, constructor = .rebeltrack_dataframe_gid,
    make_group = function(events, group_col) {
      events %>%
        dplyr::left_join(period_lookup, by = "period_start") %>%
        dplyr::group_by(dplyr::across(dplyr::all_of(c(group_col, "period_start"))))
    },
    summarise = function(group) dplyr::summarize(
      group, .var = rebeltrack_count_days_ongoing_in_period(
        date_start, date_end, period_start, period_end))
  )
}
