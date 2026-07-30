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
                     lambda r: r["ok"]["exit"] == 0 and r["ok"]["hasValue"] and r["ok"]["value"] == "[10 20 30]" and r["ok"]["hostPort"] > 0))

import urllib.request
hp = rpc({"id": 21, "cmd": "eval", "session": "h1", "source": "(nums)"})["ok"]["hostPort"]
def hget(path):
    return json.loads(urllib.request.urlopen("http://127.0.0.1:%d%s" % (hp, path), timeout=10).read())
results.append(check("phlow object", hget("/objects/0"),
                     lambda r: r["object_type"] == "Array" and r["print_string"] == "[10 20 30]"))
results.append(check("phlow views", hget("/objects/0/views"),
                     lambda r: r[0]["viewName"] == "GtPhlowColumnedListViewSpecification"
                               and r[0]["methodSelector"] == "array-items"
                               and [c["title"] for c in r[0]["columnSpecifications"]] == ["#", "Value"]))
import os
_nb = open(os.path.join(os.path.dirname(__file__), "..", "src", "notebook.carp")).read()
_ai = _nb[_nb.index("(defview array-items"):]
_ai = _ai[:_ai.index("\n\n")]
results.append(check("builtin source verbatim", {"src": hget("/objects/0/views")[0]["source"][:60]},
                     lambda r: hget("/objects/0/views")[0]["source"] == _ai))
items = hget("/objects/0/views/array-items/items")
results.append(check("phlow items", items,
                     lambda r: len(r) == 3
                               and [c["itemText"] for c in r[1]["nodeValue"]["columnValues"]] == ["1", "20"]
                               and r[1]["phlowObject"]["object_type"] == "Int"))
results.append(check("phlow send", hget("/objects/0/views/array-items/send/%d" % items[2]["phlowObject"]["id"]),
                     lambda r: r["print_string"] == "30"))
sp = rpc({"id": 24, "cmd": "eval", "session": "h1", "source": "@\"hi!\""})["ok"]["hostPort"]
def sget(path):
    return json.loads(urllib.request.urlopen("http://127.0.0.1:%d%s" % (sp, path), timeout=10).read())
results.append(check("string bytes view", sget("/objects/0/views"),
                     lambda r: [v["title"] for v in r] == ["String", "Bytes", "Print"]
                               and r[1]["viewName"] == "GtPhlowColumnedListViewSpecification"))
results.append(check("string bytes items", sget("/objects/0/views/string-bytes/items"),
                     lambda r: len(r) == 3
                               and [c["itemText"] for c in r[2]["nodeValue"]["columnValues"]] == ["2", "33", "!"]
                               and r[2]["phlowObject"]["object_type"] == "Byte"))
grad_src = '''(deftype Grad [w Int h Int])
(defn grad-pixels [g]
  (let-do [w @(Grad.w g)
           h @(Grad.h g)
           px (the (Array Byte) [])]
    (for [y 0 h]
      (for [x 0 w]
        (do
          (Array.push-back! &px (Byte.from-int (/ (* x 255) w)))
          (Array.push-back! &px (Byte.from-int (/ (* y 255) h)))
          (Array.push-back! &px (Byte.from-int 128))
          (Array.push-back! &px (Byte.from-int 255)))))
    px))
(defview rendered [g Grad]
  (=> (NB.bitmap)
      (NB.title @"Bitmap")
      (NB.extent @(Grad.w g) @(Grad.h g))
      (NB.pixels (grad-pixels g))))
(Grad.init 4 2)'''
bmr = rpc({"id": 25, "cmd": "eval", "session": "bm1", "source": grad_src})["ok"]
results.append(check("bitmap host", bmr, lambda r: r["exit"] == 0 and r["hostPort"] > 0 and r["value"] == "(Grad 4 2)"))
if bmr["hostPort"] > 0:
    import base64
    def bget(path):
        return json.loads(urllib.request.urlopen("http://127.0.0.1:%d%s" % (bmr["hostPort"], path), timeout=10).read())
    bviews = bget("/objects/0/views")
    results.append(check("bitmap view spec", bviews,
                         lambda r: r[0]["viewName"] == "GtPhlowBitmapViewSpecification"
                                   and r[0]["bitmap"]["width"] == 4
                                   and r[0]["bitmap"]["height"] == 2
                                   and r[0]["bitmap"]["stride"] == 16
                                   and r[0]["bitmap"]["format"] == "RGBA8888"))
    pixels = base64.b64decode(bviews[0]["bitmap"]["pixels"])
    results.append(check("bitmap pixels", {"len": len(pixels), "first": list(pixels[:4]), "last": list(pixels[-4:])},
                         lambda r: r["len"] == 32 and r["first"] == [0, 0, 128, 255] and r["last"] == [191, 127, 128, 255]))

