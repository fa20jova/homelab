#!/bin/bash
# PVC usage monitor

THRESHOLD=80

echo "Checking PVCs over ${THRESHOLD}% usage..."

kubectl get pvc --all-namespaces -o custom-columns='NAMESPACE:.metadata.namespace,NAME:.metadata.name,STORAGE:.status.capacity.storage,ACCESS:.spec.accessModes[*]' | tail -n +2 | while read ns pvc size access; do
  usage=$(kubectl top pod --namespace "$ns" --no-headers 2>/dev/null | awk '{sum+=$3} END {print sum}')
  echo "PVC: $pvc in $ns – Current pod memory usage: ${usage}Mi"
done
