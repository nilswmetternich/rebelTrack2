#' Load Dataset
#'
#' Create a RebelTrackDataSet object that contains all available datasets
#'
#' @param type Filter by type of event. One of: UCDP_STATE_BASED, UCDP_NON_STATE
#' or UCDP_ONE_SIDED.
#' @param actor Filter by numeric actor codes in either side-A or side-B
#' @param conflict Filter by conflict ID
#' @param region Filter by region. One of "Africa", "Americas", "Asia",
#' "Europe", "Middle East"
#' @param country_iso3c Filter by 3-letter ISO 3166-1 alpha-3 country codes
#' @param country_gw3c Filter by 3-letter Gleditsch and Ward country codes
#' @param country_gw3n Filter by 3-digit Gleditsch and Ward country codes
#' @param date_start Filter by events occcuring on or after \code{date_start}
#' @param date_end Filter by events occcuring on or before \code{date_end}
#' @param prec precision based on \code{where_prec} in \link{http://ucdp.uu.se/downloads/ged/ged181.pdf}
#' @param download Download datasets if necessary
#' @examples
#' library(rebeltrack)
#'
#' \dontrun{
#' dataset <- rebeltrack_load_dataset(type = UCDP_NON_STATE)
#' }
#' @include rebeltrack_dataset.R
#' @export
rebeltrack_load_dataset <- function(type = NULL,
                                    actor = NULL,
                                    conflict = NULL,
                                    region = NULL,
                                    country_gw3c = NULL,
                                    country_gw3n = NULL,
                                    country_iso3c = NULL,
                                    date_start = NULL,
                                    date_end = NULL,
                                    prec = 1,
                                    download = TRUE) {
  config <- rebeltrack_config()

  if (download) {
    # FIXME: call rebeltrack_download() if necessary
  }

  if (!is.null(date_start) & !lubridate::is.interval(date_start))
    date_start <- lubridate::interval(date_start, date_start)

  if (!is.null(date_end) & !lubridate::is.interval(date_end))
    date_end <- lubridate::interval(date_end, date_end)

  ged <- rebeltrack_load_ged(config) %>%
    rebeltrack_ged_filter(prec, .data$where_prec %in% !!prec) %>%
    rebeltrack_ged_filter(type, .data$type_of_violence %in% !!type) %>%
    rebeltrack_ged_filter(actor, .data$side_a_new_id %in% !!actor |
                                 .data$side_b_new_id %in% !!actor) %>%
    rebeltrack_ged_filter(conflict, .data$conflict_new_id %in% !!conflict) %>%
    rebeltrack_ged_filter(region, .data$region %in% !!region) %>%
    rebeltrack_ged_filter(country_iso3c, .data$isocc %in% !!country_iso3c) %>%
    rebeltrack_ged_filter(country_gw3c, .data$gwab %in% !!country_gw3c) %>%
    rebeltrack_ged_filter(country_gw3n, .data$gwno %in% !!country_gw3n) %>%
    rebeltrack_ged_filter(date_start, .data$date_start %within% !!date_start) %>%
    rebeltrack_ged_filter(date_end, .data$date_end %within% !!date_end)

  actors <- rebeltrack_load_actors(config)

  prio <- rebeltrack_load_prio_grid(config)
  year_max <- max(prio$year)

  events <- ged %>%
    dplyr::mutate(year_prio = ifelse(year > year_max, year_max, year)) %>%
    dplyr::left_join(prio, by = c("year_prio" = "year",
                                  "priogrid_gid" = "gid")) %>%
    dplyr::select(-year_prio)

  .RebelTrackDataSet(events = events, actors = actors)
}

# Filter the dataframe
rebeltrack_ged_filter <- function(x, arg, filter) {
  if (is.null(arg))
    return(x)
  return(dplyr::filter(x, !!rlang::enquo(filter)))
}

# Load latest RDS from the given path
rebeltrack_load_rds <- function(config, path, pattern) {
  path <- file.path(config$path, path, pattern)
  files <- sort(Sys.glob(path))
  readRDS(tail(files, n=1))
}

# Load GED data
rebeltrack_load_ged <- function(config) {
  rebeltrack_load_rds(config, file.path("ucdp", "ged"), "ged*.rds")
}

# Load Dyadic data
rebeltrack_load_dyadic_data <- function(config) {
  rebeltrack_load_rds(config, file.path("ucdp", "termination-dyadic"), "ucdp-term-dyadic-*.rds")

  rebeltrack_load_rds(config, file.path("ucdp", "dyadic"), "ucdp-dyadic-*.rds")
}

# Load actors data
rebeltrack_load_actors <- function(config) {
  rebeltrack_load_rds(config, file.path("ucdp", "actors"), "actorlist.rds")
}

# Load PRIO grid data
rebeltrack_load_prio_grid <- function(config) {
  rebeltrack_load_rds(config, file.path("prio", "grid"), "grid.rds")
}


