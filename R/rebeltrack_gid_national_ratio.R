#' national Ratio
#'
#' Ratio of events in the grids's country and all other countries. Replaces
#' rebeltrack_transnational_ratio_gid
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
#' data <- rebeltrack_national_ratio_gid(data, national_ratio)
#' }
#' @export
rebeltrack_national_ratio_gid <- function(x, var, fill = 0, lag = 0,
                                               weight = NULL) {
  group <- x@dataset@events %>%
    dplyr::group_by(period_start) %>%
    dplyr::mutate(total = dplyr::n()) %>%
    dplyr::group_by(country_id, period_start) %>%
    dplyr::mutate(country_total = dplyr::n()) %>%
    dplyr::group_by(priogrid_gid, period_start)

  group_summary <- dplyr::summarize(group, .var = mean(country_total) / mean(total))

  data <- x %>%
    weighted_lag_gid(rlang::quo_name(rlang::enquo(var)),
                     group,
                     group_summary,
                     fill,
                     lag,
                     weight)

  .rebeltrack_dataframe_gid(dataset = x@dataset, data = data)
}
