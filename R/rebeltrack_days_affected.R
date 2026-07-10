#' Days Affected by Events
#'
#' Calculate the number of distinct calendar days affected by ongoing
#' conflict (the union of every event's \code{date_start}-\code{date_end}
#' span, not double-counting overlapping events), grouped by \code{actor}
#' and \code{period} specified when the \code{RebelTrackDataFrame} was
#' created with \link{rebeltrack_dataframe}.
#'
#' (Previously this counted only the number of distinct days on which
#' events *started*, ignoring how long each event actually lasted - fixed
#' 2026-07-10, see dev-notes/STEP2_NOTES.md. This does not clip event spans to
#' period boundaries; see \code{rebeltrack_count_days_affected()}.)
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
#' @include rebeltrack_measure_impl.R
#' @export
rebeltrack_days_affected <- function(x, var, fill = 0, lag = 0, weight = NULL) {
  .rebeltrack_measure_impl(
    x, group_col = "actor",
    var = rlang::quo_name(rlang::enquo(var)), fill = fill, lag = lag, weight = weight,
    lag_engine = weighted_lag, constructor = .rebeltrack_dataframe,
    summarise = function(group) dplyr::summarize(
      group, .var = rebeltrack_count_days_affected(date_start, date_end))
  )
}

