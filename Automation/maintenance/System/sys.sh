#!/bin/bash

ech "Based on ENV"

echo "System Info:"
echo "============"
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"
echo "OS: $(grep PRETTY_NAME /etc/os-release | cut -d '=' -f2 | tr -d '\"')"
echo "Kernel: $(uname -r)"
echo "CPU: $(lscpu | grep 'Model name' | cut -d ':' -f2 | sed 's/^ *//')"
echo "Memory: $(free -h | awk '/Mem:/ {print $2 " total, " $3 " used"}')"
echo "Disk: $(df -h / | awk 'END{print $2 " total, " $3 " used"}')"
echo "IP Address: $(hostname -I | awk '{print $1}')"
