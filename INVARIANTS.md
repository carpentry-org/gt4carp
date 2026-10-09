# Invariants

A map of the agreements between gt4carp's subsystems that nothing enforces
structurally: what each boundary assumes, where the assumption lives on
each side, what happens when it drifts, and which regression test (in
`carp/test/`) watches it. Where the Test column says none, drift is
currently detected by nothing.

The subsystems: **GT** (the Pharo/Smalltalk packages), the **server**
(`carp/src/server.carp`), **metacarp** (the self-hosting compiler and its
`carp-session` library), the **DAP adapter** (the same server binary in
`--dap` mode, a separate process), **value hosts** (compiled cell programs
kept alive, `carp/src/notebook.carp`), **lldb-dap** (the native debugger's
adapter), and **disk** (session work dirs and project files).

## 1. Copied compiler knowledge

Facts that metacarp owns and gt4carp restates. Every row is a silent
failure when it drifts; none had a test before the regression suite, and
most still have none because they need the GT image or a native debug run.

| Fact | Authoritative | Copies | Drift symptom | Test |
|---|---|---|---|---|
| C symbol mangling `C<n>_name__<type>`, `L<n>_name_<id>`, `_x<code>_` escapes | `carp-c-abi/carp-c-abi.carp` (`CAbi.mangle`) | `CarpNativeDebugger` (`carpMainSymbol` = `C4_main__F0_Z1_U`, `decodeCarpName:`, `hidesVariable:`) | native debugger stops in `_dyld_start` or `main`, frame and variable names come out mangled | none (needs image + lldb) |
| git library cache layout `~/.cache/carp/libs/<host>_COLON_<owner>/…` | metacarp `main.carp` load resolution | server `Project.cache-path`, `HostBase.lib-cache` | project browser silently drops dependency files; warm base fails and everything falls back to cold compiles | E1 catches the warm-base half indirectly |
| boot prelude (host facts, Project stub, include macros) | `carp-session/carp-core-loader.carp` (private) | server `HostBase.boot-prelude` (a declared copy) | warm base fails to build, or warm and cold answer from subtly different compile-time environments | E1/E2 |
| runtime pins `socket@0.2.3`, `bufio@0.1.0` | pinned twice inside this repo: `notebook.carp` loads and `HostBase` cache paths | the two must match each other and the cache layout | warm base silently incomplete after a version bump | E1/E2 |
| diagnostic phase names (`parse expand resolve infer validate`) | metacarp `CompileError.phase` values | server `cell-fault?` whitelist | a renamed or added front-end phase turns real cell errors into pointless cold retries, or infrastructure failures into cell blame | none |
| which heads run at top level vs define | metacarp's evaluation of top-level forms | server `Cell.def-heads` and `CarpNativeDebugger class>>definitionHeads` (verified identical; the one hard-coupled pair) | absorption misclassifies cells; the native debugger's entry line lands inside a definition | A-group covers the absorption side |
| `#line` emission into the composed `cell.carp` (relative path) and core files (absolute) | metacarp `-g` codegen | native debugger's generated-code skipping, `framesCarryColumns == false`, form-extent recovery | debugger degrades to stopping in C, columns point into the wrong text | none (needs image) |

Note the head lists that are *not* copies: `Project.binding-heads`,
`annotation-heads`, `load-heads`, `config-heads` and the browser's kind
table classify deliberately different subsets for different questions.
Only `Cell.def-heads` and `definitionHeads` must stay identical.

## 2. Answer provenance

Every answer comes from one of several environments, and no response
field says which. The environments:

- **warm base** — core (+ socket + notebook runtime when the cache
  resolves; a whole project for project sessions), built once per session,
  silently replaced by bare core when its sources cannot be read.
- **warm overlay** — definitions mirrored by absorption; a failed mirror
  taints it, and taint routes queries to the CLI paths.
- **CLI pipeline** — a full compiler run over replayed session text; adds
  the notebook prelude on eval paths but not on the annotate/ownership
  paths.
