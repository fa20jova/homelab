#!/bin/bash

KNOWN_MACS="/etc/network/known_macs.txt"
CURRENT_MACS="/tmp/current_macs.txt"

arp -a | awk '{print $4}' | sort | uniq > $CURRENT_MACS

echo "Comparing MAC list..."
comm -13 <(sort $KNOWN_MACS) <(sort $CURRENT_MACS) > /tmp/unknown_macs.txt

if [[ -s /tmp/unknown_macs.txt ]]; then
  echo "⚠️ New unknown MACs detected:"
  cat /tmp/unknown_macs.txt
  cat /tmp/unknown_macs.txt >> /var/log/mac-alerts.log
fi
