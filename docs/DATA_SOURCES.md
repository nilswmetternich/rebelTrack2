# Data source notes (Step 1, 2026-07-09)

Prepared while updating `inst/extdata/config.yml` from UCDP v18.1 to v26.1.
I could not execute R or reach ucdp.uu.se / CRAN from the sandbox that
prepared this, so URLs below are confirmed reachable (checked via a page
fetch) but the exact contents/filenames of the zips are NOT verified -
that's what `scripts/step1_test_current_data.R` is for.

## What changed vs. the old config

| Dataset | Old (v18.1) | New (v26.1) | Notes |
|---|---|---|---|
| GED | `ged181-RData.zip` | `ged261-csv.zip` | Format changed RData -> CSV. Covers 1989-2025 now (was -2017). Confirmed reachable. |
| Dyadic | `ucdp-dyadic-181.RData.zip` | `ucdp-dyadic-261-csv.zip` | Not currently used by `rebeltrack_load_dataset()` (dead code path in `rebeltrack_load_dyadic_data()`), updated anyway. |
| Actors | flat `actorlist.csv` | `ucdp-actor-261-csv.zip` | **Format changed from flat CSV to a zip.** Need to confirm the CSV filename inside after `scripts/step1_test_current_data.R` runs, since `rebeltrack_load_actors()` globs for `actorlist.rds` (i.e. expects the extracted file to be named `actorlist.*`). |
| Termination | `*-2015.xlsx` | `UCDPConflictTerminationDataset_v4_2024_*.csv` | Not used by the main pipeline either; updated for completeness. |
| Translation tables (conflict/dyad/actor) | `translate_*.csv` | same URLs | Unchanged, confirmed still live by direct fetch. |
| PRIO-GRID | `grid.prio.org/api/csv/yearlies`, years 1989-2014 | computed from `cshapes` directly, no external grid data source at all | See below for the full journey (three iterations). |

## PRIO-GRID: resolved (dropped priogrid entirely, compute from cshapes directly)

This went through three iterations - keeping the history since it explains
why the final design looks the way it does.

**Iteration 1.** `rebeltrack_download()` originally pulled border/capital
distance from a legacy `grid.prio.org/api/csv/yearlies` CSV endpoint, capped
at years 1989-2014. Under v26.1's extended date range that meant every GED
event from 2015 onward (over half the dataset - confirmed by the Step 1 test
run: 98,515 of 194,544 events) had its distance covariates silently clamped
to 2014 values.

**Iteration 2.** Migrated to PRIO's ground-up replacement, the `priogrid` R
package (v3.0.1, github.com/prio-data/priogrid), pulling `bdist1`/`bdist2`
from its release and computing `capdist` ourselves (priogrid v3 dropped
distance-to-capital entirely - confirmed by checking its full 100+-entry
function/variable reference index, not just a variable list; the closest
thing, `traveltime_mean`/`traveltime_min`, is a static year-2000 snapshot of
travel time to the nearest major city, not capital-specific or time-varying).
Running this for real turned up a second, worse gap: `cshapes_gwcode`,
`bdist1`, and `bdist2` in priogrid's official v3.0.1 release **all cliff to
exactly 0% coverage starting in 2019** (checked year-by-year - a clean drop,
same year for all three). Root cause: priogrid's own boundary source is
"CShapes 2.0", whose defining paper is literally titled *"Mapping the
International System, 1886-2019"* - not a stale build, a genuine fixed edge
of that specific dataset. This hit large, heavily-conflicted countries with a
lot of recent activity hardest (Mexico, Ukraine, Brazil, Israel, Afghanistan,
DR Congo, Syria...), which is why the country breakdown looked so
counterintuitive at first (nothing to do with coastlines or small territories
- see the diagnostic scripts below for the full trail).

**Iteration 3 (current).** The CRAN `cshapes` package (v2.0, May 2026) is a
different, newer boundary source that claims coverage "1886 to today" - and
it's what rebeltrack was already using for capital coordinates. Once both
country assignment and border distance are computed from it directly,
priogrid provides nothing left to use (its other ~30 variables aren't
consumed anywhere in this package), so it was dropped entirely rather than
kept around for an unused `bdist1`. `R/rebeltrack_prio_grid.R` now:

- does ONE spatial join (`sf::st_join`) between all 259,200 grid cell
  centroids and cshapes' full historical set of country episodes (a single
  indexed operation, not a per-year loop - ocean cells are dropped for free
  since they never fall inside any polygon)
- computes `capdist` as the haversine distance from each matched cell's
  centroid to its country's capital that year
- computes `bdist2` as the distance from each cell's centroid to the
  boundary of the country it belongs to that year (`sf::st_boundary()` +
  `sf::st_distance()`, one call per historical episode rather than per cell)
- does **not** compute `bdist1` (distance to nearest *land-contiguous*
  border) - it isn't used anywhere in the package (only `bdist2` is, via
  `rebeltrack_distance_to_border()`), and it's a meaningfully harder
  calculation (shortest-path-along-connected-land, not a plain point-to-
  boundary distance) not worth solving for a variable nothing reads
- writes out a `gid`/`year`/`bdist2`/`capdist` table (bdist1 dropped from the
  shape), which `rebeltrack_load_prio_grid()` and the measure functions that
  consume it need no further changes to read
- includes duplicate-key guards at both the (cell, episode) and (cell, year)
  level, since a silent duplicate would inflate GED event rows on the
  downstream `left_join` rather than just producing a wrong value

`priogrid` is fully removed from `DESCRIPTION` (`Suggests` and `Remotes`)
and no longer downloaded - `rebeltrack_download()` now only needs `cshapes`
for PRIO-GRID-equivalent covariates.

This is unverified in the sense that I can't run R myself - the usual
write-then-verify loop applies. Worth checking once real output is in hand:
overall runtime of the spatial join + per-episode boundary distance loop,
and ideally a spot-check of `bdist2`/`capdist` values against the
`iteration 1` legacy values for the overlapping 1989-2014 years (which came
from a completely independent source, so agreement there would be a good
correctness signal).

**Verified by running it (2026-07-09):** one `sf` hiccup fixed along the way
- `cshapes`' historical polygons occasionally have a degenerate edge (a
duplicate vertex) that sf's S2 spherical engine rejects; `sf::st_make_valid()`
right after loading fixes it, no-op otherwise. After that fix, the full
pipeline ran clean and event-level coverage jumped to 94.6% (up from 64.5%
under priogrid) - our own spatial join is simply more accurate/complete than
priogrid's precomputed rasterization, independent of any year-range issue.

**`bdist2` definitional bug found and fixed (2026-07-09).**
`scripts/compare_bdist_capdist_to_legacy.R` (cross-checking against the
independent grid.prio.org legacy values for 1989-2014) showed `capdist`
correlating at 0.9977 - validated - but `bdist2` only at 0.3066, with a
systematic negative bias (mean diff -354.52km despite a median diff of just
1.66km, i.e. a small number of very large errors). Root cause: `bdist2` was
computed as the distance from a cell's centroid to `sf::st_boundary()` of
**its own** country polygon for that episode. A polygon's boundary includes
its coastline, so for any coastal cell this measured distance to the sea,
not distance to the nearest actual international border - exactly the kind
of error that would produce a few huge, wrong values while leaving most
interior/land-border cells looking fine (matching the small-median/large-
mean pattern observed).

Fixed in `R/rebeltrack_prio_grid.R`: for each episode, `bdist2` is now the
distance from the episode's cells to the union of every OTHER episode (any
country) whose date range overlaps this episode's at all - i.e. the nearest
point that actually falls inside a different, contemporaneous country's
territory, coastline excluded. This is an approximation in one respect: a
neighbouring country's territorial changes *within* the overlap window
(e.g. a civil war shifting control) are smoothed into a single unioned
geometry rather than tracked year-by-year, since doing this exactly would
require partitioning all of history into a much finer, globally-shared set
of intervals every time any country anywhere changes shape - a
disproportionate amount of extra computation for a level of precision this
variable was never expected to have. The error being fixed (coastline
counted as a border) was a much larger, systematic problem than this
approximation introduces.