- **host program** — the compiled cell itself, serving its live result.
- **DAP adapter** — a separate process with a private `"dap"` session that
  never sees notebook or project sessions.

Who answers what: eval answers from CLI+notebook or warm emission or the
host; annotate/complete/doc/expand answer from warm state even when it is
tainted or degraded; the DAP adapter answers only from itself.

**Invariant to preserve: surfaces of one session agree on what exists.**
If eval succeeds using a binding, completion offers it and annotate does
not call it unknown (tests E1/E2). Enforced by routing: warm state that is
missing, tainted or degraded sends annotate and completion through the
CLI pipeline, which loads the notebook runtime the way the eval paths do —
slower by a compile, but the same world. A session that holds loads or
build flags is tainted on purpose (the mirror cannot hold their meaning),
so its queries pay the CLI price; that latency is the accepted cost of
never answering from a smaller world than the runs use. Corollary kept by
tests F1–F6: the macro tools should see the same macro environment.
Evaluate, expand and expand-1 now do — metacarp's expand-module-1-against
seeds transient compile-time definitions in source order, pinned by a
carp-session test of its own — so the one remaining gap is the DAP
adapter, which misses committed macros because its launch carries no
session (a product decision).

One-step seeding covers defmacro, defndynamic, defdynamic and deftype
members, the same transient definitions full expansion registers, so a
macro that reads `(members T)` for a deftype in the same cell expands
step-wise too (pinned by carp-session's one-step test).

Degradation is visible in-band: `ping` answers `warm: degraded` once a
base build has failed, and the server still logs the cause to stderr —
which GT currently discards (`startServer` nulls stdout/stderr).

## 3. Identity

- **Sessions** are bare strings minted in three places: page uid
  (base36), `project:<root>`, `default`; the DAP adapter hardcodes its
  own `dap`. Nothing namespaces them across GT images sharing a server.
- **Definitions**: the session identifies an absorbed form by what it
  establishes — a binding by its name alone (so redefinition under
  another head replaces instead of conflicting), an annotation by what it
  says about whom (`implements`/`derive` keep both symbols so two about
  one subject coexist), a load or flag by its target string. Annotations
  live inside their target's entry and travel with it into the warm
  mirror as one input, which is what lets carp-session pair a doc with
  its definition (tests A1–A3, B1–B2). GT's `moduleName` parsing of
  qualified names is still a third, independent reading.
- **Cells have no identity at all.** The protocol carries only source, so
  the server cannot distinguish an edited cell from a new one; renames
  leave ghosts (characterization test A4) and diagnostics cannot be
  blamed on the cell that introduced a conflict. Giving cells identity is
  a protocol/product decision, not a bugfix.
- **Values** are (host port, object id), authenticated only at the
  server's launch handshake; reads on a host carry no token (only DELETE
  is checked), while ports recycle mod 500 and any new eval kills the
  session's previous host. `CarpValueClient` therefore re-reads
  `GET /session` before every read and refuses one whose token is not the
  one it connected to.
- **The server binary** identifies itself by build stamp (`--stamp` vs
  ping); GT checks once per client instance.

## 4. Source coordinates

- The universal currency is **UTF-8 byte offsets, half-open, in file or
  cell coordinates**. The compiler reports them; GT crosses to character
  positions in exactly one place (`CarpStylerUtilities
  charPositionsByByteOffsetIn:`); files are edited byte-wise
  (`CarpProjectFile byteSliceFrom:to:`, `replaceBytesFrom:to:with:`).
- The server preserves file coordinates through semantic filtering by
  **blanking spans with spaces, never deleting** (`Project.blank-span!`).
  Do not "clean up" the blanking: definition spans are file coordinates
  because of it.
