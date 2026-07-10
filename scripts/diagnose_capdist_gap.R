# Diagnose why ~35% of GED events don't get a matched capdist/bdist value
# (see docs/DATA_SOURCES.md and the Step 1 conversation for background).
#
# This does NOT re-download anything - it reuses whatever
# rebeltrack_download() already cached (GED under ~/.rebeltrack, priogrid's
# release under ~/.rebeltrack/prio/raw). Run scripts/step1_test_current_data.R
# first if you haven't already.
#
# The gap could come from two different places, and this script isolates
# which one it is:
#   (A) the grid cell an event falls in has no cshapes_gwcode (country)
#       assigned at all in that year - a grid-assignment gap, most likely
#       from conflict events clustering at coastlines/borders where a grid
#       cell's centroid can fall just outside the country polygon that
#       "owns" most of that cell
#   (B) the grid cell DOES have a cshapes_gwcode, but it never matches a
#       cshapes::cshp() capital episode for that year - which would point to
#       a coding mismatch between priogrid's bundled cshapes_gwcode and the
#       gwcode values in the cshapes package installed locally (e.g. a
#       different cshapes version, or a type/format mismatch)
#
# How to run: source("scripts/diagnose_capdist_gap.R"), send back everything
# printed.

results <- list()

run_step <- function(name, expr) {
  message("\n==== ", name, " ====")
  out <- tryCatch({
    value <- withCallingHandlers(
      expr,
      warning = function(w) {
        message("WARNING: ", conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    )
    message("OK")
    list(status = "PASS", value = value, error = NULL)
  }, error = function(e) {
    message("FAILED: ", conditionMessage(e))
    list(status = "FAIL", value = NULL, error = conditionMessage(e))
  })
  results[[name]] <<- out
  out$value
}

if (requireNamespace("devtools", quietly = TRUE)) {
  devtools::load_all(".")
} else {
  stop("Please install.packages('devtools') first.")
}

config <- rebeltrack_config()

dataset <- run_step("load dataset", rebeltrack_load_dataset())
events <- dataset@events

run_step("event column names", {
  print(names(events))
})

prio <- run_step("load cached prio grid table", rebeltrack_load_prio_grid(config))
max_prio_year <- max(prio$year, na.rm = TRUE)
events$year_prio <- pmin(events$year, max_prio_year)

message("\nTotal events: ", nrow(events))
message("Events with non-NA capdist (from the main pipeline's join): ",
        sum(!is.na(events$capdist)), " (",
        round(mean(!is.na(events$capdist)), 3), ")")

# ---- Re-read priogrid's cshapes_gwcode column fresh (from the already-
# downloaded/cached release - no new network calls) ----
tv <- run_step("read priogrid time-varying (cached)", {
  x <- as.data.frame(priogrid::read_pg_timevarying())
  x <- x[, c("pgid", "measurement_date", "cshapes_gwcode")]
  x$year <- lubridate::year(x$measurement_date)
  x
})

events_gwcode <- run_step("join events to cshapes_gwcode by (grid cell, year)", {
  dplyr::left_join(
    events[, c("id", "priogrid_gid", "year_prio")],
    tv[, c("pgid", "year", "cshapes_gwcode")],
    by = c("priogrid_gid" = "pgid", "year_prio" = "year")
  )
})

share_gwcode_present <- mean(!is.na(events_gwcode$cshapes_gwcode))
message("\n(A) Share of EVENTS whose grid cell/year has a cshapes_gwcode assigned: ",
        round(share_gwcode_present, 3))
message("    (this isolates the grid-assignment stage - if this alone is",
        " already close to 0.645, the gap is almost entirely here, not in",
        " the capital-matching step below)")

# ---- Type/coding sanity check before attempting the capital join ----
capitals_raw <- run_step("load cshapes capital table", cshapes::cshp(useGW = TRUE))
capitals_raw <- sf::st_drop_geometry(capitals_raw)

message("\nclass(priogrid's cshapes_gwcode): ",
        paste(class(events_gwcode$cshapes_gwcode), collapse = "/"))
message("class(cshapes::cshp()$gwcode):    ",
        paste(class(capitals_raw$gwcode), collapse = "/"))

priogrid_codes <- sort(unique(stats::na.omit(events_gwcode$cshapes_gwcode)))
cshapes_codes <- sort(unique(capitals_raw$gwcode))
overlap <- intersect(priogrid_codes, cshapes_codes)
message("Distinct gwcodes touched by events (via priogrid): ", length(priogrid_codes))
message("Distinct gwcodes in cshapes::cshp(): ", length(cshapes_codes))
message("Overlap: ", length(overlap), " (",
        round(length(overlap) / length(priogrid_codes), 3),
        " of priogrid's event-relevant codes also appear in cshapes)")
if (length(overlap) / max(length(priogrid_codes), 1) < 0.9) {
  message("  -> LOW OVERLAP: this points to a coding/version mismatch between",
          " priogrid's bundled cshapes_gwcode and the gwcode values in the",
          " cshapes package installed locally, independent of any date logic.")
  message("  gwcodes in events but NOT in cshapes::cshp(): ",
          paste(setdiff(priogrid_codes, cshapes_codes), collapse = ", "))
}

# ---- Capital-episode matching, for events that DID get a gwcode ----
capitals <- data.frame(
  gwcode = capitals_raw$gwcode,
  start_year = lubridate::year(as.Date(capitals_raw$start)),
  end_year = lubridate::year(as.Date(capitals_raw$end))
)

has_gwcode <- events_gwcode[!is.na(events_gwcode$cshapes_gwcode), ]

matched <- run_step("check capital-episode match for events with a gwcode", {
  unique_gy <- unique(has_gwcode[, c("cshapes_gwcode", "year_prio")])
  names(unique_gy) <- c("gwcode", "year")
  unique_gy$matched <- mapply(function(gw, yr) {
    any(capitals$gwcode == gw & capitals$start_year <= yr & capitals$end_year >= yr)
  }, unique_gy$gwcode, unique_gy$year)
  unique_gy
})

message("\n(B) Share of (gwcode, year) combinations [given gwcode IS present]",
        " that DO match a cshapes capital episode: ",
        round(mean(matched$matched), 3))

unmatched_gwcodes <- sort(unique(matched$gwcode[!matched$matched]))
if (length(unmatched_gwcodes) > 0) {
  message("gwcodes present via priogrid but never matched to a cshapes",
          " capital episode for the relevant year(s): ",
          paste(unmatched_gwcodes, collapse = ", "))
  # how many events does each unmatched gwcode actually account for
  unmatched_events <- has_gwcode[has_gwcode$cshapes_gwcode %in% unmatched_gwcodes, ]
  print(sort(table(unmatched_events$cshapes_gwcode), decreasing = TRUE))
} else {
  message("No unmatched gwcodes - stage (B) accounts for none of the gap.")
}

# ---- Bonus: geographic breakdown of the NO-gwcode-at-all events, if GED's
# own country/lat/lon columns are present under their usual names ----
no_gwcode <- events[events$id %in% events_gwcode$id[is.na(events_gwcode$cshapes_gwcode)], ]

run_step("country breakdown of no-gwcode events (if 'country' column exists)", {
  if (!"country" %in% names(events))
    stop("no 'country' column on events - see the printed column names above")
  tab <- sort(table(no_gwcode$country), decreasing = TRUE)
  print(utils::head(tab, 20))
  tab
})

run_step("centroid-offset check (if latitude/longitude columns exist)", {
  latcol <- intersect(c("latitude", "lat"), names(events))
  loncol <- intersect(c("longitude", "lon", "long"), names(events))
  if (length(latcol) == 0 || length(loncol) == 0)
    stop("no obvious latitude/longitude columns - see the printed column names above")

  centroids <- rebeltrack_pgid_to_lonlat(unique(no_gwcode$priogrid_gid))
  merged <- dplyr::left_join(no_gwcode, centroids, by = "priogrid_gid")
  offset_km <- rebeltrack_haversine_km(
    merged[[loncol[1]]], merged[[latcol[1]]], merged$lon, merged$lat
  )
  message("Distance between each no-gwcode event's own coordinates and its",
          " grid cell centroid (small values here, well under the ~40km",
          " cell diagonal, would support the coastal/border centroid theory):")
  print(summary(offset_km))
  offset_km
})

# ---- Summary ----
message("\n\n==== SUMMARY ====")
summary_df <- data.frame(
  step = names(results),
  status = vapply(results, function(x) x$status, character(1)),
  error = vapply(results, function(x) if (is.null(x$error)) "" else x$error, character(1))
)
print(summary_df, right = FALSE)
