# Cross-check the new cshapes-based bdist2/capdist against the ORIGINAL
# grid.prio.org legacy values for the years they overlap (1989-2014). These
# come from two completely independent sources (old PRIO-GRID 2.0 CSV API vs.
# the current cshapes package), so agreement is a real correctness signal -
# not just "the code ran without erroring."
#
# Assumes the very first legacy download is still sitting at
# ~/.rebeltrack/prio/grid/grid.rds (the one fixed-name file from before any
# of this migration - every run since has written a timestamped
# grid_YYYYMMDD.rds alongside it instead of overwriting it). If you've since
# deleted it, this script will say so and stop.
#
# Run with: source("scripts/compare_bdist_capdist_to_legacy.R")

if (requireNamespace("devtools", quietly = TRUE)) {
  devtools::load_all(".")
} else {
  stop("Please install.packages('devtools') first.")
}

config <- rebeltrack_config()
legacy_path <- file.path(path.expand(config$path), "prio", "grid", "grid.rds")

if (!file.exists(legacy_path)) {
  stop("No legacy grid.rds found at ", legacy_path, " - can't do this ",
       "comparison (it may have been cleaned up, or never existed in this ",
       "~/.rebeltrack). Skipping is fine, this is a nice-to-have check, not ",
       "a blocker.")
}

legacy <- readRDS(legacy_path)
message("legacy (grid.prio.org) table: ", nrow(legacy), " rows, columns: ",
        paste(names(legacy), collapse = ", "))

current <- rebeltrack_load_prio_grid(config) # picks the newest grid_*.rds
message("current (cshapes) table: ", nrow(current), " rows, columns: ",
        paste(names(current), collapse = ", "))

overlap_years <- intersect(unique(legacy$year), unique(current$year))
message("overlapping years: ", min(overlap_years), "-", max(overlap_years))

compare <- dplyr::inner_join(
  legacy[legacy$year %in% overlap_years, c("gid", "year", "bdist2", "capdist")],
  current[current$year %in% overlap_years, c("gid", "year", "bdist2", "capdist")],
  by = c("gid", "year"),
  suffix = c("_legacy", "_new")
)

message("\nmatched (gid, year) rows for comparison: ", nrow(compare))

if (nrow(compare) == 0) {
  stop("No overlapping (gid, year) rows matched - the gid numbering or year ",
       "range may not line up the way expected. Worth investigating before ",
       "trusting either table.")
}

for (v in c("bdist2", "capdist")) {
  legacy_col <- compare[[paste0(v, "_legacy")]]
  new_col <- compare[[paste0(v, "_new")]]
  both_present <- !is.na(legacy_col) & !is.na(new_col)

  message("\n== ", v, " ==")
  message("rows with a value in both: ", sum(both_present), " / ", nrow(compare))
  if (sum(both_present) > 0) {
    diff <- new_col[both_present] - legacy_col[both_present]
    message("correlation (legacy vs new): ", round(cor(legacy_col[both_present], new_col[both_present]), 4))
    message("mean absolute difference: ", round(mean(abs(diff)), 2), " km")
    message("median absolute difference: ", round(median(abs(diff)), 2), " km")
    message("summary of new - legacy (km):")
    print(summary(diff))
  }
}
