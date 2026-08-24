#!/bin/sh
# Runs the regression suites against throwaway servers.
#
# WARNING: starting a carp server kills every running value host on this
# machine (the stale-host pkill in the server's main), including hosts a
# live GT session is inspecting. Run this when no notebook you care about
# is open.
#
# Environment:
#   CARP_COMPILER  the self-hosting compiler binary        (required)
#   CARP_DIR       checkout whose core/ the server uses    (required)
#   CARP_SERVER    server binary          (default ../out/carp-server)
#   CARP_NB_LIB    notebook runtime       (default ../src/notebook.carp)
#   REG_PORT       first of three ports   (default 8123)
#   REG_STRICT     1 makes known-defect tests fail the exit code too
#
# Exit code: 0 unless an anchor regressed (or REG_STRICT=1 and defects
# are still open).
set -e
here=$(cd "$(dirname "$0")" && pwd)
BIN=${CARP_SERVER:-$here/../out/carp-server}
CC=${CARP_COMPILER:?set CARP_COMPILER}
CORE=${CARP_DIR:?set CARP_DIR}/core
NB=${CARP_NB_LIB:-$here/../src/notebook.carp}
P1=${REG_PORT:-8123}; P2=$((P1+1)); P3=$((P1+2)); P4=$((P1+3))
work=$(mktemp -d)

"$BIN" "$P1" "$CC" "$CORE" "$work/healthy" "$NB" > "$work/healthy.log" 2>&1 &
pid1=$!
# no notebook library at all: no hosts, no marked values — but cells run
"$BIN" "$P4" "$CC" "$CORE" "$work/nonb" > "$work/nonb.log" 2>&1 &
pid4=$!
# the degraded server cannot find the warm base's library sources, so its
# warm environment silently falls back to bare core while eval keeps
# compiling with the notebook runtime; environment_regressions E1 runs here
CARP_LIB_CACHE="$work/nowhere" \
  "$BIN" "$P2" "$CC" "$CORE" "$work/degraded" "$NB" > "$work/degraded.log" 2>&1 &
pid2=$!
"$BIN" --dap "$P3" "$CC" "$CORE" "$work/dap" "$NB" > "$work/dap.log" 2>&1 &
pid3=$!
cleanup() {
  kill "$pid1" "$pid2" "$pid3" "$pid4" 2>/dev/null || true
  pkill -f "$work/.*/cell-host" 2>/dev/null || true
  rm -rf "$work"
}
trap cleanup EXIT
sleep 2

fail=0
cd "$here"
python3 absorption_regressions.py "$P1" || fail=1
python3 value_channel_regressions.py "$P1" "$P4" || fail=1
python3 environment_regressions.py "$P1" "$P2" "$P3" || fail=1
exit $fail
