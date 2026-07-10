# Step 2 notes: modernization + function-set reduction

Step 2 goal (from the original plan): update functions for compatibility
with current packages/best practice, and reduce the function set where
sensible, before building a new package release.

Approach agreed with Nils: fix install-breaking bugs and remove exact
duplicates first (this pass, low risk), then tackle the bigger actor/gid
consolidation as a separate, more careful pass with its own testing.

## Audit method

Read all 35 files in `R/` directly (not just grepped) to find anything that
wasn't already caught by the Step 1 pipeline tests. This matters because
`devtools::load_all(".")` - which every Step 1 test run used - is more
permissive about namespace resolution than a real `library(rebeltrack)`
after installation: it attaches all of `Imports:` to the search path, so
code that's missing a proper `dplyr::` prefix or a NAMESPACE import can run
fine under `load_all()` and then break the moment someone actually installs
the package. Several of the bugs below are exactly that pattern - correct
under every test we've run so far, and latent until install.

## Fixed in this pass

**Install-breaking bugs (would fail under a real `library(rebeltrack)`,
not caught by any existing test):**

- `rebeltrack_actor_name.R` called bare `select()` with no `dplyr::` prefix.
  NAMESPACE has no `import(dplyr)`/`importFrom(dplyr, ...)` at all (only
  `%>%`, `%within%`, and `new` are imported, despite dplyr being a real
  `Imports:` dependency) - so this only ever worked because `load_all()`
  papers over it. Fixed to `dplyr::select(...)`. The same line also had a
  tidyselect bug - `select(.name = name_var)` doesn't resolve `name_var` as
  a string holding a column name under modern dplyr; fixed to
  `dplyr::select(.name = dplyr::all_of(name_var))`.
- `rebeltrack_adjacency_matrix.R` called `purrr::map_lgl()`, but purrr isn't
  declared anywhere in DESCRIPTION - would fail with "there is no package
  called 'purrr'" unless purrr happened to already be installed as some
  other package's dependency. Replaced with base R:
  `vapply(group_id, is.null, logical(1))`, no new dependency needed.
- `rebeltrack_gid_casualty_count.R` (the side-A variant only) called
  `rebeltrack::weighted_lag_gid(...)`. `::` only resolves *exported*
  functions, and `weighted_lag_gid` isn't exported (it's the shared internal
  engine used by nearly every measure function). The default and side-B
  variants in the same file correctly call it bare; fixed the side-A one to
  match. Not caught by testing because `tests/testthat/test_casualty_count_gid.R`
  only exercises the default (both-sides) variant, not the side-A/side-B
  ones - a real test coverage gap worth keeping in mind.

**Cleanup (not bugs, just noise):**

- Removed a stray `print(dim(a))` debug line left in `weight_apply()`
  (`rebeltrack_utils.R`).

**`rebeltrack_actor_name.R` column schema fix (2026-07-10):** Nils ran
`colnames(rebeltrack_load_dataset()@actors)` and confirmed the current UCDP
actor release has no `ActorID`/`Name`/`NameFull` columns at all (those are
v18.1 names). Checked the UCDP Actor Dataset Codebook to map old to new
correctly rather than guess: `NameOrig`/`NameOrigFullEng` are populated for
every actor (the name at/since registration), while `NewName`/
`NewNameFullEng` are *only* populated when `NameChange == 1` (i.e. the actor
has actually been renamed) - otherwise they're `NA`. Fixed
`rebeltrack_actor_name()` to join on `ActorId` (was `ActorID`) and to use
`dplyr::coalesce(NewName, NameOrig)` (and the FullEng equivalents for
`long = TRUE`), so every actor gets a name - the current name if it changed,
the original name otherwise - rather than `NA` for any actor that was never
renamed. Not covered by any existing test (nothing calls
`rebeltrack_actor_name()` in `scripts/step1_test_current_data.R` or
`tests/testthat/`) - worth a quick manual check once run.

**Flagged but NOT fixed (needs a decision, not a mechanical fix):**

