# Step 1 diagnostic script: test rebeltrack against current UCDP GED data (v26.1)
#
# What this does: runs the README workflow (config -> download -> load_dataset
# -> dataframe -> a few measure functions) end to end, with each stage wrapped
# in tryCatch so one failure doesn't stop the run. At the end it prints a
# PASS/FAIL summary so we get a full picture from a single run.
#
# How to run:
#   1. Open the rebeltrack.Rproj / this package folder in RStudio (or set
#      your working directory to the package root in a plain R session).
#   2. install.packages(c("devtools", "rlang", "magrittr", "dplyr", "tidyr",
#        "httr", "haven", "lubridate", "readr", "readxl", "yaml", "matlab",
#        "Matrix", "sf", "slam", "cshapes"))
#   3. source("scripts/step1_test_current_data.R")
#   4. Send me back the full console output (or at minimum the summary table
#      printed at the end, plus any error messages).
#
# NOTE: rebeltrack_download() will download ~26 years of UCDP GED data and
# the actor dataset, then computes both border distance (bdist2) and
# distance-to-capital itself directly from the cshapes package - no priogrid
# dependency any more (see R/rebeltrack_prio_grid.R and
# dev-notes/DATA_SOURCES.md for why). This may take a while and use a meaningful
# amount of disk space under ~/.rebeltrack. If you'd rather not re-download,
# delete or rename ~/.rebeltrack first to make sure this is a clean test of
# the new config, not a mix of old cached
# files.

results <- list()

