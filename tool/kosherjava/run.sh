#!/usr/bin/env bash
# Runs kosher_dart and KosherJava over the same places and dates, and writes
# the differences to build/kosherjava/report.txt.
set -euo pipefail
KOSHERJAVA_TAG="${1:-3.1.0}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TOOL="$ROOT/tool/kosherjava"
WORK="$ROOT/build/kosherjava"
SRC="$WORK/zmanim-$KOSHERJAVA_TAG"

mkdir -p "$WORK/out"
[ -d "$SRC" ] || git clone -q --depth 1 --branch "$KOSHERJAVA_TAG" \
  https://github.com/KosherJava/zmanim.git "$SRC"
javac -encoding UTF-8 -nowarn -d "$WORK/classes" \
  $(find "$SRC/src/main/java" -name '*.java') "$TOOL/Dump.java"
(cd "$ROOT" && dart pub get --no-example >/dev/null && dart compile kernel "$TOOL/dump.dart" -o "$WORK/dump.dill" >/dev/null)

cd "$WORK"
java -cp classes Dump cal out/j_cal.txt
TZ=UTC dart dump.dill cal out/d_cal.txt
cp "$TOOL/places.txt" places.txt
while read -r name lat lon elevation zone; do
  java -cp classes Dump zman "out/j_$name.txt" "$name" "$lat" "$lon" "$elevation" "$zone"
  TZ="$zone" dart dump.dill zman "out/d_$name.txt" "$name" "$lat" "$lon" "$elevation"
done < places.txt
python3 -I "$TOOL/compare.py" > report.txt
echo "$WORK/report.txt"