- `rebeltrack_gid_adjacency_matrix.R`'s `active_cells()` references an
  undefined `data` variable - would error "object 'data' not found" if ever
  called. Left as-is with a comment: it's not reachable from any exported
  function (`rebeltrack_adjacency_matrix_gid()` goes through
  `active_neighbours()` instead), so nothing exercises it. Likely just dead
  code to delete in the consolidation pass rather than a function worth
  fixing - flagged there rather than guessed at.
**`rebeltrack_actors_active_gid` / `rebeltrack_actors_present_gid` (2026-07-10):**
Asked Nils about the `n_distinct(side_a) + n_distinct(side_b)` pattern.
Confirmed intentional for the original use case: in `UCDP_STATE_BASED`
events, side_a is always the state and side_b always the rebel group, so
the two sides are genuinely disjoint sets of actors and summing their
distinct counts separately is correct. But Nils wants this to generalise to
other event types too (`UCDP_NON_STATE`, where two non-state groups can
appear as either side across different events, or interstate conflicts),
where the same actor could legitimately appear as side_a in one event and
side_b in another - the old sum-based approach would double-count that
actor. Fixed by switching to `dplyr::n_distinct(c(side_a, side_b))`, which
counts each actor once regardless of role: identical result to before when
the sides really are disjoint (the state-based case), correct even when
they're not (other event types).

While looking at this, found that `rebeltrack_actors_active_gid` and
`rebeltrack_actors_present_gid` were themselves an undiscovered *third*
exact-duplicate pair (missed in the original audit since nothing pointed at
it the way the national/transnational docstring did) - identical bodies,
just different names, both computing the same `priogrid_gid`/`period_start`
actor count. Removed `rebeltrack_actors_active_gid` (`R/rebeltrack_gid_actors_active.R`,
its `.Rd`, its NAMESPACE export, its DESCRIPTION Collate entry), kept
`rebeltrack_actors_present_gid` with the n_distinct fix applied, and
corrected its docstring, which had claimed to be the "Equivalent of
rebeltrack_grids_affected" - checked, and that's actually a different
metric (grid cells affected per actor, not actors present per grid cell) -
looks like a leftover copy-paste doc error, now removed. No test or script
referenced either function by name, so nothing else needed updating.

## Removed: exact duplicate functions

Two pairs of `_gid` functions were byte-for-byte identical implementations
under different names:

- `rebeltrack_transnational_ratio_gid` was an exact duplicate of
  `rebeltrack_national_ratio_gid` (whose own docstring already said
  "Replaces rebeltrack_transnational_ratio_gid" - the duplicate was just
  never actually deleted).
- `rebeltrack_transnational_count_gid` was an exact duplicate of
  `rebeltrack_national_count_gid` (same relationship, inferred by symmetry
  with the ratio pair since there was no explicit docstring note on this
  one).

Removed `R/rebeltrack_gid_transnational_ratio.R` and
`R/rebeltrack_gid_transnational_count.R`, their `man/*.Rd` files, and their
`export()` lines in NAMESPACE and `Collate:` entries in DESCRIPTION. The
actor-level (non-`_gid`) `rebeltrack_transnational_ratio` and
`rebeltrack_transnational_count` are untouched - those are different
functions, not part of this duplication.

**Nils: run `devtools::document()` to regenerate NAMESPACE/man pages
cleanly from the current roxygen comments** (this pass hand-edited
NAMESPACE/DESCRIPTION to stay consistent in the meantime, but `document()`
is the source of truth and should produce the same result). Also worth
re-running the full `testthat` suite once more to confirm nothing broke.

## Consolidation pass: actor/gid measure functions (2026-07-10)

Nils chose the low-risk option: keep every exported function name and
signature exactly as-is (no breaking changes for anything that calls them),
and only remove the duplication internally.

