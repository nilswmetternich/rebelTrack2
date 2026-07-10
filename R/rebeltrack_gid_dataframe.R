#' @include rebeltrack_dataset.R
.RebelTrackDataFrameGid <- setClass("RebelTrackDataFrameGid",
                                 slots = c(dataset = "RebelTrackDataSet",
                                           data = "data.frame",
                                           n_actors = "integer",
                                           n_periods = "integer"))

# internal function to create the RebelTrackDataFrame S4 object


.rebeltrack_dataframe_gid <- function(dataset, data) {
  .RebelTrackDataFrameGid(dataset = dataset,
                       data = data,
                       n_actors = dplyr::n_distinct(data$priogrid_gid),
                       n_periods = dplyr::n_distinct(data$period_start)) # changed to include the priogrid_gid - definite bodge
}

#' Coerce to data.frame
#'
#' Coerce a RebelTrackDataFrame object to a data.frame.
#'
#' @param from A RebelTrackDataFrameGid object
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
#' df <- as.data.frame(data)
#' }
#' @export
as.data.frame.RebelTrackDataFrameGid <- function(from) {
  return(from@data) # extractor functions
}

# Set the as.data.frame() method for RebelTrackDataFrameGid Object
setAs(.RebelTrackDataFrameGid@className,
      "data.frame",
      as.data.frame.RebelTrackDataFrameGid)


# Set the show() method for RebelTrackDataFrameGid Object
setMethod("show", .RebelTrackDataFrameGid@className, function(object) {
  show_slot <- function(slot_name) {
    cat(sprintf("Slot \"%s\":\n", slot_name))
    methods::show(methods::slot(object, slot_name))
  }

  cat(sprintf("An object of class \"%s\"\n", class(object)))
  show_slot("data")
})

#' Create RebelTrackDataFrameGid Object
#'
#' Create a RebelTrackDataFrameGid grouped by \code{side} and \code{period}.
#'
#' @param dataset A RebelTrackDataSet object
#' @param side One of \code{SIDE_A}/\code{SIDE_B}, \code{"A"}/\code{"B"},
#'   \code{"a"}/\code{"b"}, or \code{1}/\code{2}
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
#' data <- rebeltrack_dataframe_gid(dataset,
#'                              side = SIDE_A,
#'                              period = "month",
#'                              balanced = TRUE)
#' }
#' @include rebeltrack_dataframe_impl.R
#' @export
rebeltrack_dataframe_gid <- function(dataset, side, period, balanced = FALSE) {
  .rebeltrack_dataframe_impl(dataset, side, period, balanced,
                             group_col = "priogrid_gid", constructor = .rebeltrack_dataframe_gid)
}


