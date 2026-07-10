# Quick check: the new gid/year table capped at 2019 again, same as
# priogrid's frozen release did - but this time from OUR OWN cshapes-based
# computation, not priogrid's bundled data. Two possible explanations:
#   (a) cshapes' actual bundled boundary data genuinely stops at 2019
#       despite the package claiming "1886 to today" coverage, OR
#   (b) a bug in rebeltrack_download_prio_grid()'s date handling - e.g. if a
#       country's current/ongoing episode has a missing (NA) end date rather
#       than an actual recent date, pmin()/pmax()/filtering could silently
#       drop exactly those rows.
# This checks the RAW cshp() output before any of our processing touches it.
#
# Run with: source("scripts/diagnose_cshapes_end_dates.R")

if (requireNamespace("devtools", quietly = TRUE)) {
  devtools::load_all(".")
} else {
  stop("Please install.packages('devtools') first.")
}

cshp <- cshapes::cshp(useGW = TRUE)

message("Total episodes: ", nrow(cshp))
message("class(cshp$end): ", paste(class(cshp$end), collapse = "/"))
message("Number of NA end dates: ", sum(is.na(cshp$end)))
message("Max raw end date (as-is, no as.Date() conversion): ", max(cshp$end, na.rm = TRUE))
message("Max end date after as.Date(): ", max(as.Date(cshp$end), na.rm = TRUE))

message("\nDistribution of end dates by year (top 15 most common end years):")
end_years <- lubridate::year(as.Date(cshp$end))
print(utils::head(sort(table(end_years), decreasing = TRUE), 15))

message("\nHow many distinct countries (gwcode) have their LATEST episode ",
        "ending after 2019-12-31?")
latest_per_country <- stats::aggregate(end ~ gwcode, data = sf::st_drop_geometry(cshp),
                                       FUN = function(x) max(as.Date(x)))
message(sum(latest_per_country$end > as.Date("2019-12-31")), " / ",
        nrow(latest_per_country), " countries")

message("\nExample rows for a country you'd expect to have very recent ",
        "changes (Ukraine, gwcode 369) and one with no recent border change ",
        "expected (e.g. France, gwcode 220):")
print(sf::st_drop_geometry(cshp[cshp$gwcode %in% c(369, 220),
                                c("gwcode", "country_name", "start", "end", "status")]))