run_step <- function(name, expr) {
  message("\n==== ", name, " ====")
  warnings_seen <- character(0)
  out <- tryCatch({
    # withCallingHandlers keeps the call stack alive so muffleWarning is a
    # valid restart, letting us log warnings and keep going without treating
    # them as fatal. Errors still propagate out to the tryCatch below.
    value <- withCallingHandlers(
      expr,
      warning = function(w) {
        warnings_seen[[length(warnings_seen) + 1]] <<- conditionMessage(w)
        message("WARNING: ", conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    )
    message("OK")
    list(status = "PASS", value = value, error = NULL, warnings = warnings_seen)
  }, error = function(e) {
    message("FAILED: ", conditionMessage(e))
    list(status = "FAIL", value = NULL, error = conditionMessage(e), warnings = warnings_seen)
  })
  results[[name]] <<- out
  out$value
}

# 0. Load the package from source (so we're testing the edited config.yml /
# rebeltrack_config.R in this folder, not whatever is currently installed).
if (requireNamespace("devtools", quietly = TRUE)) {
  devtools::load_all(".")
} else {
  stop("Please install.packages('devtools') and re-run, so we load the ",
       "package from this source tree rather than any old installed copy.")
}

# 1. Config
config <- run_step("rebeltrack_config()", rebeltrack_config())
if (!is.null(config)) str(config)

# 2. Download (writes to ~/.rebeltrack, converts each file to .rds)
run_step("rebeltrack_download()", rebeltrack_download())

# 2b. Inspect exactly what ended up on disk - this tells us directly whether
# the glob patterns used by rebeltrack_load_ged()/rebeltrack_load_actors()/
# rebeltrack_load_prio_grid() actually match the files the new UCDP zips
# produced, and lets us sanity-check the new prio/grid table directly before
# it gets joined into anything else.
run_step("list ~/.rebeltrack contents", {
  path <- config$path
  files <- list.files(path.expand(path), recursive = TRUE, full.names = FALSE)
  print(files)
  files
})

prio_table <- run_step("inspect prio/grid table", {
  prio <- rebeltrack_load_prio_grid(config)
  message("prio grid: ", nrow(prio), " rows, columns: ",
          paste(names(prio), collapse = ", "))
  message("year range: ", min(prio$year, na.rm = TRUE), "-", max(prio$year, na.rm = TRUE))
  message("share of rows with non-NA capdist: ",
          round(mean(!is.na(prio$capdist)), 3))
  message("share of rows with non-NA bdist2: ",
          round(mean(!is.na(prio$bdist2)), 3))
  print(utils::head(prio))
  prio
})

# 3. Load dataset (GED + actors + PRIO-GRID join)
dataset <- run_step("rebeltrack_load_dataset()", rebeltrack_load_dataset())
if (!is.null(dataset)) {
  message("events: ", nrow(dataset@events), " rows x ", ncol(dataset@events), " cols")
  message("actors: ", nrow(dataset@actors), " rows x ", ncol(dataset@actors), " cols")
  message("date range: ", min(dataset@events$date_start, na.rm = TRUE), " to ",
          max(dataset@events$date_start, na.rm = TRUE))
  # The PRIO-GRID join no longer clamps event years beyond prio's coverage
  # to the latest available year - events from years prio doesn't cover
  # (currently 2020+, since cshapes' actual data caps at 2019 - see
  # dev-notes/DATA_SOURCES.md) now get a plain NA for bdist2/capdist instead of a
  # silently-substituted older value. So a lower share here than the raw
  # prio/grid table's own coverage is expected and correct, not a bug.
  events_year_max <- max(dataset@events$year, na.rm = TRUE)
  message("max GED event year: ", events_year_max)
  message("share of events with non-NA capdist after join: ",
          round(mean(!is.na(dataset@events$capdist)), 3))
  message("share of events with non-NA bdist2 after join: ",
          round(mean(!is.na(dataset@events$bdist2)), 3))
  if (!is.null(prio_table)) {
    message("share of events with non-NA capdist, restricted to years prio ",
            "actually covers: ",
            round(mean(!is.na(dataset@events$capdist[dataset@events$year <= max(prio_table$year)])), 3))
  }
}

# 4. Build actor x month panel
data <- run_step("rebeltrack_dataframe()", {
  rebeltrack_dataframe(dataset, side = SIDE_B, period = "month", balanced = TRUE)
})
if (!is.null(data)) {
  df <- as.data.frame(data)
  message("panel: ", nrow(df), " rows, ", dplyr::n_distinct(df$actor), " actors, ",
          dplyr::n_distinct(df$period_start), " periods")
}

# 5. Measure functions (the most commonly used ones)
if (!is.null(data)) {
  data2 <- run_step("rebeltrack_event_count()", {
    rebeltrack_event_count(data, event_count)
  })

  data3 <- run_step("rebeltrack_casualty_count()", {
    rebeltrack_casualty_count(if (!is.null(data2)) data2 else data, SIDE_A, casualty_count)
  })

  data4 <- run_step("rebeltrack_transnational_ratio()", {
    rebeltrack_transnational_ratio(if (!is.null(data3)) data3 else data, transnational_ratio)
  })

  base_for_distance <- if (!is.null(data4)) data4 else data

  data5 <- run_step("rebeltrack_distance_to_border()", {
    rebeltrack_distance_to_border(base_for_distance, border_dist)
  })

  data6 <- run_step("rebeltrack_distance_to_capital()", {
    rebeltrack_distance_to_capital(if (!is.null(data5)) data5 else base_for_distance, capital_dist)
  })

  if (!is.null(data6)) {
    df6 <- as.data.frame(data6)
    message("share of panel rows with non-NA capital_dist: ",
            round(mean(!is.na(df6$capital_dist)), 3))
    message("share of panel rows with non-NA border_dist: ",
            round(mean(!is.na(df6$border_dist)), 3))
    print(utils::head(df6))
  }
}

# 6. Grid-cell (gid) variant - smaller smoke test
dataframe_gid <- run_step("rebeltrack_dataframe_gid()", {
  rebeltrack_dataframe_gid(dataset, side = SIDE_B, period = "month", balanced = TRUE)
})
if (!is.null(dataframe_gid)) {
  gdf <- as.data.frame(dataframe_gid)
  message("gid panel: ", nrow(gdf), " rows, ",
          dplyr::n_distinct(gdf$priogrid_gid), " grid cells")

  gid_capital <- run_step("rebeltrack_distance_to_capital_gid()", {
    rebeltrack_distance_to_capital_gid(dataframe_gid, capital_dist)
  })
  if (!is.null(gid_capital)) {
    gdf2 <- as.data.frame(gid_capital)
    message("share of gid panel rows with non-NA capital_dist: ",
            round(mean(!is.na(gdf2$capital_dist)), 3))
  }
}

# ---- Summary ----
message("\n\n==== SUMMARY ====")
summary_df <- data.frame(
  step = names(results),
  status = vapply(results, function(x) x$status, character(1)),
  n_warnings = vapply(results, function(x) length(x$warnings), integer(1)),
  error = vapply(results, function(x) if (is.null(x$error)) "" else x$error, character(1))
)
print(summary_df, right = FALSE)
