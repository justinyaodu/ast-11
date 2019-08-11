#!/bin/bash

# remove the failure indicator file
# if main.sh failed because the table was deemed bad

source common.sh

[ -d "$1" ] || abort "no dir specified"

cd "$1"

for failed in $(find | grep 'failed$'); do
	for model_log in $(sed -e 's/\.fits.failed/_createmodel?.log/g' <<< "$failed"); do
		if grep -q "output table is likely bad" < "$model_log"; then
			rm -v "$failed"
			break
		fi
	done
done
