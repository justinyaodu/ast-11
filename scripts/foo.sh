#!/bin/bash
for status in /m/mirror/processing/*/*/*.status; do
	echo "$(grep -o 'VCC...._.' <<< "$status") $(cat "$status")"
done > "/m/status-$(date +"%Y%m%d-%H%M")"
