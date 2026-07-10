# Follow-up to diagnose_capdist_gap.R: that script showed the entire capdist
# gap traces to cshapes_gwcode being NA at the event's grid cell/year (not a
# gwcode coding mismatch, and not a capital-matching failure). The countries
# hit hardest (Mexico, Ukraine, Brazil, Israel, Afghanistan...) are large,
# heavily-conflicted countries with a lot of *recent* activity, which
# suggests a temporal gap rather than a spatial/coastal one: does
# cshapes_gwcode coverage simply drop off in recent years?
#
# This checks that directly - no re-download, reuses the cache.
# Run with: source("scripts/diagnose_capdist_gap_by_year.R")

if (requireNamespace("devtools", quietly = TRUE)) {
  devtools::load_all(".")
} else {
  stop("Please install.packages('devtools') first.")
}

dataset <- rebeltrack_load_dataset()
events <- dataset@events

tv <- as.data.frame(priogrid::read_pg_timevarying())
tv <- tv[, c("pgid", "measurement_date", "cshapes_gwcode")]
tv$year <- lubridate::year(tv$measurement_date)

# ---- (1) Global picture: for EVERY grid cell/year in priogrid's release
# (not just where GED events happen to fall), what share has a gwcode? ----
message("==== global cshapes_gwcode coverage by year (all 259,200 cells) ====")
global_by_year <- stats::aggregate(
  !is.na(cshapes_gwcode) ~ year, data = tv, FUN = mean
)
names(global_by_year) <- c("year", "share_non_na")
print(global_by_year[global_by_year$year >= 2010, ], row.names = FALSE)

# ---- (2) Event-level picture: for GED events specifically, what share per
# year has a matched gwcode at their own cell/year? This is the one that
# actually matters for the package. ----
max_prio_year <- max(tv$year, na.rm = TRUE)
events$year_prio <- pmin(events$year, max_prio_year)

events_gwcode <- dplyr::left_join(
  events[, c("id", "year", "priogrid_gid", "year_prio")],
  tv[, c("pgid", "year", "cshapes_gwcode")],
  by = c("priogrid_gid" = "pgid", "year_prio" = "year")
)

message("\n==== share of GED EVENTS with non-NA cshapes_gwcode, by event year ====")
by_year <- stats::aggregate(
  !is.na(cshapes_gwcode) ~ year, data = events_gwcode, FUN = mean
)
names(by_year) <- c("year", "share_matched")
counts_by_year <- table(events_gwcode$year)
by_year$n_events <- as.integer(counts_by_year[as.character(by_year$year)])
print(by_year, row.names = FALSE)

message("\nmax year with any cshapes_gwcode data at all (globally): ", max_prio_year)
message("If share_matched craters at some cutoff year well before ", max_prio_year,
        ", that's a temporal coverage gap in priogrid's cshapes_gwcode ",
        "specifically (not a bug in rebeltrack's join code) - and would ",
        "mean bdist1/bdist2 have the same gap, since they likely derive ",
        "from the same cshapes-based country/border assignment.")
