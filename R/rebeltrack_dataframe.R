#' @include rebeltrack_dataset.R
.RebelTrackDataFrame <- setClass("RebelTrackDataFrame",
                                 slots = c(dataset = "RebelTrackDataSet",
                                           data = "data.frame",
                                           n_actors = "integer",
                                           n_periods = "integer"))


# internal function to create the RebelTrackDataFrame S4 object
.rebeltrack_dataframe <- function(dataset, data) {
  .RebelTrackDataFrame(dataset = dataset,
                       data = data,
                       n_actors = dplyr::n_distinct(data$actor),
                       n_periods = dplyr::n_distinct(data$period_start))
}

#' Coarce to data.frame
#'
#' Coarce a RebelTrackDataFrame object to a data.frame.
#'
#' @param from A RebelTrackDataFrame object
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
#' df <- as.data.frame(data)
#' }
#' @export
as.data.frame.RebelTrackDataFrame <- function(from) {
  return(from@data) # extractor functions
}

# Set the as.data.frame() method for RebelTrackDataFrame Object
setAs(.RebelTrackDataFrame@className,
      "data.frame",
      as.data.frame.RebelTrackDataFrame)


# Set the show() method for RebelTrackDataFrame Object
setMethod("show", .RebelTrackDataFrame@className, function(object) {
  show_slot <- function(slot_name) {
    cat(sprintf("Slot \"%s\":\n", slot_name))
    methods::show(methods::slot(object, slot_name))
  }

  cat(sprintf("An object of class \"%s\"\n", class(object)))
  show_slot("data")
})

#' Create RebelTrackDataFrame Object
#'
#' Create a RebelTrackDataFrame grouped by \code{side} and \code{period}.
#'
#' @param dataset A RebelTrackDataSet object
#' @param side One of: {SIDE_A, SIDE_B} or {'A', 'B'} or {'a', 'b'} or {1, 2}
#' @param period Any date interval supported by \link{seq.Date} such as
#' "day(s)", "week(s)", "month(s)", "quarter(s)", or "year(s)", optionally
#' preceded by an integer, for example "3 months".
#' @param balanced Either \code{TRUE} or \code{FALSE}. If \code{TRUE}, a
#' balanced panel is returned.
#' @examples
#' library(rebeltrack)
#'
#' \dontrun{
#' dataset <- rebeltrack_load_dataset(type = UCDP_NON_STATE)
#'
#' data <- rebeltrack_dataframe(dataset,
#'                              side = SIDE_A,
#'                              period = "month",
#'                              balanced = TRUE)
#' }
#' @export
rebeltrack_dataframe <- function(dataset, side, period, balanced = FALSE) {
  events <- dataset@events %>%
    dplyr::mutate(period_start = lubridate::floor_date(date_start,
                                                       unit = period)) %>%
    dplyr::mutate_(actor = get_var_by_side("side_%s_new_id", side))


  data <- events %>%
    dplyr::group_by(actor, period_start) %>%
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
      dplyr::group_by(actor) %>%
      tidyr::complete(period_start = period_seq, fill = list(active = FALSE)) %>%
      dplyr::ungroup()
  }

  data <- data %>%
    dplyr::mutate(period_end = period_start +
                    lubridate::period(period) - lubridate::days(1)) %>%
    dplyr::select(actor, period_start, period_end, active) %>%
    dplyr::arrange(period_start, actor)

  dataset <- rebeltrack_update_dataset(dataset, events = events)

  .rebeltrack_dataframe(dataset = dataset, data = data)
}

