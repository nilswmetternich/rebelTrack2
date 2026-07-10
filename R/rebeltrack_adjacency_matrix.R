#' Adjacency Matrix
#'
#' Calculate the adjacency matrix fo each \code{actor} in the \link{rebeltrack_dataframe}.
#'
#' @param x A \code{RebelTrackDataFrame} object
#' @param by one of GROUP_BY_CONFLICT or GROUP_BY_GOVERNMENT
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
#' adjacency_matrix <- rebeltrack_adjacency_matrix(data)
#' }
#' @export
rebeltrack_adjacency_matrix <- function(x, by = GROUP_BY_CONFLICT) {
  group_vars <- c("conflict_new_id", "gwnoa")
  group_var <- do.call(switch, c(list(by), group_vars))
  if (is.null(group_var))
    group_var <- group_vars[1]

  group <- x@dataset@events %>%
    dplyr::group_by(actor, period_start)

  group_summary <- group %>%
    dplyr::mutate(group_id = .data[[group_var]]) %>%
    dplyr::summarize(group_id = list(unique(group_id)))

  data <- as.data.frame(x)

  n_actors <- dplyr::n_distinct(data$actor)
  n_periods <- dplyr::n_distinct(data$period_start)

  adj_matrix <- data %>%
    dplyr::left_join(group_summary, by = dplyr::group_vars(group)) %>%
    # was purrr::map_lgl(group_id, is.null) - purrr isn't a declared
    # dependency anywhere in DESCRIPTION; vapply() does the same thing with
    # only base R.
    dplyr::filter(!vapply(group_id, is.null, logical(1))) %>%
    tidyr::unnest(group_id) %>%
    dplyr::filter(!is.na(group_id)) %>%
    dplyr::group_by(period_start, group_id) %>%
    tidyr::expand(actor, accomplice = actor) %>%
    dplyr::group_by(period_start, actor, accomplice) %>%
    dplyr::summarize(edges = n()) %>%
    tidyr::spread(accomplice, edges, drop=FALSE, fill = 0) %>%
    dplyr::ungroup() %>%
    dplyr::select(-c(period_start, actor))

  adj_matrix %>%
    as.matrix() %>%
    t() %>%
    array(dim = c(n_actors, n_actors, n_periods)) %>%
    aperm(c(2, 1, 3))
}
