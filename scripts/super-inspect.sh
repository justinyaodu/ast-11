#!/bin/bash

# slideshows images to facilitate human verification of proper light subtraction

source common.sh

# print usage message if number of parameters is incorrect
[ $# -ge 1 ] || abort "usage: $0 <directory/containing/galaxy/directories>"

containing_dir="$(strip_trailing_slash "$1")"

# start DS9 if not running
if ! ds9_xpa_running; then
	echo "starting DS9..."
	ds9 &

	# wait for DS9 to start
	while ! ds9_xpa_running; do sleep 1; done
fi

galaxy_count=0
for galaxy_dir in "$containing_dir"/*/; do
	galaxy_dirs[$galaxy_count]="$(strip_trailing_slash "$galaxy_dir")"
	((galaxy_count++))
done

galaxy_index=0
frame_count=0
debug='false'
zoom='1'
scale=''

for_each_frame() {
	xpaset -p ds9 frame first
	frames_remaining=$frame_count
	while [ $frames_remaining -gt 0 ]; do
		xpaset -p ds9 $@
		xpaset -p ds9 frame next
		((frames_remaining--))
	done
}

is_integer() {
	[ "$1" -eq "$1" ] 2>/dev/null
}

parse_command() {
	[ "$debug" = 'true' ] && echo $@
	case "$1" in
	h | help)
		cat <<- EOF

		    h[elp]     : print this screen
		    
		    p[rev]     : view previous galaxy
		    n[ext]     : view next galaxy
		    a[ll]      : list all loaded galaxies
		    f[ind]     : find galaxy by name
		    
		    m[odsub]   : load model-subtracted images
		    s[ource]   : load original images
		    [mas]k     : load mask images
		    j OR rmf   : load rmf images

		    r[egion]   : load regions for each image
		    c[lear]    : clear all regions

		    z[scale]   : use linear zscale scaling
		    l[og]      : use log zmax scaling

		    i[n]  [n]  : zoom in  [n times]
		    o[ut] [n]  : zoom out [n times]

		    e[fficient]: enable efficient input mode
				 (single letters, no Enter)
		    E          : disable efficient input mode

		    M          : mark model-subtracted image as best
		    J          : mark rmf image as best
		    C          : clear marks

		    d[ebug]    : toggle debug mode

		    q[uit]     : self-explanatory

		EOF
		;;
	p | prev)
		parse_command 'decrement'
		;;
	n | next)
		parse_command 'increment'
		;;
	a | all)
		for galaxy in "${galaxy_dirs[@]}"; do
			echo "$galaxy"
		done
		;;
	f | find)
		if [ -z "$2" ]; then
			read -p 'enter search string: ' -r query
		else
			query="$2"
		fi

		for index in $(seq 0 $((galaxy_count - 1))); do
			if grep -q "$query" <<< "${galaxy_dirs[$index]}"; then
				parse_command 'seek' $index
				return
			fi
		done
		echo "    no galaxy matching search string: $query"
		;;
	m | modsub)
		parse_command 'view' 'modsub'
		parse_command 'zscale'
		;;
	s | source)
		parse_command 'view' 'source'
		parse_command 'log'
		;;
	k | mask)
		parse_command 'view' 'mask'
		parse_command 'log'
		;;
	j | rmf)
		parse_command 'view' 'rmf'
		parse_command 'zscale'
		;;
	view)
		if [ -z "$2" ]; then
			echo "no target specified"
			return 1
		fi
		target="$2"

		case "$target" in
		modsub | source | mask | rmf)
			;;
		*)
			echo "unknown target: $target"
			return
			;;
		esac

		parse_command 'reset'
		
		for band in 'g' 'i' 'r' 'u' 'z'; do
			xpaset -p ds9 frame new
			((frame_count++))

			dir="${galaxy_dirs[$galaxy_index]}"
			galaxy="$(basename "$dir")"
			prefix="${dir}/${galaxy}_${band}"

			status_file="${prefix}.fits.status"
			[ -f "$status_file" ] || continue

			sub_status="$(<"$status_file")"

			region="${prefix}_mod${sub_status}.reg"

			case "$target" in
			modsub)
				case "$sub_status" in
				0)
					continue
					;;
				1 | 2 | 3)
					image="${prefix}_modsub${sub_status}.fits"
					;;
				*)
					echo "warning: unknown status $sub_status"
					continue
					;;
				esac
				;;
			source)
				image="${prefix}.fits"
				;;
			mask)
				case "$sub_status" in
				0 | 3)
					# 0 means it failed, so there cannot be a mask
					# 3 is the pseudo pipeline, which does use the
					# mask from the reference image, but it copies
					# the .pl file which can't be viewed in DS9
					continue
					;;
				1)
					image="${prefix}_flag_converted.fits"
					;;
				2)
					image="${prefix}_mask.fits"
					;;
				*)
					echo "warning: unknown status $sub_status"
					continue
					;;
				esac
				;;
			rmf)
				image="${prefix}_rmf.fits"

				# ignore region file entirely; do not want to
				# see isophotes when viewing rmf image
				region=""
				;;
			esac

			[ -f "$image" ] && parse_command 'load' "$image" "$region"
		done

		xpaset -p ds9 tile yes
		[ "$zoom" != '1' ] && parse_command 'zoom'
		;;
	r | region)
		for_each_frame regions show yes			
		;;
	c | clear)
		for_each_frame regions show no
		;;
	z | zscale)
		[ scale = 'zscale' ] && return
		for_each_frame scale linear
		for_each_frame scale mode zscale
		scale='zscale'
		;;
	l | log)
		[ scale = 'log' ] && return
		for_each_frame scale log
		for_each_frame scale mode zmax
		scale='log'
		;;
	i | in)
		times="$2"
		if [ -z "$times" ]; then
			times="1"
		elif ! is_integer "$times"; then
			echo "not an integer"
			return
		fi
		zoom="$(bc -l <<< "$zoom * 1.25^($times)")"
		parse_command 'zoom'
		;;
	o | out)
		times="$2"
		if [ -z "$times" ]; then
			times="1"
		elif ! is_integer "$times"; then
			echo "not an integer"
			return
		fi
		zoom="$(bc -l <<< "$zoom * 0.8^($times)")"
		parse_command 'zoom'
		;;
	zoom)
		for_each_frame zoom to $zoom
		;;
	e | efficient)
		read_opts='-n1'
		;;
	E)
		read_opts=''
		;;
	M | J | C)
		dir="${galaxy_dirs[$galaxy_index]}"
		for original in "$dir"/VCC????_?.fits; do
			case "$1" in
			M)
				status_num="$(<"$original.status")"
				best="$(sed -e "s/\.fits$/_modsub$status_num.fits/g" <<< "$original")"
				;;
			J)
				best="$(sed -e 's/\.fits$/_rmf.fits/g' <<< "$original")"
				;;
			C)
				best=""
				;;
			*)
				abort "how did you even get here?"
				;;
			esac
			best_file="$original.best"
			if [ -z "$best" ]; then
				rm -f "$best"
			else
				echo "$best" > "$best_file"
			fi
		done
		;;
	d | debug)
		if [ "$debug" = 'true' ]; then
			debug='false'
		else
			debug='true'
		fi
		;;
	q | quit)
		exit 0
		;;
	increment)
		parse_command 'seek' $((galaxy_index + 1))
		;;
	decrement)
		parse_command 'seek' $((galaxy_index - 1))
		;;
	seek)
		if ! is_integer "$2"; then
			echo "    parameter must be an integer"
			return
		fi

		galaxy_index=$2

		if [ $galaxy_index -lt 0 ]; then
			echo "    cannot seek before the first galaxy"
			galaxy_index=0
		elif [ $galaxy_index -ge $galaxy_count ]; then
			echo "    cannot seek past the last galaxy"
			galaxy_index=$((galaxy_count - 1))
		fi

		# reset zoom when viewing another galaxy
		zoom=1

		parse_command 'modsub'
		;;
	reset)
		xpaset -p ds9 frame delete all
		frame_count=0
		regions=
		;;
	load)
		[ -f "$2" ] && echo "    loading $2" && xpaset -p ds9 fits "$2"
		[ -f "$3" ] && xpaset -p ds9 regions load "$3"
		;;
	*)
		echo "unknown command: $1"
		parse_command 'help'
		;;
esac
}

xpaset -p ds9 regions showtext no
parse_command m

read_opts=''

while read $read_opts -p 'enter command (h for help): ' -r line; do
	# add a newline if in efficient mode
	[ -z "$read_opts" ] || echo

	parse_command $line
done
