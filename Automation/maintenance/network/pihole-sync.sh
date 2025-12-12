#!/bin/bash

PIHOLE_URL="http://pi.hole/admin"
BLOCKLIST_REPO="https://raw.githubusercontent.com/youruser/blocklists/main/hosts.txt"

curl -sSL $BLOCKLIST_REPO -o /etc/pihole/custom.list
pihole -g

echo "Pi-hole blocklist updated from GitHub source."
