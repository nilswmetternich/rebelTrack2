#' national Count
#'
#' Calculate the number of cells active in the country where the \code{priogrid_gid} is active in the
#' given \code{period}
#'
#' (rebeltrack_transnational_count_gid was an exact duplicate of this
#' function and has been removed - use this one. See docs/STEP2_NOTES.md.)
#'
#' @param x A \code{RebelTrackDataFrameGid} object
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
#' data <- rebeltrack_dataframe_gid(dataset,
#'                              period = "month",
#'                              balanced = TRUE)
#'
#' data <- rebeltrack_national_count_gid(data, national_ratio)
#' }
#' @include rebeltrack_measure_impl.R
#' @export
rebeltrack_national_count_gid <- function(x, var, fill = 0, lag = 0,
                                               weight = NULL) {
  .rebeltrack_measure_impl(
    x, group_col = "priogrid_gid",
    var = rlang::quo_name(rlang::enquo(var)), fill = fill, lag = lag, weight = weight,
    lag_engine = weighted_lag_gid, constructor = .rebeltrack_dataframe_gid,
    make_group = function(events, group_col) {
      events %>%
        dplyr::group_by(country_id, period_start) %>%
        dplyr::mutate(count = dplyr::n_distinct(priogrid_gid)) %>%
        dplyr::group_by(dplyr::across(dplyr::all_of(c(group_col, "period_start"))))
    },
    summarise = function(group) dplyr::summarize(group, .var = max(count))
  )
}
