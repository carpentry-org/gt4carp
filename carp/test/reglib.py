"""Shared driver for the regression suites in this directory.

Same protocol idiom as server_test.py: length-prefixed JSON over TCP
against an already-running server.

Tests marked expect_red=True encode an intended semantic contract that is
known to be violated today. They print `FAIL (known defect)` and do not
fail the run; the suite fails only when an anchor (unmarked test) breaks.
A red test that starts passing is reported so its marker can be removed.
Set REG_STRICT=1 to make open defects fail the exit code too.
"""
import json, os, socket, sys, uuid


class Server:
    def __init__(self, port, timeout=180):
        self.s = socket.create_connection(("127.0.0.1", port), timeout=timeout)
        self.f = self.s.makefile("rwb")
        self.n = 0

    def rpc(self, obj):
        self.n += 1
        obj = dict(obj)
        obj["id"] = self.n
        body = json.dumps(obj).encode()
        self.f.write(str(len(body)).encode() + b"\n" + body)
        self.f.flush()
        n = int(self.f.readline().strip())
        return json.loads(self.f.read(n))

    def ev(self, session, source):
        return self.rpc({"cmd": "eval", "session": session, "source": source})


def sid(tag):
    # fresh session per run: the protocol has no session lifecycle beyond
    # reset, so a re-run against a long-lived server must not inherit state
    return "%s-%s" % (tag, uuid.uuid4().hex[:8])


results = []


def check(name, got, pred, expect_red=False):
    try:
        ok = pred(got)
    except Exception as e:
        ok = False
        got = "exception: %r (on %s)" % (e, json.dumps(got)[:120])
    tag = "PASS" if ok else ("FAIL (known defect)" if expect_red else "FAIL")
    shown = got if isinstance(got, str) else json.dumps(got)
    print(tag, name, "->", shown[:200], flush=True)
    results.append((name, ok, expect_red))
    return ok


def finish():
    broken = [n for n, ok, red in results if not ok and not red]
    open_defects = [n for n, ok, red in results if not ok and red]
    fixed = [n for n, ok, red in results if ok and red]
    print("anchors broken:", broken or "none", file=sys.stderr)
    print("defects still open: %d" % len(open_defects), file=sys.stderr)
    if fixed:
        print("defects now FIXED, remove expect_red:", fixed, file=sys.stderr)
    strict = os.environ.get("REG_STRICT") == "1"
    sys.exit(1 if (broken or (strict and open_defects)) else 0)
