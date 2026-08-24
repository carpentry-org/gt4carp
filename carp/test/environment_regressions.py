"""Regressions for environment coherence and macro environments.

Cause E — answer provenance. A session's answers come from several
environments (warm base, warm overlay, CLI pipeline, host program) and
nothing marks which one answered. Contract: within one session the query
surfaces agree on whether a binding exists — if eval succeeds using it,
completion offers it and annotate does not call it unknown.
  E1 runs against a deliberately degraded server (CARP_LIB_CACHE pointing
  nowhere): warm state that is missing, tainted or degraded routes
  annotate and completion through the CLI pipeline, which loads the
  notebook runtime the way the eval paths do — the same world, a compile
  slower. The test asserts coherence, not a direction, so it stays valid
  if the policy ever becomes refusal instead. E2 anchors the healthy
  case; ping's warm field says when the degraded routing is in force.

Cause F — macro environments. Contract: Evaluate, expand, expand-1 and
the DAP adapter expand a macro against the same session environment.
  F1 expand-1 sees a macro defined earlier in the same source, the way
     expand (F2) and Evaluate do: metacarp's expand-module-1-against seeds
     transient compile-time definitions in source order. Needs a server
     built against carp-compiler with that fix.
  F3 expand answers changed:false when nothing expanded — changed means
     progressed, whatever the expander says.
  F4 anchors expand-1 on a committed macro.
  F5 a macro committed to a session must be visible when debugging that
     session's snippet. CONTRACT-PENDING: the DAP launch request carries
     no session today (the adapter is a separate process with a private
     session), so adopting this contract is a product decision; the test
     already sends a session argument for the day it is honored.
  F6 anchors that the adapter records steps for a same-cell macro.

Run: python3 environment_regressions.py <healthy-port> <degraded-port> <dap-port>
"""
import json, socket, sys, time

from reglib import Server, check, finish, sid

healthy = Server(int(sys.argv[1]))
degraded = Server(int(sys.argv[2]))
dap_port = int(sys.argv[3])

# --- Cause E: environment coherence --------------------------------------


def coherence(server, session):
    "eval / annotate / completion agreement on NB, as (eval, annotate, complete)."
    e = server.ev(session, '(NB.cap @"hello")')
    a = server.rpc({"cmd": "annotate", "session": session,
                    "source": '(NB.cap @"hello")'})
    c = server.rpc({"cmd": "complete", "session": session, "prefix": "NB."})
    return (e.get("ok", {}).get("exit") == 0,
            "ok" in a and a["ok"].get("diagnostics") == [],
            len(c.get("ok", {}).get("candidates", [])) > 0)


S = sid("envh")
healthy.ev(S, '(defn uses-nb [] (NB.cap @"xy"))')
check("E2 healthy server: eval, annotate and completion agree on NB",
      coherence(healthy, S),
      lambda t: t == (True, True, True))

S = sid("envd")
degraded.ev(S, '(defn uses-nb [] (NB.cap @"xy"))')
check("E1 degraded server: eval, annotate and completion still agree",
      coherence(degraded, S),
      lambda t: t[0] == t[1] == t[2])

# --- Cause F: macro environments -----------------------------------------

S = sid("mx")
same_cell = "(defmacro th3 [x] (list (quote do) x x x))\n(th3 9)"
check("F1 expand-1 sees a macro defined earlier in the same source",
      healthy.rpc({"cmd": "expand-1", "session": S, "source": same_cell}),
      lambda r: r["ok"]["changed"] is True)
check("F2 expand sees a macro defined earlier in the same source",
      healthy.rpc({"cmd": "expand", "session": S, "source": same_cell}),
      lambda r: r["ok"]["changed"] is True and "(do 9 9 9)" in r["ok"]["expansion"])

check("F3 expand answers changed:false when nothing expanded",
      healthy.rpc({"cmd": "expand", "session": sid("mx2"),
                   "source": "(no-such-macro 2)"}),
      lambda r: r["ok"]["changed"] is False)

S = sid("mx3")
healthy.ev(S, "(defmacro twc [x] (list (quote +) x x))")
check("F4 expand-1 sees a committed macro",
      healthy.rpc({"cmd": "expand-1", "session": S, "source": "(twc 3)"}),
      lambda r: r["ok"]["changed"] is True and "(+ 3 3)" in r["ok"]["expansion"])


# --- minimal DAP client ---------------------------------------------------


class Dap:
    def __init__(self, port, tries=30):
        for i in range(tries):
            try:
                self.s = socket.create_connection(("127.0.0.1", port), timeout=60)
                break
            except OSError:
                if i == tries - 1:
                    raise
                time.sleep(1)
        self.buf = b""
        self.seq = 0

    def send(self, command, arguments=None):
        self.seq += 1
        m = {"seq": self.seq, "type": "request", "command": command}
        if arguments is not None:
            m["arguments"] = arguments
        b = json.dumps(m).encode()
        self.s.sendall(b"Content-Length: %d\r\n\r\n" % len(b) + b)

    def read(self):
        while b"\r\n\r\n" not in self.buf:
            self.buf += self.s.recv(65536)
        head, rest = self.buf.split(b"\r\n\r\n", 1)
        n = int([l for l in head.split(b"\r\n")
                 if l.lower().startswith(b"content-length")][0].split(b":")[1])
        while len(rest) < n:
            rest += self.s.recv(65536)
        self.buf = rest[n:]
        return json.loads(rest[:n])

    def launch_steps(self, source, session=None):
        "launches and answers the recorded step count from the console event"
        args = {"source": source}
        if session is not None:
            args["session"] = session
        self.send("launch", args)
        steps = None
        for _ in range(10):
            m = self.read()
            if m.get("type") == "event" and m.get("event") == "output":
                text = m.get("body", {}).get("output", "")
                if "compile-time steps recorded" in text:
                    steps = int(text.split()[0])
            if m.get("type") == "event" and m.get("event") == "stopped":
                return steps
        return steps


dap = Dap(dap_port)
dap.send("initialize", {"adapterID": "regression"})
while True:
    m = dap.read()
    if m.get("type") == "event" and m.get("event") == "initialized":
        break

check("F6 adapter records steps for a same-cell macro",
      dap.launch_steps("(defmacro twl [x] (list (quote *) x x))\n(twl 4)"),
      lambda steps: steps is not None and steps > 0)

check("F5 adapter sees a macro committed to the launching session",
      dap.launch_steps("(twc 2)", session=S),
      lambda steps: steps is not None and steps > 0,
      expect_red=True)

dap.send("disconnect", {})

finish()
