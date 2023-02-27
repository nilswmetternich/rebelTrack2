#' Calculate Distance to Border
#'
#' Calculate distance to border of grouped by \code{priogrid_gid} and \code{period}
#' specified when the \code{RebelTrackDataFrameGid} was created
#' with \link{rebeltrack_dataframe_gid}.
#'
#' @param x A \code{RebelTrackDataFrameGid} object
#' @param var Name of the variable to create
#' @param fill Default value when no events are observed in the specified period.
#' @param lag An integer giving the number of positions to lead or lag by.
#' @param weight A weight matrix to apply.
#' @param func Name of function to apply (default = mean)
#' @param ... Additional arguments passed to \code{func}
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
#' data <- rebeltrack_distance_to_border_gid(data, border_dist)
#' }
#' @export
rebeltrack_distance_to_border_gid<- function(x, var, fill = NA, lag = 0,
                                          weight = NULL, func = mean, ...) {
  group <- x@dataset@events %>%
    dplyr::group_by(priogrid_gid, period_start)

  # TODO: add unique to summary stats, to throw error if all not unique for particular period.
  group_summary <- dplyr::summarize(
    group, .var = rebeltrack_summary_stats(bdist2, func, na.rm = TRUE, ...))

  data <- x %>%
    weighted_lag_gid(rlang::quo_name(rlang::enquo(var)),
                 group,
                 group_summary,
                 fill,
                 lag,
                 weight)
  .rebeltrack_dataframe_gid(dataset = x@dataset, data = data) #got rid of gid
}

