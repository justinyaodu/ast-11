#!/bin/bash

# print the status for each image that has been processed
# by the subtraction pipeline

source common.sh

[ $# -eq 1 ] || abort "usage: $0 <dir>"

[ -d "$1" ] || abort "invalid dir: $1"

for status in $(find "$1" | grep 'VCC...._[ugriz].fits.status$'); do
	echo "$(grep -o 'VCC...._.' <<< "$status") $(cat "$status")"
done > "$1/status-$(date +"%Y%m%d-%H%M")"
