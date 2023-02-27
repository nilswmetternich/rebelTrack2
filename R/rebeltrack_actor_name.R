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
  name_var <- ifelse(long, "NameFull", "Name")
  actors <- x@dataset@actors %>%
    select(ActorID, .name = name_var)

  data <- as.data.frame(x) %>%
    dplyr::left_join(actors, by = c("actor" = "ActorID")) %>%
    dplyr::mutate(!!rlang::quo_name(rlang::enquo(var)) := .name) %>%
    dplyr::select(-.name)

  .rebeltrack_dataframe(dataset = x@dataset, data = data)
}

