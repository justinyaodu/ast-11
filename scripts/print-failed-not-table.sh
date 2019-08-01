#!/bin/bash

# print all images that failed, but not because table was deemed bad

source common.sh

[ -d "$1" ] || abort "no dir specified"

cd "$1"

for failed in $(find | grep 'failed$'); do
	for model_log in $(sed -e 's/\.fits.failed/_createmodel?.log/g' <<< "$failed"); do
		if grep -q "output table is likely bad" < "$model_log"; then
			continue 2
		fi
	done

	echo "$failed"
done
