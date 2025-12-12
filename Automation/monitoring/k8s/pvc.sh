#!/bin/bash

THRESHOLD=80
LOGFILE="/var/log/pvc-usage.log"

echo "[PVC Monitor] $(date): Starting PVC scan..." | tee -a "$LOGFILE"

NAMESPACES=$(kubectl get ns --no-headers -o custom-columns=":metadata.name")

for ns in $NAMESPACES; do
  PVCs=$(kubectl get pvc -n "$ns" --no-headers 2>/dev/null)
  if [[ -z "$PVCs" ]]; then continue; fi

  echo "[Namespace: $ns]" | tee -a "$LOGFILE"
  echo "$PVCs" | awk '{print $1}' | while read pvc; do
    usage=$(kubectl top pod -n "$ns" --no-headers 2>/dev/null | awk '{sum+=$3} END {print sum}')
    echo "  PVC: $pvc, Approx pod usage: ${usage}Mi" | tee -a "$LOGFILE"
  done
done
