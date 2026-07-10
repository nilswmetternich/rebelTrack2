#' Calculate Casualties
#'
#' Calculate the total number of casualties grouped by \code{priogrid_gid} and \code{period}
#' specified when the \code{RebelTrackDataFrameGid} was created with
#' \link{rebeltrack_dataframe_gid}. This encodes side_a and side_b
#'
#' @param x A \code{RebelTrackDataFrameGid} object
#' @param var Name of the variable to create
#' @param fill Default value when no events are observed in the specified period.
#' @param lag An integer giving the number of positions to lead or lag by.
#' @param weight A weight matrix to apply. Must be a Rebeltrack GID matrix to respect dimensionality.
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
#' data <- rebeltrack_casualty_count_gid(data, casualty_count)
#' }
#' @include rebeltrack_measure_impl.R
#' @export
rebeltrack_casualty_count_gid <- function(x, var, fill = 0, lag = 0,
                                      weight = NULL) {
  .rebeltrack_measure_impl(
    x, group_col = "priogrid_gid",
    var = rlang::quo_name(rlang::enquo(var)), fill = fill, lag = lag, weight = weight,
    lag_engine = weighted_lag_gid, constructor = .rebeltrack_dataframe_gid,
    make_group = .simple_group(function(events) dplyr::mutate(
      events, casualty_count = deaths_a + deaths_b)),
    summarise = function(group) dplyr::summarize(group, .var = sum(casualty_count))
  )
}


#' Calculate Casualties
#'
#' Calculate the  number of casualties grouped by \code{priogrid_gid} and \code{period} and side
#' specified when the \code{RebelTrackDataFrameGid} was created with
#' \link{rebeltrack_dataframe_gid}. Specifically for side A
#'
#' @param x A \code{RebelTrackDataFrameGid} object
#' @param var Name of the variable to create
#' @param fill Default value when no events are observed in the specified period.
#' @param lag An integer giving the number of positions to lead or lag by.
#' @param weight A weight matrix to apply. Must be a Rebeltrack GID matrix to respect dimensionality.
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
#' data <- rebeltrack_casualty_count_gid_sideA(data, casualty_count)
#' }
#' @include rebeltrack_measure_impl.R
#' @export
rebeltrack_casualty_count_gid_sideA <- function(x, var, fill = 0, lag = 0,
                                                weight = NULL) {
  .rebeltrack_measure_impl(
    x, group_col = "priogrid_gid",
    var = rlang::quo_name(rlang::enquo(var)), fill = fill, lag = lag, weight = weight,
    lag_engine = weighted_lag_gid, constructor = .rebeltrack_dataframe_gid,
    make_group = .simple_group(function(events) dplyr::mutate(
      events, casualty_count = deaths_a)),
    summarise = function(group) dplyr::summarize(group, .var = sum(casualty_count))
  )
}

#' Calculate Casualties
#'
#' Calculate the  number of casualties grouped by \code{priogrid_gid} and \code{period} and side
#' specified when the \code{RebelTrackDataFrameGid} was created with
#' \link{rebeltrack_dataframe_gid}. Specifically for side B
#'
#' @param x A \code{RebelTrackDataFrameGid} object
#' @param var Name of the variable to create
#' @param fill Default value when no events are observed in the specified period.
#' @param lag An integer giving the number of positions to lead or lag by.
#' @param weight A weight matrix to apply. Must be a Rebeltrack GID matrix to respect dimensionality.
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
#' data <- rebeltrack_casualty_count_gid_sideB(data, casualty_count)
#' }
#' @include rebeltrack_measure_impl.R
#' @export
rebeltrack_casualty_count_gid_sideB <- function(x, var, fill = 0, lag = 0,
                                                weight = NULL) {
  .rebeltrack_measure_impl(
    x, group_col = "priogrid_gid",
    var = rlang::quo_name(rlang::enquo(var)), fill = fill, lag = lag, weight = weight,
    lag_engine = weighted_lag_gid, constructor = .rebeltrack_dataframe_gid,
    make_group = .simple_group(function(events) dplyr::mutate(
      events, casualty_count = deaths_b)),
    summarise = function(group) dplyr::summarize(group, .var = sum(casualty_count))
  )
}
