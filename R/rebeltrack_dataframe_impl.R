# Shared engine behind rebeltrack_dataframe() and rebeltrack_dataframe_gid() -
# the panel constructors, not the measures added on top of them (those share
# .rebeltrack_measure_impl() in rebeltrack_measure_impl.R instead). Before
# this file, the two had near-identical bodies differing only in the
# grouping column ("actor" vs "priogrid_gid") and which S4 class/constructor
# wraps the result. Purely an internal refactor - rebeltrack_dataframe() and
# rebeltrack_dataframe_gid() keep their exact existing signatures and
# behaviour. See dev-notes/STEP2_NOTES.md.

#' Shared implementation for the actor/gid panel constructors
#'
#' @param dataset A RebelTrackDataSet object
#' @param side One of \code{SIDE_A}/\code{SIDE_B}, \code{"A"}/\code{"B"},
#'   \code{"a"}/\code{"b"}, or \code{1}/\code{2}
#' @param period Any date interval supported by \link{seq.Date}
#' @param balanced Either \code{TRUE} or \code{FALSE}
#' @param group_col The grouping column for this panel ("actor" or "priogrid_gid")
#' @param constructor \code{.rebeltrack_dataframe} or \code{.rebeltrack_dataframe_gid}
#' @keywords internal
.rebeltrack_dataframe_impl <- function(dataset, side, period, balanced,
                                       group_col, constructor) {
  # The `actor` column is added here unconditionally, even when
  # group_col == "priogrid_gid" - this matches the pre-refactor behaviour of
  # rebeltrack_dataframe_gid(), which also always added it to @events (used
  # by any measure function chained afterwards that reads `actor` directly,
  # e.g. via weighted_lag()'s own per-actor lag step).
  events <- dataset@events %>%
    dplyr::mutate(period_start = lubridate::floor_date(date_start, unit = period)) %>%
    dplyr::mutate(actor = .data[[get_var_by_side("side_%s_new_id", side)]])

  data <- events %>%
    dplyr::group_by(.data[[group_col]], period_start) %>%
    dplyr::summarize() %>%
    tidyr::complete(period_start = seq(min(period_start),
                                       max(period_start),
                                       by = period)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(active = TRUE)

  if (balanced) {
    period_seq <- seq(min(data$period_start),
                      max(data$period_start),
                      by = period)
    data <- data %>%
      dplyr::group_by(.data[[group_col]]) %>%
      tidyr::complete(period_start = period_seq, fill = list(active = FALSE)) %>%
      dplyr::ungroup()
  }

  data <- data %>%
    dplyr::mutate(period_end = period_start +
                    lubridate::period(period) - lubridate::days(1)) %>%
    dplyr::select(.data[[group_col]], period_start, period_end, active) %>%
    dplyr::arrange(period_start, .data[[group_col]])

  dataset <- rebeltrack_update_dataset(dataset, events = events)

  constructor(dataset = dataset, data = data)
}