**Result of that first fix, and a second correction (2026-07-10).** Re-running
`compare_bdist_capdist_to_legacy.R` after the "union of every temporally-
overlapping episode" fix above moved the `bdist2` correlation from 0.3066 to
0.6492 - better, but still far short of `capdist`'s 0.9977, with a clear
systematic negative bias remaining (mean diff -215.67km, max -2446.79km).
Checked PRIO-GRID's own codebook directly: `bdist2` is defined as "the
spherical distance from the cell centroid to the border of the nearest
neighbouring country, regardless of whether the nearest country is located
across international waters" - distance to whoever is closest *in that
specific year*, not an approximation over an episode's whole lifespan.

The remaining bias was exactly that approximation: for a long-lived episode
(e.g. a country with one continuous 1985-2019 episode), unioning "every
country that ever existed at any point during 1985-2019" pulls in states
that were not actually contemporaneous with any given year in that range
(e.g. a state that formed and dissolved decades apart from the year in
question), making the union artificially larger/closer than it should be
for that specific year - a systematic understatement, matching the observed
negative bias.

Fixed properly in `R/rebeltrack_prio_grid.R`: history since 1985 is now
partitioned into intervals bounded by every episode's start/end year
globally (typically a few dozen intervals in practice, not hundreds, since
most stable countries' episodes all clip to the same 1985 start and only
genuine post-1985 border changes - USSR/Yugoslavia/Czechoslovakia breakups,
South Sudan, Kosovo, etc. - introduce new breakpoints). Within each interval,
`bdist2` is computed using `sf::st_nearest_feature()` (a spatial-index
nearest-candidate lookup) against every OTHER episode actually active in
that exact interval, rather than a union over an episode's entire lifespan -
this is both more correct (no more temporally-mismatched neighbours) and
cheaper per call (no `sf::st_union()` of dozens of polygons, just a nearest-
candidate lookup + one distance call). `capdist` is unaffected by this change
(it only ever depended on a cell's own country/episode, never on
neighbours), so it's still expanded to years and computed exactly as before;
the two are now joined on `(gid, year)` at the end rather than both being
carried through the same per-episode expansion.

**Performance problem found on the first real run (2026-07-10).** The
interval count itself was fine (21 intervals, as expected - well within the
"a few dozen" estimate), but the run sat for 20+ minutes without completing
a single one. Root cause: `sf::st_nearest_feature()` builds a spatial index
over its candidate set on every call, and the code was passing it the full
~190-country active set (many with very detailed real-world coastlines) for
every country in every interval - thousands of expensive index rebuilds.
Fixed by pre-filtering candidates to only those whose bounding box is
anywhere near the target country's (a cheap numeric xmin/ymin/xmax/ymax
comparison, no geometry operations), with a generous 20-degree margin and a
full-candidate-set fallback if the filter ever produces zero matches (e.g.
an antimeridian-spanning country) - so correctness never depends on the
filter being exactly right, only speed does. Also added per-interval
progress messages (active/present country counts, elapsed time) since the
old "every 10 intervals" cadence gave no visibility into whether a run was
progressing or stuck.

**Still too slow even with the bbox pre-filter (2026-07-10).** The bbox
filter cuts the *candidate set size* per call, but doesn't address the
bigger issue: partitioning history into 21 global intervals means the same
~190 countries are "present" in nearly every interval, even though most of
them - and, more importantly, their actual nearby-neighbour sets - don't
change between intervals (a global interval boundary fires when ANY country
anywhere changes, most of which are irrelevant to a given country's own
neighbourhood). The code was recomputing the same answer for the same
country dozens of times over. Fixed with a cache keyed on (this country's
episode id, its sorted bbox-filtered candidate ids): identical signature
means provably identical distances, so they're reused rather than
recomputed. Most countries only ever see one or two distinct signatures
across their whole post-1985 history, so this should collapse the effective
number of `st_nearest_feature` calls back down close to the original
~194-episode count. Console output now also reports cache hits vs. actual
computations per interval so this is directly observable.

