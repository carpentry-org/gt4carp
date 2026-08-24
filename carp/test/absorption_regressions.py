"""Regressions for session absorption (server.carp: Session.absorb!, Cell).

Cause A — definition identity. Contract: a form's identity is what it
establishes, and absorbing a successful cell never silently destroys an
unrelated prior definition. (These were red while forms were keyed by
`head:second-symbol` text, which collided across implements forms, loads
and cross-head redefinition.)
  A1  implements: two implementations of one interface both persist.
      A1b and A5 anchor the second implementation and the compiler
      accepting multiple implementations inside one cell.
  A2  load: two load forms both persist.
  A3  cross-head redefinition: re-evaluating a definition can always
      repair a session — a binding replaces the binding of its name
      whatever the head. Full edit-replaces-cell semantics would still
      need cell identity in the protocol, which is a product decision.
  A4  rename ghost: CHARACTERIZATION, not a contract. With no cell
      identity, keeping the old name is consistent accumulate semantics.
      This pins today's behavior so a change to it is deliberate; if cell
      identity is ever added, flip this test.

Cause B — absorption granularity. Contract: documentation written in a
notebook cell is served by the doc command, as for project files and core;
annotations travel inside their target's entry, so the warm mirror sees
definition and documentation as one input. B4 (meta-set!) stays red until
carp-session's document collector reads meta-set! forms — and a decision
about which meta keys the session serves.

Cause C — input normalization. Contract: a cell means the same program
whatever its line endings; every command that carries source normalizes it
at intake (get-source), the way the debug paths always did.

Run: python3 absorption_regressions.py <port>
"""
import shutil, sys, tempfile

from reglib import Server, check, finish, sid

srv = Server(int(sys.argv[1]))

# --- Cause A: definition identity ---------------------------------------

S = sid("iface")
srv.ev(S, '(definterface fancy (Fn [a] String))')
srv.ev(S, '(defn fancy-int [i] (str (Int.inc i)))\n(implements fancy fancy-int)')
srv.ev(S, '(defn fancy-bool [b] (if b @"yes" @"no"))\n(implements fancy fancy-bool)')
check("A1 both interface implementations persist",
      srv.ev(S, '(fancy 1)'),
      lambda r: r["ok"]["exit"] == 0 and r["ok"]["value"] == "2")
check("A1b latest implementation persists",
      srv.ev(S, '(fancy true)'),
      lambda r: r["ok"]["exit"] == 0 and r["ok"]["value"] == "yes")

check("A5 metacarp accepts multiple implementations in one cell",
      srv.ev(sid("ifone"),
             '(definterface gg (Fn [a] String))\n'
             '(defn gi [i] (str (Int.inc i)))\n(implements gg gi)\n'
             '(defn gb [b] (if b @"yes" @"no"))\n(implements gg gb)\n'
             '(String.append &(gg 1) &(gg true))'),
      lambda r: r["ok"]["exit"] == 0 and r["ok"]["value"] == "2yes")

loads = tempfile.mkdtemp(prefix="carp-reg-loads-")
open(loads + "/a.carp", "w").write("(defn reg-a-fn [] 1)\n")
open(loads + "/b.carp", "w").write("(defn reg-b-fn [] 2)\n")
S = sid("load")
srv.ev(S, '(load "%s/a.carp")' % loads)
srv.ev(S, '(load "%s/b.carp")' % loads)
check("A2 first load persists beside a second",
      srv.ev(S, '(reg-a-fn)'),
      lambda r: r["ok"]["exit"] == 0 and r["ok"]["value"] == "1")
check("A2b second load persists",
      srv.ev(S, '(reg-b-fn)'),
      lambda r: r["ok"]["exit"] == 0 and r["ok"]["value"] == "2")
shutil.rmtree(loads, ignore_errors=True)

S = sid("xhead")
srv.ev(S, '(defn conv [] 1)')
srv.ev(S, '(def conv 2)')
srv.ev(S, '(defn conv [] 3)')
check("A3 re-evaluating a definition repairs the session",
      srv.ev(S, '(conv)'),
      lambda r: r["ok"]["exit"] == 0 and r["ok"]["value"] == "3")

S = sid("ghost")
srv.ev(S, '(defn old-name [] 11)')
srv.ev(S, '(defn new-name [] 22)')
check("A4 CHARACTERIZATION: prior definition survives an apparent rename",
      srv.ev(S, '(old-name)'),
      lambda r: r["ok"]["exit"] == 0 and r["ok"]["value"] == "11")

# --- Cause B: doc pairing across absorption ------------------------------

S = sid("docs")
srv.ev(S, '(doc mfd "inline doc")\n(defn mfd [] 1)')
check("B1 same-cell doc served by the doc command",
      srv.rpc({"cmd": "doc", "session": S, "name": "mfd"}),
      lambda r: r.get("ok", {}).get("documentation") == "inline doc")

S = sid("docs2")
srv.ev(S, '(defn mfe [] 1)')
srv.ev(S, '(doc mfe "later doc")')
check("B2 cross-cell doc served by the doc command",
      srv.rpc({"cmd": "doc", "session": S, "name": "mfe"}),
      lambda r: r.get("ok", {}).get("documentation") == "later doc")

S = sid("docs3")
srv.ev(S, '(defn mfm [] 1)')
srv.ev(S, '(meta-set! mfm "doc" "meta doc")')
check("B4 meta-set! doc served by the doc command",
      srv.rpc({"cmd": "doc", "session": S, "name": "mfm"}),
      lambda r: r.get("ok", {}).get("documentation") == "meta doc",
      expect_red=True)

check("B3 core documentation still served",
      srv.rpc({"cmd": "doc", "session": sid("docs4"), "name": "Int.inc"}),
      lambda r: "increments" in r.get("ok", {}).get("documentation", ""))

# --- Cause C: line-ending normalization ----------------------------------

check("C1 CR-delimited cell with a comment evaluates",
      srv.ev(sid("cr"), '; note\r(+ 40 2)'),
      lambda r: r["ok"]["exit"] == 0 and r["ok"]["value"] == "42")

finish()
