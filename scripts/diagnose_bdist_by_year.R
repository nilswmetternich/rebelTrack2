# Quick follow-up: cshapes_gwcode has a hard cliff to 0 coverage in 2019+
# (confirmed - see dev-notes/DATA_SOURCES.md). bdist1/bdist2 (distance to nearest
# land-contiguous / international border) are conceptually also
# border-geometry-dependent, and might be built from the same CShapes 2.0
# source (which is only defined through 2019 per its own title/scope). This
# checks whether they have the same cliff, before deciding how big the fix
# needs to be. No re-download - reuses the cache.
#
# Run with: source("scripts/diagnose_bdist_by_year.R")

if (requireNamespace("devtools", quietly = TRUE)) {
  devtools::load_all(".")
} else {
  stop("Please install.packages('devtools') first.")
}

tv <- as.data.frame(priogrid::read_pg_timevarying())
tv <- tv[, c("pgid", "measurement_date", "bdist1", "bdist2", "cshapes_gwcode")]
tv$year <- lubridate::year(tv$measurement_date)

message("==== global coverage by year, all 259,200 cells (bdist1 / bdist2 / cshapes_gwcode) ====")
by_year <- stats::aggregate(
  cbind(!is.na(bdist1), !is.na(bdist2), !is.na(cshapes_gwcode)) ~ year,
  data = tv, FUN = mean
)
names(by_year) <- c("year", "share_bdist1", "share_bdist2", "share_gwcode")
print(by_year[by_year$year >= 2010, ], row.names = FALSE)
