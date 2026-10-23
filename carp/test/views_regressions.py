#!/usr/bin/env python3
"""Exercise the shared view model through the notebook's actual JSON adapter."""
import json
import os
from pathlib import Path
import subprocess
import tempfile

compiler = os.environ['CARP_COMPILER']
core = str(Path(os.environ['CARP_DIR']) / 'core')
notebook = Path(__file__).resolve().parents[1] / 'src' / 'notebook.carp'
source = r'''
(deftype Point [x Int y Int])
(defview coordinates [p Point]
  (=> (View.text) (View.title @"Coordinates")
      (View.content (fmt "point(%d, %d)" @(Point.x p) @(Point.y p)))))
(defn main []
  (let-do [root (view-register (Result.unsafe-from-success (Array.range 0 699 1)))]
    (IO.println &(NB.route "GET" "/objects/0/views/array-items/count"))
    (IO.println &(NB.items-json root "array-items" 300 2))
    (IO.println &(NB.items-json root "array-items" 300 2))
    (NB.release-object! root)
    (IO.println (if (View.valid-id? root) "true" "false"))
    (View.drop-ref! 1) (View.drop-ref! 1)
    (View.drop-ref! 2) (View.drop-ref! 2)
    (IO.println (if (View.valid-id? root) "true" "false"))
    (IO.println &(NB.views-json (view-register (Point.init 3 7))))
    (IO.println &(NB.views-json (view-register @"abc")))
    (View.clear!)))
'''
with tempfile.TemporaryDirectory(prefix='carp-view-test-') as directory:
    directory = Path(directory)
    program = directory / 'views.carp'
    program.write_text('(load ' + json.dumps(str(notebook)) + ')\n' + source)
    binary = directory / 'views'
    subprocess.run([compiler, '-c', core, '-b', '-o', str(binary), str(program)], check=True)
    result = subprocess.run([str(binary)], text=True, capture_output=True, check=True)
    assert not result.stderr, result.stderr
    replies = [json.loads(line) for line in result.stdout.splitlines()]
    assert replies[0] == 700
    first, repeated = replies[1:3]
    assert len(first) == 2
    assert [row['nodeValue']['columnValues'][0]['itemText'] for row in first] == ['300', '301']
    assert [row['phlowObject']['print_string'] for row in first] == ['300', '301']
    assert [row['nodeId'] for row in repeated] == [row['nodeId'] for row in first]
    assert replies[3] is True, 'children must retain parent storage'
    assert replies[4] is False, 'last child lease must release the parent'
    coordinates = next(view for view in replies[5] if view['methodSelector'] == 'coordinates')
    assert coordinates['string'] == 'point(3, 7)'
    assert coordinates['title'] == 'Coordinates'
    assert '(defview coordinates' in coordinates['source']
    byte_view = next(view for view in replies[6] if view['methodSelector'] == 'string-bytes')
    assert [column['title'] for column in byte_view['columnSpecifications']] == ['#', 'Byte', 'Char']
print('shared notebook views, bounded ranges, navigation, source, and leases passed')
