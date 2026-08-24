"""Regressions for the value/stdout split (server.carp: respond-run).

Cause D — every path that runs a compiled cell to completion answers the
last line of stdout as the cell's value, so on fallback routes a print
becomes the value of a unit-valued expression, and multi-line values only
survive on the host path.

Contract: `value` holds the printed representation of the cell's result
and nothing else; program output stays whole in `stdout`, on every route;
a unit-valued cell has no value. Fix: implementation, plus one emission
decision — the echoed result must be separable from program output (a
sentinel between run output and echo, or no echo for unit, chosen where
the program is emitted).

D1 deliberately includes a nested defn so the cell cannot be hosted and
takes the fallback route today; the contract does not depend on which
route runs it. D2/D3 anchor the host path and definition cells.

D4 runs against a server started without a notebook library (a second
port, optional): expression cells must still execute there — a cell that
only type-checks must not report an execution that never happened. The
library-less route cannot mark a value, so it claims none; the run's
output, echo included, stays in stdout.

Run: python3 value_channel_regressions.py <port> [no-nb-lib-port]
"""
import sys

from reglib import Server, check, finish, sid

srv = Server(int(sys.argv[1]))

r = srv.ev(sid("unit"), '(do (defn ffr [] 1) (IO.println "l1") (IO.println "l2"))')
check("D1 program output is not answered as the value of a unit cell",
      r,
      lambda r: r["ok"]["exit"] == 0
      and r["ok"]["value"] == ""
      and "l1" in r["ok"]["stdout"]
      and "l2" in r["ok"]["stdout"])

check("D2 host path keeps a multi-line value whole",
      srv.ev(sid("ml"), '@"a\\nb"'),
      lambda r: r["ok"]["exit"] == 0 and r["ok"]["hasValue"]
      and r["ok"]["value"] == "a\nb")

check("D3 definition cell answers no value and no host",
      srv.ev(sid("defonly"), '(defn reg-d3 [] 1)'),
      lambda r: r["ok"]["exit"] == 0 and not r["ok"]["hasValue"]
      and r["ok"]["value"] == "")

if len(sys.argv) > 2:
    nonb = Server(int(sys.argv[2]))
    check("D4 expression cells execute without a notebook library",
          nonb.ev(sid("nonb"), '(do (IO.println "ran") 42)'),
          lambda r: r["ok"]["exit"] == 0 and "ran" in r["ok"]["stdout"])

finish()
