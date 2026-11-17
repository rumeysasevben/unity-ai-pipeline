#!/usr/bin/env bash
# Everything that has to be done after the level designer's map changes, in one command (see the decision log).
#
#   tools/update-map.sh            the whole update: editor steps, then the play checks
#   tools/update-map.sh --checks   only the play checks (the map has been updated already)
#
# Unity must be CLOSED (a project cannot be opened twice). Result: docs/map-update-report.md. Exit code 0 when everything passed.
set -u

here="$(cd "$(dirname "$0")" && pwd)"
project="$(cd "$here/.." && pwd)"
project_win="$(cd "$project" && pwd -W 2>/dev/null || echo "$project")"
version="$(sed -n 's/^m_EditorVersion: //p' "$project/ProjectSettings/ProjectVersion.txt")"
unity="/c/Program Files/Unity/Hub/Editor/$version/Editor/Unity.exe"
logs="${TMPDIR:-/tmp}/update-map"
report="$project/docs/map-update-report.md"
mkdir -p "$logs"

if [ ! -x "$unity" ]; then
  echo "Unity $version was not found at: $unity" >&2
  exit 2
fi

if tasklist 2>/dev/null | grep -q "^Unity.exe"; then  # case-sensitive: Unity Hub runs a lower-case unity.exe
  echo "Unity is open. Close it first: a project cannot be opened twice." >&2
  exit 2
fi

failed=0

if [ "${1:-}" != "--checks" ]; then
  echo "== Editor steps (about 10 minutes) =="
  # Graphics are needed here: the ambient people are placed by looking at the map through a camera.
  "$unity" -batchmode -quit -projectPath "$project_win" \
    -executeMethod MyGame.Editor.Map.MapUpdate.RunBatch -logFile "$logs/editor.log"
  code=$?
  echo "editor steps finished with code $code"
  if [ "$code" -ne 0 ]; then
    failed=1
  fi
fi

echo "== Play checks (about 6 minutes) =="
# Reachability: every delivery zone, yellow stop and the base can be reached from the start round the obstacles.
# Doorsteps: every delivery house takes its package put down at the door. Start: the tuk-tuk stands upright on the road.
# With graphics: URP cannot make its render textures under -nographics ("RenderTexture.Create failed" fails every test).
"$unity" -batchmode -projectPath "$project_win" -runTests -testPlatform PlayMode \
  -testFilter "MapReachabilityProbeTests;DoorstepDeliveryTests;NeighborhoodGameplayTests" \
  -testResults "$logs/play.xml" -logFile "$logs/play.log"
code=$?
echo "play checks finished with code $code"

{
  echo
  echo "## Play checks ($(date '+%Y-%m-%d %H:%M'))"
  echo
  if [ -f "$logs/play.xml" ]; then
    summary="$(grep -m1 -oE 'total="[0-9]+" passed="[0-9]+" failed="[0-9]+"' "$logs/play.xml")"
    echo "Result: $summary"
    echo
    bad="$(grep -oE 'name="[^"]*" fullname="[^"]*" methodname="[^"]*" classname="[^"]*" runstate="[A-Za-z]*" seed="[0-9]*" result="Failed"' "$logs/play.xml" | sed -E 's/name="([^"]*)".*/- \1/')"
    if [ -n "$bad" ]; then
      echo "Failed:"
      echo "$bad"
      failed=1
    else
      echo "All play checks passed: the tuk-tuk starts upright, every delivery zone, yellow stop and the base can be reached, every doorstep takes its package."
    fi
    grep -E "\[Probe\] (NOT REACHABLE|cut-off stretch)" "$logs/play.log" | sort -u | sed 's/^/- /' | head -10
  else
    echo "No result file: the play checks did not run (see $logs/play.log)."
    failed=1
  fi
} >> "$report"

if [ "$failed" -ne 0 ]; then
  echo "Something needs a look: docs/map-update-report.md" >&2
  exit 1
fi

echo "Everything passed: docs/map-update-report.md"