tree_src = '''(deftype Cnt [n Int])
(defn cnt-kids [c]
  (let-do [n @(Cnt.n c)
           out (the (Array Int) [])]
    (when (> n 0)
      (do
        (Array.push-back! &out (nb-register (Cnt.init (- n 1))))
        (Array.push-back! &out (nb-register (Cnt.init (- n 1))))))
    out))
(defview overview [c Cnt]
  (let [n @(Cnt.n c)
        me @c]
    (=> (NB.tree)
        (NB.title @"Tree")
        (NB.items (fn [] (if (> n 0) 2 0)))
        (NB.item-format (fn [i] (fmt "root kid %d" i)))
        (NB.send (fn [i] (do (ignore i) (nb-register (Cnt.init (- n 1))))))
        (NB.children (fn [] (cnt-kids &me))))))
(Cnt.init 3)'''
tr = rpc({"id": 28, "cmd": "eval", "session": "tr1", "source": tree_src})["ok"]
results.append(check("tree host", tr, lambda r: r["exit"] == 0 and r["hostPort"] > 0))
if tr["hostPort"] > 0:
    def tget(path):
        return json.loads(urllib.request.urlopen("http://127.0.0.1:%d%s" % (tr["hostPort"], path), timeout=10).read())
    results.append(check("tree view spec", tget("/objects/0/views"),
                         lambda r: r[0]["viewName"] == "GtPhlowTreeViewSpecification"
                                   and r[0]["methodSelector"] == "overview"))
    troots = tget("/objects/0/views/overview/items")
    results.append(check("tree roots", troots,
                         lambda r: len(r) == 2 and r[0]["nodeValue"]["itemText"] == "root kid 0"
                                   and r[0]["phlowObject"]["print_string"] == "(Cnt 2)"))
    kid = troots[0]["nodeId"]
    tkids = tget("/objects/0/views/overview/children/0,%d" % kid)
    results.append(check("tree children", tkids,
                         lambda r: len(r) == 2 and r[0]["nodeValue"]["itemText"] == "(Cnt 1)"
                                   and r[0]["phlowObject"]["object_type"] == "Cnt"))
    grandkid = tkids[1]["nodeId"]
    tgrands = tget("/objects/0/views/overview/children/0,%d,%d" % (kid, grandkid))
    results.append(check("tree grandchildren", tgrands,
                         lambda r: len(r) == 2 and r[0]["nodeValue"]["itemText"] == "(Cnt 0)"))
    leafid = tgrands[0]["nodeId"]
    tleaf = tget("/objects/0/views/overview/children/0,%d,%d,%d" % (kid, grandkid, leafid))
    results.append(check("tree leaf empty", tleaf, lambda r: r == []))
    tkids2 = tget("/objects/0/views/overview/children/0,%d" % kid)
    results.append(check("tree children memoized", tkids2,
                         lambda r: [x["nodeId"] for x in r] == [x["nodeId"] for x in tkids]))

