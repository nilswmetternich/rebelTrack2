#' Actor Name
#'
#' Get the actor name for each \code{actor} in the \link{rebeltrack_dataframe}.
#'
#' @param x A \code{RebelTrackDataFrame} object
#' @param var Name of the variable to create
#' @param long Whether to get the long or short name
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
#' data <- rebeltrack_actor_name(data, actor_name)
#' }
#' @export
rebeltrack_actor_name <- function(x, var, long = FALSE) {
  # Column names updated for the current UCDP actor release (was v18.1's
  # flat ActorID/Name/NameFull - none of those exist any more). The current
  # actor file only fills in NewName/NewNameFullEng when an actor has
  # actually been renamed (NameChange == 1); NameOrig/NameOrigFullEng are
  # populated for every actor. Falling back to the Orig columns via
  # coalesce() when there's no New value means every actor still gets a
  # name, rather than NA for the (common) case of an actor that never
  # changed names. See dev-notes/STEP2_NOTES.md.
  short_col <- "NameOrig"
  full_col <- "NameOrigFullEng"
  new_short_col <- "NewName"
  new_full_col <- "NewNameFullEng"

  actors <- x@dataset@actors %>%
    dplyr::mutate(.name = dplyr::coalesce(
      .data[[if (long) new_full_col else new_short_col]],
      .data[[if (long) full_col else short_col]]
    )) %>%
    dplyr::select(ActorId, .name)

  data <- as.data.frame(x) %>%
    dplyr::left_join(actors, by = c("actor" = "ActorId")) %>%
    dplyr::mutate(!!rlang::quo_name(rlang::enquo(var)) := .name) %>%
    dplyr::select(-.name)

  .rebeltrack_dataframe(dataset = x@dataset, data = data)
}