Added `R/rebeltrack_measure_impl.R`: a shared `.rebeltrack_measure_impl()`
worker plus a `.simple_group()` helper. Every measure function now reduces
to stating what's actually different about it - the grouping column
("actor" or "priogrid_gid"), how to build the grouped data (usually just
`.simple_group()`, sometimes a custom multi-stage `make_group` for measures
that need an intermediate grouping step like transnational_ratio's
per-country counts before the per-actor ratio), the summarising expression,
and which lag engine/constructor pair to use.

`weighted_lag()`/`weighted_lag_gid()` were deliberately **not** merged into
this - they differ in a real way (gid weight matrices are handled as slam
sparse arrays, actor ones as plain dense arrays), and merging them wasn't
something this pass could safely verify without running R. They're passed
into `.rebeltrack_measure_impl()` as the `lag_engine` argument instead, so
the actor and gid code paths still end up calling the right one.

Refactored onto the shared engine (12 functions, all exported names and
behaviour unchanged): `rebeltrack_event_count`/`_gid`,
`rebeltrack_casualty_count`/`_gid`/`_gid_sideA`/`_gid_sideB`,
`rebeltrack_days_affected`/`_gid`, `rebeltrack_distance_to_border`/`_gid`,
`rebeltrack_distance_to_capital`/`_gid`, `rebeltrack_transnational_ratio`,
`rebeltrack_transnational_count`, `rebeltrack_national_ratio_gid`,
`rebeltrack_national_count_gid`, `rebeltrack_actors_present_gid`.

**Not touched in this pass** (different enough structurally that folding
them in risked more than it saved):
- `rebeltrack_dataframe`/`rebeltrack_dataframe_gid` - the panel
  *constructors*, not measures added onto an existing panel. Different
  shape (period completion via `tidyr::complete()`, balancing logic,
  updating the dataset) - a plausible separate consolidation target later,
  but deliberately out of scope here.
- `rebeltrack_grids_affected` - actor-only, no gid counterpart to pair with.
- `rebeltrack_adjacency_matrix`/`_gid` - already flagged as needing a
  rewrite rather than incremental changes; folding it into this pass would
  have made an already-risky file riskier.

**Verified (2026-07-10):** `devtools::document()` regenerated the Collate
directive and wrote docs for the two new internal helpers
(`.rebeltrack_measure_impl`, `.simple_group`) with no errors, and
`devtools::test()` came back `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 90 ]` -
identical to the pre-consolidation baseline. The consolidation is behaviour-
preserving as far as the existing test suite can confirm.

## `days_affected` semantics fixed (2026-07-10)

Asked Nils which way to resolve the "does this measure duration or just
event-start-days" ambiguity flagged in the audit. Answer: change the
behaviour to measure actual duration, not just leave the docs more honest
about the old behaviour.

