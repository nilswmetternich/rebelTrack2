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
#' @param prec precision based on \code{where_prec} in \url{http://ucdp.uu.se/downloads/ged/ged181.pdf}
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

  # NOTE (bugfix): date_start/date_end used to each be wrapped in
  # lubridate::interval(date_start, date_start) - a ZERO-WIDTH interval,
  # since both endpoints are the same value - and then filtered via
  # %within%, which only matches events whose own date_start/date_end
  # falls exactly on that single instant. That's why passing e.g.
  # date_start = as.Date("2020-01-01") silently returned zero rows instead
  # of "on or after 2020-01-01" as documented. Replaced with plain
  # >=/<= comparisons, which match the documented "on or after"/"on or
  # before" contract directly.
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
    rebeltrack_ged_filter(date_start, .data$date_start >= !!date_start) %>%
    rebeltrack_ged_filter(date_end, .data$date_end <= !!date_end)

  actors <- rebeltrack_load_actors(config)

  prio <- rebeltrack_load_prio_grid(config)

  # NOTE: this used to clamp any event year beyond prio's coverage down to
  # the latest available year (e.g. every 2020+ event silently got 2019's
  # border/capital distance values), on the theory that a stale value beats
  # none. By Nils's preference this is now a plain year-to-year join instead:
  # events from years prio doesn't cover (currently, anything after 2019 -
  # see dev-notes/DATA_SOURCES.md) just get NA for bdist2/capdist rather than a
  # silently-substituted older value. This is more honest about what's
  # actually known, at the cost of more missingness in recent years.
  events <- ged %>%
    dplyr::left_join(prio, by = c("year" = "year",
                                  "priogrid_gid" = "gid"))

  .RebelTrackDataSet(events = events, actors = actors)
}

# Filter the dataframe
rebeltrack_ged_filter <- function(x, arg, filter) {
  if (is.null(arg))
    return(x)
  return(dplyr::filter(x, !!rlang::enquo(filter)))
}

# Load latest RDS from the given dataset directory.
#
# NOTE: this used to glob for a hardcoded filename pattern per dataset (e.g.
# "ged*.rds", "actorlist.rds"), which broke as soon as UCDP changed their
# release file naming (e.g. GED v26.1 saves as "GEDEvent_v26_1.rds", not
# anything matching "ged*.rds"; the actor dataset is "Actor_v26_1.rds", not
# "actorlist.rds"). Each dataset already has its own directory
# (config$path/<source>/<dataset>), so there's no need to also match on
# filename - just take the most recently modified .rds file in that
# directory. This also means re-running rebeltrack_download() after a UCDP
# version bump picks up the new file automatically.
rebeltrack_load_rds <- function(config, path) {
  dir <- file.path(config$path, path)
  files <- list.files(dir, pattern = "\\.rds$", full.names = TRUE)

  if (length(files) == 0)
    stop(sprintf("no .rds file found in '%s' - run rebeltrack_download() first", dir))

  # most recently modified wins if more than one is present
  info <- file.info(files)
  readRDS(rownames(info)[order(info$mtime, decreasing = TRUE)][1])
}

# Load GED data
rebeltrack_load_ged <- function(config) {
  rebeltrack_load_rds(config, file.path("ucdp", "ged"))
}

# Load Dyadic data
rebeltrack_load_dyadic_data <- function(config) {
  list(
    termination = rebeltrack_load_rds(config, file.path("ucdp", "termination-dyadic")),
    dyadic = rebeltrack_load_rds(config, file.path("ucdp", "dyadic"))
  )
}

# Load actors data
rebeltrack_load_actors <- function(config) {
  rebeltrack_load_rds(config, file.path("ucdp", "actors"))
}

# Load PRIO grid data
rebeltrack_load_prio_grid <- function(config) {
  rebeltrack_load_rds(config, file.path("prio", "grid"))
}