dv_src = '''(deftype Point [x Int y Int])
(defview coords [p Point]
  (=> (NB.text)
      (NB.title @"Coords")
      (NB.content (fmt "x: %d" @(Point.x p)))))
(defview coordinates [p Point]
  (let [x @(Point.x p)
        y @(Point.y p)]
    (=> (NB.list)
        (NB.title @"Coordinates")
        (NB.priority 2)
        (NB.items (fn [] 2))
        (NB.item-format (fn [i] (if (= i 0) (str x) (str y))))
        (NB.send (fn [i] (if (= i 0) (nb-register x) (nb-register y)))))))
(Point.init 3 4)'''
dv = rpc({"id": 29, "cmd": "eval", "session": "dv1", "source": dv_src})["ok"]
results.append(check("defview host", dv, lambda r: r["exit"] == 0 and r["hostPort"] > 0 and r["value"] == "(Point 3 4)"))
if dv["hostPort"] > 0:
    def dget(path):
        return json.loads(urllib.request.urlopen("http://127.0.0.1:%d%s" % (dv["hostPort"], path), timeout=10).read())
    dviews = dget("/objects/0/views")
    results.append(check("defview views", [(v["title"], v["methodSelector"], v["priority"]) for v in dviews],
                         lambda r: r == [("Coords", "coords", 1),
                                         ("Coordinates", "coordinates", 2),
                                         ("Print", "gtPrintFor", 100),
                                         ("Raw", "gtRawFor", 90)]))
    rawitems = dget("/objects/0/views/gtRawFor/items")
    results.append(check("defview raw items", rawitems,
                         lambda r: [[c["itemText"] for c in n["nodeValue"]["columnValues"]] for n in r] == [["x", "3"], ["y", "4"]]
                                   and r[1]["phlowObject"]["print_string"] == "4"))
    results.append(check("defview print view", dget("/objects/0/views/gtPrintFor"),
                         lambda r: r["string"] == "(Point 3 4)"))
    dv_expected = dv_src[dv_src.index("(defview coords"):dv_src.index("(defview coordinates")].rstrip()
    results.append(check("defview source verbatim", {"src": dviews[0]["source"][:40]},
                         lambda r: dviews[0]["source"] == dv_expected))
    ditems = dget("/objects/0/views/coordinates/items")
    results.append(check("defview list items", ditems,
                         lambda r: [x["nodeValue"]["itemText"] for x in r] == ["3", "4"]))

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

st = rpc({"id": 60, "cmd": "eval", "session": "set1", "source": "(Set.from-array &[10 20 30])"})["ok"]
results.append(check("set host", st, lambda r: r["exit"] == 0 and r["hostPort"] > 0 and r["value"].startswith("{")))
if st["hostPort"] > 0:
    def stget(path):
        return json.loads(urllib.request.urlopen("http://127.0.0.1:%d%s" % (st["hostPort"], path), timeout=10).read())
    sviews = stget("/objects/0/views")
    results.append(check("set views", [(v["title"], v["viewName"]) for v in sviews],
                         lambda r: r == [("Items", "GtPhlowColumnedListViewSpecification"),
                                         ("Print", "GtPhlowTextEditorViewSpecification")]))
    sitems = stget("/objects/0/views/set-items/items")
    results.append(check("set items", sitems,
                         lambda r: len(r) == 3 and sorted(int(n["nodeValue"]["columnValues"][1]["itemText"]) for n in r) == [10, 20, 30]
                                   and r[0]["phlowObject"]["object_type"] == "Int"))
bg = rpc({"id": 61, "cmd": "eval", "session": "set1", "source": "(Bag.from-array &[5 5 7])"})["ok"]
results.append(check("bag host", bg, lambda r: r["exit"] == 0 and r["hostPort"] > 0 and r["value"].startswith("(Bag")))
if bg["hostPort"] > 0:
    def bgget(path):
        return json.loads(urllib.request.urlopen("http://127.0.0.1:%d%s" % (bg["hostPort"], path), timeout=10).read())
    bitems = bgget("/objects/0/views/bag-items/items")
    results.append(check("bag items", bitems,
                         lambda r: len(r) == 3 and sorted(int(n["nodeValue"]["columnValues"][1]["itemText"]) for n in r) == [5, 5, 7]))

print("ALL PASS" if all(results) else "FAILURES", file=sys.stderr)
sys.exit(0 if all(results) else 1)
