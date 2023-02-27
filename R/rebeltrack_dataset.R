.RebelTrackDataSet <- setClass("RebelTrackDataSet",
                               slots = c(events = "data.frame",
                                         actors = "data.frame"))


# update a dataset object
rebeltrack_update_dataset <- function(dataset,
                                      events = NULL,
                                      actors = NULL) {
  if (is.null(events))
    events <- dataset@events

  if (is.null(actors))
    actors <- dataset@actors

  .RebelTrackDataSet(events = events, actors = actors)
}