**Rebuilt around per-country local neighbourhoods instead of global
intervals (2026-07-10).** Even the cached, bbox-filtered global-interval
version stayed slow - the cache mostly helped small/medium countries, but
large countries have wide bounding boxes, so unrelated changes elsewhere in
the world kept falling inside their filter margin and forcing recomputation
of exactly the biggest, most cell-heavy countries. This matches Nils's
suggestion directly: track, per country, only whether *that country's own
nearest neighbours* changed - not whether anything changed anywhere in the
world. Rebuilt so that for every episode, a small fixed "neighbour universe"
(geographically plausible candidates, any point in history) is computed
once, and a target episode's own lifetime is only split into sub-periods at
the years where one of ITS candidates actually starts or ends. Most episodes
now need exactly one distance computation for their entire lifetime.

**Switched from polygon distances to grid-native (cell-to-cell) distances
(2026-07-10, Nils's suggestion).** Even with the local-neighbourhood
restructuring above, the remaining cost was `sf::st_nearest_feature()` /
`st_distance()` computing point-to-*polygon* distance against cshapes' raw,
highly detailed real-world coastline geometries - walking that boundary
data is the expensive part, independent of how few candidate countries or
sub-periods are involved. Nils's idea: since PRIO-GRID is itself a regular
0.5-degree raster, use the grid's own structure - compute distance to the
nearest *other country's grid cell centroid* (which we already have for
free from the one-time spatial join) instead of to the country's polygon
boundary. This turns the calculation into point-to-point nearest-neighbour
(a spatial-index coordinate lookup), which is dramatically cheaper than
point-to-polygon, and arguably a more natural definition of "border
distance" at this product's own resolution anyway. Trade-off: bdist2 is now
quantised to roughly one grid cell width (~55km at the equator) - a cell
can't read as, say, 3km from a border, since the nearest it can score is
about one cell over - which is a reasonable, resolution-appropriate cost
for the speed-up.

**Verified by running it (2026-07-10): fixed, fast, and correct.** Full
pipeline run: bdist2 computation completed in 164 seconds (down from 20+
minutes) with 1,686 distance computations across 199 post-1985 episodes -
close to the ~194 "one per episode" ideal, confirming the local-
neighbourhood restructuring is working as intended. Coverage unchanged
(100% within 1985-2019, 0.65 overall / 0.96 restricted-to-covered-years
after the GED join, matching prior runs).

`compare_bdist_capdist_to_legacy.R` against the independent 1989-2014
legacy values: `bdist2` correlation is now **0.969** (up from 0.3066 with
the original own-boundary bug, then 0.6492 with the first, too-coarse
union-based fix) - close to `capdist`'s 0.9977. The remaining difference is
exactly the expected grid-quantisation signature: median diff +23.13km,
mean +12.22km, both almost precisely half a grid cell width (~55km cells ->
~27km half-width) - consistent with measuring to the nearest other
country's cell *centroid* rather than the exact boundary line, as expected
and accepted when this design was adopted. A handful of extreme outliers
remain (max diff ~2223km, min ~-2447km) - not yet investigated, likely a
small number of edge cases (isolated states, high-latitude cells where grid
cell width shrinks, or the rare worldwide-fallback path) - worth a look if
`bdist2` precision becomes important for a specific analysis, but not
blocking given the overall correlation and the systematic/explained nature
of the typical-case bias.

This closes out the PRIO-GRID/bdist2 rework. `R/rebeltrack_prio_grid.R` now:
computes `capdist` via haversine to capital (per cell/episode, expanded to
years); computes `bdist2` via nearest-other-country-cell-centroid distance,
restricted per episode to a precomputed geographic "neighbour universe" and
split into sub-periods only where one of those specific neighbours actually
changed; both are joined on `(gid, year)` and saved as the PRIO-GRID
replacement table.

**The 2019 ceiling is real, not a bug.** Checked `cshapes::cshp()`'s raw
`end` dates directly: 0 of 187 countries have any episode extending past
2019-12-31, and 174 of 365 total episodes end on that exact date (every
"currently ongoing" episode was capped there when the dataset was built).
The CRAN page's "1886 to today" framing is misleading - the actual bundled
boundary geometries are the same CShapes 2.0 vintage priogrid uses, just a
more complete/accurate extraction of it.

