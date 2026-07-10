# rebeltrack 0.2.0

## Step 1: current UCDP data support

* Updated `inst/extdata/config.yml` to pull UCDP GED, dyadic, actor, and
  termination data from the current v26.1 releases (was v18.1). GED format
  changed from RData to CSV; actor data changed from a flat CSV to a zip.
* Fixed several bugs that only surfaced once tested against current data
  and packages, none of which were specific to the new UCDP release:
  * `rebeltrack_config()` looked for `extData` instead of `extdata`
    (case-sensitive filesystems only).
  * `dplyr::mutate_()` (removed in dplyr 1.0) replaced with
    `dplyr::mutate(x = .data[[var]])` throughout.
  * `attributes(group)$vars` (no longer set by modern dplyr) replaced with
    `dplyr::group_vars(group)`.
  * `rebeltrack_load_ged()`/`rebeltrack_load_actors()`/
    `rebeltrack_load_prio_grid()` now load the most recently modified `.rds`
    file in each dataset's directory instead of matching a hardcoded
    filename pattern, which broke when UCDP changed its release naming.
* Rebuilt PRIO-GRID-equivalent covariates (border distance, capital
  distance) entirely from the `cshapes` R package, after two earlier
  attempts (a legacy `grid.prio.org` API capped at 2014, then the `priogrid`
  v3 package, which turned out to be capped at 2019 for the same reason)
  proved insufficient. See `docs/DATA_SOURCES.md` for the full investigation
  and the three-stage `bdist2` computation redesign (own-boundary distance
  -> temporally-overlapping-union approximation -> per-country local
  neighbourhood intervals using grid-cell-centroid distances), which ended
  at a 0.969 correlation against the original independent legacy values
  (capdist: 0.9977).
* Events/cells outside PRIO-GRID's actual coverage (currently pre-1985 or
  post-2019) now get `NA` for `bdist2`/`capdist` instead of being silently
  clamped to the nearest available year's value.
* Updated `tests/testthat/test_ged.R` and `test_actors.R` dimension checks
  from v18.1 values to the current release's.

## Step 2: modernization and function-set reduction

* Fixed additional install-breaking bugs found by reading (not caught by
  `devtools::load_all()`-based testing, which is more permissive about
  namespace resolution than a real install):
  * `rebeltrack_actor_name()` used a bare `select()` with no `dplyr::`
    prefix and a tidyselect bug; also updated to the current UCDP actor
    schema (`ActorId`, `NameOrig`/`NameOrigFullEng` with a `NewName`/
    `NewNameFullEng` fallback when an actor has been renamed).
  * `rebeltrack_adjacency_matrix()` depended on `purrr::map_lgl()` without
    declaring `purrr` anywhere - replaced with base R `vapply()`.
  * `rebeltrack_casualty_count_gid_sideA()` called `rebeltrack::weighted_lag_gid()`
    (`::` on a non-exported internal function) - fixed to call it bare.
  * `rebeltrack_load_dataset()`'s `date_start`/`date_end` filters silently
    matched almost nothing: each bound was wrapped in a zero-width
    `lubridate::interval()` (start == end) and filtered via `%within%`,
    which only matches events landing on that exact instant rather than
    the documented "on or after"/"on or before" semantics. Replaced with
    plain `>=`/`<=` comparisons.
* Removed three pairs of exact-duplicate functions:
  `rebeltrack_transnational_ratio_gid`/`rebeltrack_national_ratio_gid`,
  `rebeltrack_transnational_count_gid`/`rebeltrack_national_count_gid`, and
  `rebeltrack_actors_active_gid`/`rebeltrack_actors_present_gid`. Kept one
  from each pair; no change to any surviving function's name or signature.
* Fixed `rebeltrack_actors_present_gid()` to count each actor once via
  `n_distinct(c(side_a, side_b))` instead of summing `n_distinct(side_a) +
  n_distinct(side_b)` separately - the old version only gave the right
  answer when side_a/side_b were guaranteed disjoint (true for
  `UCDP_STATE_BASED`, not guaranteed for other event types).
* Consolidated the actor/gid "measure" function pairs (event count,
  casualty count, days affected, distance to border/capital, transnational
  ratio/count, national ratio/count, actors present - 12 functions in all)
  onto one shared internal engine (`.rebeltrack_measure_impl()` in
  `R/rebeltrack_measure_impl.R`). Purely internal - every exported function
  name and signature is unchanged.
* Consolidated `rebeltrack_dataframe()`/`rebeltrack_dataframe_gid()` (the
  panel constructors) onto a shared internal engine
  (`.rebeltrack_dataframe_impl()` in `R/rebeltrack_dataframe_impl.R`), same
  no-API-change approach.
* **Behavioural change:** `rebeltrack_days_affected()`/`_gid()` now measure
  the actual duration of conflict (the union of every event's
  `date_start`-`date_end` span) instead of only counting the number of
  distinct days on which an event *started*. Added a new sibling pair,
  `rebeltrack_days_ongoing()`/`_gid()`, which additionally clips each
  event's span to the boundaries of the period it's being aggregated into,
  for a value that can never exceed the period's own length.
* Rewrote `rebeltrack_adjacency_matrix_gid()` for performance, exploiting
  PRIO-GRID's row-major gid numbering (sequential from 1 at the
  south-west corner, west to east, wrapping to the next row after 720
  cells) to replace per-cell coordinate round-trips, a `Vectorize()`-based
  per-row neighbor lookup, list-column set intersection, and a dense
  `gid x gid` matrix allocated per period with vectorized modular
  arithmetic, a single join against active cells, and one direct sparse
  array construction. Also dropped `active_cells()`/`lag_for_active()`
  (dead code - referenced an undefined variable, unreachable from the
  exported function), leftover debug prints/`browser()` calls, and the
  now-unused `matlab` dependency. Verified against the original on a real
  3-month sample: identical dimensions, dimnames, and all 1064 nonzero
  entries; ~28x faster on that sample alone. See `docs/STEP2_NOTES.md` for
  the full writeup and equivalence check.
* Added `tests/testthat/helper-dataset.R`, a session-cached dataset
  fixture (`.rebeltrack_test_dataset()`). Every test file previously called
  `rebeltrack_load_dataset()` directly - several multiple times, once per
  side/period combination under test - so a single `devtools::test()`/
  `check()` run re-read and re-joined the full GED/actors/PRIO-GRID data
  from disk 30+ times over. Tests now share one load for the whole suite.

See `docs/STEP2_NOTES.md` for the full file-by-file audit.

# rebeltrack 0.1.1

* Initial tracked version.
