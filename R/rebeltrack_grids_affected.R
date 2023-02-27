#' Grids Affected by Events
#'
#' Calculate the number of grids affected by events grouped by \code{actor} and
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
#' data <- rebeltrack_grids_affected(data, grids_affected)
#' }
#' @export
rebeltrack_grids_affected <- function(x, var, fill = 0, lag = 0, weight = NULL) {
  group <- x@dataset@events %>%
    dplyr::group_by(actor, period_start)

  group_summary <- dplyr::summarize(
    group, .var = dplyr::n_distinct(priogrid_gid))

  data <- x %>%
    weighted_lag(rlang::quo_name(rlang::enquo(var)),
                 group,
                 group_summary,
                 fill,
                 lag,
                 weight)

  .rebeltrack_dataframe(dataset = x@dataset, data = data)
}