Added `rebeltrack_count_days_affected(date_start, date_end)` to
`R/rebeltrack_utils.R`: expands every event's `[date_start, date_end]` span
into individual calendar days, takes the union across all events in the
group (so overlapping events aren't double-counted), and returns the count
of distinct days. `rebeltrack_days_affected()` and
`rebeltrack_days_affected_gid()` now call this instead of
`dplyr::n_distinct(date_start)`. This is a **behavioural change** - existing
numeric output from these two functions will differ (generally larger,
since a multi-day event now contributes more than one day) - not just an
internal refactor like everything else in this document.

Caveat carried over from the old version, documented explicitly this time:
neither the old nor new implementation clips an event's span to period
boundaries (the period string like "month" isn't available at this point in
the pipeline), so an event starting near the end of one period and
continuing into the next has all of its days counted against the period its
`date_start` falls in. Not new behaviour, just now written down.

Not covered by `tests/testthat/test_days_affected*.R` (those only check
column names/shape, not values) - worth a manual sanity check on real data
if this measure is used for anything analysis-critical.

**Follow-up: added a period-bounded sibling function (2026-07-10).** After
seeing the fix above, Nils asked for both variants rather than picking one:
the full-duration version just implemented (`rebeltrack_days_affected()`),
plus a second function that clips each event's span to the boundaries of
the period it's being aggregated into, so its value can never exceed the
period's own length.

Added `rebeltrack_count_days_ongoing_in_period(date_start, date_end,
period_start, period_end)` to `R/rebeltrack_utils.R` (same union-of-spans
logic as `rebeltrack_count_days_affected()`, but clips each event to
`[period_start, period_end]` first, and drops events that don't overlap the
period at all). New exported functions `rebeltrack_days_ongoing()` /
`rebeltrack_days_ongoing_gid()` (`R/rebeltrack_days_ongoing.R`,
`R/rebeltrack_gid_days_ongoing.R`) use it, via the same
`.rebeltrack_measure_impl()` engine as everything else - the only wrinkle is
that they need `period_end`, which lives on the built panel (`x@data`) but
not on `x@dataset@events`, so each function first builds a small
`period_start -> period_end` lookup from `as.data.frame(x)` and joins it
onto events inside a custom `make_group`, rather than using the
`.simple_group()` shortcut.

Naming: `rebeltrack_days_affected()` = total duration of every event
regardless of period boundaries (can exceed the period's length for a
long-running event). `rebeltrack_days_ongoing()` = days within *this*
period specifically that saw ongoing conflict (bounded by the period's own
length). Both have `_gid` counterparts.

Added `tests/testthat/test_days_ongoing.R` and `test_days_ongoing_gid.R`,
following the existing shape-check pattern plus one real value check this
time: `days_ongoing <= period length in days` for every row, which is a
correctness invariant the clipping logic should always satisfy.

**Verified (2026-07-10):** `devtools::document()` generated docs cleanly for
both new exported functions and the two new internal helpers, and
`devtools::test()` came back `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 122 ]` (90
previous + 16 each for the new `days_ongoing`/`days_ongoing_gid` test
files) - including the period-length invariant holding on real data.

## `rebeltrack_dataframe`/`rebeltrack_dataframe_gid` consolidation (2026-07-10)

Last remaining actor/gid duplication, done as its own pass right before
Step 3. Same approach as the measure-function consolidation: added
`.rebeltrack_dataframe_impl()` in `R/rebeltrack_dataframe_impl.R`
(parameterized by `group_col` and which S4 constructor to use), and both
`rebeltrack_dataframe()` and `rebeltrack_dataframe_gid()` are now thin
wrappers around it. No API changes - same exported names and signatures.

One behaviour preserved deliberately rather than "fixed": the shared impl
still unconditionally adds an `actor` column to `@events`, even when
building a gid-grouped panel (`group_col == "priogrid_gid"`) - this matches
what `rebeltrack_dataframe_gid()` already did before this refactor, since
some measure functions chained afterwards may read `actor` directly (e.g.
`weighted_lag()`'s per-actor lag step runs regardless of which panel type
called it). Not touched, just carried forward exactly.

Not yet verified by a test run - next step is `devtools::document()` and
`devtools::test()` again.

## Remaining findings, still deferred

Not touched by any pass so far - noted here so they're not lost:

- **Inconsistent casualty-count design.** Actor level is one function
  (`rebeltrack_casualty_count`) taking a `side` argument, called twice for
  A and B. Gid level is three separate functions (combined,
  `_sideA`, `_sideB`). Both now share the same internal engine (see above),
  but the public API shape is still inconsistent between the two levels -
  worth reconciling if/when an API-breaking pass is ever on the table.
- **`rebeltrack_gid_adjacency_matrix.R`** is noticeably messier than the
  rest of the package: commented-out code blocks, a `print(i)` debug line
  left in a loop, self-deprecating comments ("bodge", "naive iteration"),
  and dependencies on `matlab::meshgrid`/`slam::` for logic that might be
  simpler in base R or with `Matrix::`. Candidate for a rewrite rather than
  incremental fixes.
- One remaining superseded tidyverse pattern: `tidyr::spread()` in
  `rebeltrack_adjacency_matrix.R` (would modernize to `tidyr::pivot_wider()`
  if/when that function gets touched in the consolidation pass).
