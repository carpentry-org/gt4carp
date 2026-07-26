import json, socket, sys

PORT = int(sys.argv[1])

s = socket.create_connection(("127.0.0.1", PORT), timeout=60)
f = s.makefile("rwb")

def rpc(obj):
    body = json.dumps(obj).encode()
    f.write(str(len(body)).encode() + b"\n" + body)
    f.flush()
    n = int(f.readline().strip())
    return json.loads(f.read(n))

def check(name, got, pred):
    ok = pred(got)
    print(("PASS" if ok else "FAIL"), name, "->", json.dumps(got)[:200])
    return ok

results = []
results.append(check("ping", rpc({"id": 1, "cmd": "ping"}),
                     lambda r: r.get("ok") == "pong"))
results.append(check("def cell", rpc({"id": 2, "cmd": "eval", "session": "p1",
                                      "source": "(defn square [x] (* x x))"}),
                     lambda r: r["ok"]["exit"] == 0))
results.append(check("expr cell", rpc({"id": 3, "cmd": "eval", "session": "p1",
                                       "source": "(square 12)"}),
                     lambda r: r["ok"]["exit"] == 0 and r["ok"]["value"] == "144" and r["ok"]["stdout"] == ""))
results.append(check("redefine", rpc({"id": 4, "cmd": "eval", "session": "p1",
                                      "source": "(defn square [x] (* x (* x x)))"}),
                     lambda r: r["ok"]["exit"] == 0))
results.append(check("uses redef", rpc({"id": 5, "cmd": "eval", "session": "p1",
                                        "source": "(square 3)"}),
                     lambda r: r["ok"]["exit"] == 0 and r["ok"]["value"] == "27"))
results.append(check("expr not persisted", rpc({"id": 6, "cmd": "eval", "session": "p1",
                                                "source": "(square 2)"}),
                     lambda r: r["ok"]["exit"] == 0 and r["ok"]["value"] == "8"))
results.append(check("error cell", rpc({"id": 7, "cmd": "eval", "session": "p1",
                                        "source": "(nonexistent-fn 1)"}),
                     lambda r: r["ok"]["exit"] != 0 and len(r["ok"]["stderr"]) > 0))
results.append(check("session survives error", rpc({"id": 8, "cmd": "eval", "session": "p1",
                                                    "source": "(square 4)"}),
                     lambda r: r["ok"]["exit"] == 0 and r["ok"]["value"] == "64"))
results.append(check("second session isolated", rpc({"id": 9, "cmd": "eval", "session": "p2",
                                                     "source": "(square 4)"}),
                     lambda r: r["ok"]["exit"] != 0))
results.append(check("reset", rpc({"id": 10, "cmd": "reset", "session": "p1"}),
                     lambda r: r.get("ok") == "reset"))
results.append(check("reset cleared defs", rpc({"id": 11, "cmd": "eval", "session": "p1",
                                                "source": "(square 4)"}),
                     lambda r: r["ok"]["exit"] != 0))

results.append(check("prints split from value", rpc({"id": 12, "cmd": "eval", "session": "p3",
                                       "source": "(defn shout [] (do (println* \"hey\") 5))\n(shout)"}),
                     lambda r: r["ok"]["value"] == "5" and "hey" in r["ok"]["stdout"]))

results.append(check("host value", rpc({"id": 20, "cmd": "eval", "session": "h1",
                                        "source": "(defn nums [] [10 20 30])\n(nums)"}),
                     lambda r: r["ok"]["exit"] == 0 and r["ok"]["hasValue"] and r["ok"]["value"] == "(3 items)" and r["ok"]["hostPort"] > 0))

import urllib.request
hp = rpc({"id": 21, "cmd": "eval", "session": "h1", "source": "(nums)"})["ok"]["hostPort"]
def hget(path):
    return json.loads(urllib.request.urlopen("http://127.0.0.1:%d%s" % (hp, path), timeout=10).read())
results.append(check("phlow object", hget("/objects/0"),
                     lambda r: r["object_type"] == "Array" and r["print_string"] == "(3 items)"))
results.append(check("phlow views", hget("/objects/0/views"),
                     lambda r: r[0]["viewName"] == "GtPhlowListViewSpecification" and r[0]["methodSelector"] == "gtItemsFor"))
items = hget("/objects/0/views/gtItemsFor/items")
results.append(check("phlow items", items,
                     lambda r: len(r) == 3 and r[1]["nodeValue"]["itemText"] == "20" and r[1]["phlowObject"]["object_type"] == "Int"))
results.append(check("phlow send", hget("/objects/0/views/gtItemsFor/send/%d" % items[2]["phlowObject"]["id"]),
                     lambda r: r["print_string"] == "30"))
results.append(check("def cell no host", rpc({"id": 26, "cmd": "eval", "session": "h2",
                                              "source": "(defn g [] 1)"}),
                     lambda r: r["ok"]["exit"] == 0 and not r["ok"]["hasValue"]))
results.append(check("reset kills host", rpc({"id": 27, "cmd": "reset", "session": "h1"}),
                     lambda r: r.get("ok") == "reset"))
def host_dead():
    try:
        hget("/session"); return False
    except Exception:
        return True
import time; time.sleep(0.5)
results.append(check("host gone after reset", {"dead": host_dead()}, lambda r: r["dead"]))

print("ALL PASS" if all(results) else "FAILURES", file=sys.stderr)
sys.exit(0 if all(results) else 1)
