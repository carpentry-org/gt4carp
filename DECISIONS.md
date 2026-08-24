# Decisions

Open product decisions the code deliberately does not make. Each entry says
what is undecided, what the options cost, and what to find out next.
Companion to INVARIANTS.md, which maps what the code does enforce.

## Module reopening in notebook sessions

Reproducer: evaluate `(defmodule M (defn a [] 1))` in one cell and
`(defmodule M (defn b [] 2))` in the next; `(M.a)` then fails with
"unknown binding M.a; did you mean M.b?".

Every compiler layer treats modules as open. Reference Carp and metacarp
batch both compile the two forms in one file and answer 3 for
`(+ (M.a) (M.b))`; carp-session merges reopenings committed as distinct
inputs (both names complete, the sum annotates clean). Only absorption
loses the first one, because it treats a defmodule form as a single
name-keyed binding and the second cell replaces the first.

Three options:

1. **Replace** (today): re-evaluating an edited module cell behaves
   correctly; reopening from another cell silently destroys the first
   body.
2. **Union per qualified name**: absorb a defmodule's contents as entries
   for `M.a`, `M.b`, … — matches all three compiler layers, keeps
   replace-on-re-eval for each member, needs no protocol change. Its cost
   is the deletion ambiguity: when the user re-evaluates a module cell
   with a member removed, "this cell no longer defines M.a" is
   indistinguishable from "M.a came from some other cell", so deleted
   members would live on as ghosts. Top-level absorption already has
   exactly this ambiguity (renaming a defn leaves the old name defined),
   so union would make modules consistent with the rest of the session —
   wrong in the same direction, rather than wrong in a different one.
3. **Cell identity in the protocol**: the only option correct in both
   directions — replace what this cell used to define, keep what other
   cells defined. A protocol and product change, not a bugfix.

Held until the cell-identity decision below. If that decision stalls,
option 2 is the defensible interim; whichever way it goes, pin it with a
characterization test the way A4 pins rename ghosts.

## Fix order for the remaining decisions

Investigation order, not code. Each item names the question to answer
next, and what it unblocks.

1. **Cell identity in the eval protocol.** The root decision: settles
   rename ghosts (test A4), module reopening and its deletion ambiguity,
   and gives diagnostics a cell to blame. Investigate: Lepiter already
   has snippet uids (the page uid is the session — the snippet uid could
   ride along); what "cell deleted" should mean for its definitions; how
   replay order behaves when an early cell is re-evaluated.
2. **Expose removal in the protocol.** carp-session's `remove` and
   `remove-input` exist and are unexposed; any cell-identity design needs
   them, and a "forget this name" escape hatch is useful on its own.
   Investigate: reconciliation when a removed name is still referenced by
   later entries.
3. **Module reopening.** Decide after 1 (or adopt option 2 above as the
   interim); then pin.
4. **DAP session sharing (F5).** The adapter is a separate process with a
   private session, so a debugged snippet cannot see page macros.
   Investigate two shapes: the launch request carries a session id and
   the adapter mirrors that session's entries, versus GT composing the
   session's text into the launch source. The second needs no state
   sharing and may be a one-line client change; check what it does to
   step positions and per-launch source files first.
5. **meta-set! documentation keys (B4).** carp-session's document
   collector reads only `doc` forms. Decide which meta keys the session
   serves (doc alone, or sig and example too), then teach
   `collect-documents-node!` to read `meta-set!`.
6. **Client-side degradation surfacing.** The server now says
   `warm: degraded` in ping and logs every fallback, and GT still nulls
   the server's stderr and ignores the field. Decide where the indicator
   lives — the snippet label already shows the server address — before
   wiring anything.

Implementation-only, no decision needed, listed for order: the one-step
deftype-members parity gap (INVARIANTS.md §2) — fold
`register-deftype-members!` into one-step seeding next time carp-expand
is open.