- **Two diagnostic coordinate systems coexist**: annotate carries
  cell-relative byte spans; eval stderr carries composed-program
  line/column prose (a one-line cell can be blamed at "line 7"). The CLI
  annotate path — routine now for tainted or degraded sessions — emits
  span-less local rows (the editor anchors them by walking its own parse
  tree; a future compiler that adds spans gets them rebased to cell
  bytes) and still no diagnostics: a cell that fails to compile there
  answers a protocol error, which the editor renders as no marks at all.
- **Project definition spans are read at project-load time and trusted at
  save time.** `CarpProjectFile` remembers the file's stamp from when its
  spans were last true, and `replaceBytesFrom:` refuses to write when the
  stamp, or the cached bytes, no longer match disk (the stamp resolves
  only to the second). Every write path goes through it; keep it that way.
  Pinned by `CarpProjectExamples>>#savingRefusesAFileChangedOnDisk`; the
  window between the server reading a file and GT stamping it is not
  covered.
- Debug builds map C to Carp via `#line` with a *relative* `cell.carp`
  path — resolvable because the binary is built in the session dir; a
  debugger launched with another cwd loses the mapping.
- Line endings: every command that carries source normalizes it at intake
  (`get-source` applies `Cell.unix-newlines` in one place; the debug
  paths already did). Spans in any answer are offsets into the normalized
  text — byte-identical to the client's text for CR-delimited senders,
  shifted for CRLF senders, which no known client is (test C1; Lepiter
  stores CR-delimited snippet text).

## 5. Session and environment synchronization

- Absorption and the warm mirror must stay in step: `Warm.absorb!` runs
  after `Session.absorb!` and re-commits every binding entry the cell
  touched — by definition or by annotation — as one whole input through
  `Session.upsert-input`. A failed mirror upsert taints warm state, and
  entries the mirror cannot hold (loads, flags, `use`) taint it by
  construction, which routes that session's queries to the CLI. Anything
  that changes absorption must keep the mirror's view either complete or
  tainted — never silently partial.
- **Sessions are replayed source text.** Definition initializers run
  inside every later evaluation, not at definition time; their output is
  attributed to whatever cell runs next (test D-group covers the value
  half). This is the deliberate model, not a bug; do not add caching that
  assumes initializers ran once.
- Absorbed cells are split into one input per form, which is what breaks
  doc pairing (tests B1–B4); carp-session's `upsert-input` (whole-input
  identity, used by the project paths, where docs work) is the intended
  alternative, and `Session.remove`/`remove-input` exist but are not
  exposed by the protocol — which is why a poisoned session has no repair
  short of reset (test A3).
- Project sessions: file stamps (`noteSessionSaw:`) decide which files to
  re-commit on refresh; disk is written before the session is told
  (`save:` then `commit`), so git, disk and session converge — but see
  the span-staleness invariant above.
- Value host lifecycle: each eval kills the session's previous host; the
  server start kills **every** host on the machine (intended orphan
  cleanup under a one-server-per-machine assumption — any second server,
  including a test runner's, is a kill-all; `run_regressions.sh` warns).
  Host ports allocate sequentially mod 500 above `port+100`; the native
  debugger draws lldb-dap ports from the 500 above that range, so the two
  must move together.
- GT-side caches that can serve stale answers: the per-name documentation
  cache (dropped whenever the session changes through the client, by
  `CarpServerClient>>#epochOf:`; a change made by another client goes
  unseen), the lint cache
  (by source hash, safe), the type-annotation cache (by source hash, safe;
  failure hashes suppress retries), remote-value element caches (retained
  after their host dies).

## 6. Disk state as protocol

The session work dir is an IPC surface, not scratch: `cell.carp`,
`stdout.log`, `stderr.log`, `exit.code`, `run-exit.code`, `warm.log`,
`cell-warm.c`, `cell-host`, `cell-debug(.c)`, `salt` are written and read
across process boundaries with no locking; correctness rests on the
server serializing requests per session. `dap-cell-<n>.carp` files are
append-only on purpose — earlier debuggers keep pointing at true text —
and must never be rewritten in place.
