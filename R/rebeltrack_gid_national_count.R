#' national Count
#'
#' Calculate the number of cells active in the country where the \code{priogrid_gid} is active in the
#' given \code{period}
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
#' @export
rebeltrack_national_count_gid <- function(x, var, fill = 0, lag = 0,
                                               weight = NULL) {
  group <- x@dataset@events %>%
    dplyr::group_by(country_id, period_start) %>%
    dplyr::mutate(count = dplyr::n_distinct(priogrid_gid)) %>%
    dplyr::group_by(priogrid_gid, period_start)

  group_summary <- dplyr::summarize(group, .var = max(count))
  data <- x %>%
    weighted_lag_gid(rlang::quo_name(rlang::enquo(var)),
                     group,
                     group_summary,
                     fill,
                     lag,
                     weight)

  .rebeltrack_dataframe_gid(dataset = x@dataset, data = data)
}