**Nils's call on how to handle 2020-2025:** rather than clamping those years
to 2019's values (the original design, `year_prio <- pmin(year, year_max)`
in `rebeltrack_load_dataset.R`), those events now get a plain `NA` for
`bdist2`/`capdist` instead of a silently-substituted older value - more
honest about what's actually known, at the cost of more missingness in
recent years. `rebeltrack_load_dataset()` now does a direct year-to-year
join with no clamping at all.

## Known code issues found by reading (not yet run)

These will very likely surface when `scripts/step1_test_current_data.R` is
run, independent of data currency:

- `rebeltrack_config.R` looked for `system.file("extData", ...)` but the
  actual directory is `inst/extdata` (lowercase). Fixed in this pass -
  it's why the package may have silently failed to find its own config on
  case-sensitive filesystems (Linux/CI) even though it likely worked fine on
  a Mac, where the default filesystem is case-insensitive.
- `dplyr::mutate_()` (SE-style verb) is used in `rebeltrack_dataframe.R`,
  `rebeltrack_gid_dataframe.R`, and elsewhere. This was removed from dplyr
  in the 1.0 rewrite (2020) - any dplyr installed today will not have this
  function at all, so this should hard-fail immediately on `rebeltrack_dataframe()`
  regardless of GED data.
- `weighted_lag()` / `weighted_lag_gid()` in `rebeltrack_utils.R` read
  `attributes(group)$vars` to recover the grouping columns for a join. Modern
  dplyr no longer stores a `vars` attribute on grouped data frames (use
  `dplyr::group_vars()` instead) - this will likely return `NULL`, silently
  turning the intended explicit join into a natural join. This function is
  the shared engine behind nearly every measure function (casualty count,
  event count, days affected, distance measures, transnational measures,
  both actor and gid variants), so it's high-priority for Step 2.
- ~~`rebeltrack_load_ged()`/`rebeltrack_load_actors()`/`rebeltrack_load_prio_grid()`
  glob for specific filenames~~ **Fixed and confirmed by the Step 1 test
  run.** The new UCDP files are named `GEDEvent_v26_1.csv`/`Actor_v26_1.csv`,
  which didn't match the old `ged*.rds`/`actorlist.rds` glob patterns even
  on a case-insensitive Mac filesystem (glob matching itself is
  case-sensitive regardless of the filesystem). `rebeltrack_load_rds()` now
  just reads the most recently modified `.rds` file in each dataset's own
  directory instead of matching on filename.
- `tests/testthat/test_ged.R` and other tests hardcode dimensions from the
  v18.1 GED (`nrow == 59017`, `ncol == 46`). These will need updating to
  whatever v26.1 actually produces - not a bug, just expected maintenance.

## Next step

Run `scripts/step1_test_current_data.R` locally (fresh, since it now runs
the cshapes-only path in `rebeltrack_prio_grid.R` with priogrid removed) and
send back the console output - especially the `prio/grid` inspection step,
the `capital_dist`/`border_dist` coverage numbers, and the final PASS/FAIL
summary table. Then, if that looks healthy, run
`scripts/compare_bdist_capdist_to_legacy.R` to cross-check the new
`bdist2`/`capdist` values against the original grid.prio.org-sourced values
for 1989-2014, which is a genuinely independent check since the two came
from different upstream sources.

## Diagnostic scripts written during this investigation

For reference, the trail that led to the current design:
`scripts/diagnose_capdist_gap.R` (isolated the gap to grid-cell country
assignment, not capital matching), `scripts/diagnose_capdist_gap_by_year.R`
and `scripts/diagnose_bdist_by_year.R` (found the 2019 cliff in priogrid's
`cshapes_gwcode`/`bdist1`/`bdist2`). These queried priogrid directly and are
now historical - they won't work once priogrid is uninstalled, since that
dependency has been dropped. `scripts/compare_bdist_capdist_to_legacy.R` is
still active/useful.
