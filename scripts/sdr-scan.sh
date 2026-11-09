#!/usr/bin/env bash
# Quick RTL-SDR spectrum scan helper
# Usage: sdr-scan.sh [start_MHz] [stop_MHz] [step_kHz] [seconds]
set -euo pipefail
START=${1:-24}
STOP=${2:-1000}
STEP=${3:-250}
SECS=${4:-30}
OUT=/home/fr3k/.hermes/cache/scratch/sdr-scan-${START}-${STOP}.csv
rm -f "$OUT"
echo "Scanning ${START}-${STOP} MHz, ${STEP}k step, ${SECS}s..."
timeout $((SECS+10)) rtl_power -f ${START}M:${STOP}M:${STEP}k -g 40 -i 10 -e ${SECS}s "$OUT" 2>&1 | tail -3
echo "--- peaks ---"
python3 - "$OUT" <<'PY'
import sys, statistics
rows=[]
for line in open(sys.argv[1]):
    p=line.strip().split(',')
    if len(p)<7: continue
    low=float(p[2]); step=float(p[4])
    for i,d in enumerate(p[6:]):
        rows.append((low+i*step,float(d)))
if not rows:
    print("no data"); sys.exit()
med=statistics.median(d for _,d in rows)
peaks=sorted([r for r in rows if r[1]>med+8], key=lambda r:-r[1])
out=[]
for f,d in peaks:
    if not out or f-out[-1][0]>1e6: out.append((f,d))
for f,d in out[:25]:
    print(f"{f/1e6:8.3f} MHz  {d:6.2f} dB")
print("median noise floor:", round(med,2), "dB | peaks:", len(out))
PY
PY