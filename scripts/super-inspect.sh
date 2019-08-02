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
			    l[ist]     : list all loaded galaxies
			    f[ind]     : find galaxy by name
			    
			    m[odsub2]  : load modsub2 images
			    s[ource]   : load original images

			    r[egion]   : load regions for each image
			    c[lear]    : clear all regions

			    z[scale]   : use linear zscale scaling
			    l[og]      : use log zmax scaling

			    i[n]  [n]  : zoom in  [n times]
			    o[ut] [n]  : zoom out [n times]

			    e[fficient]: enable efficient input mode
			                 (single letters, no Enter)
			    E          : disable efficient input mode

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
		l | list)
			for galaxy in "${galaxy_dirs[@]}"; do
				echo "$galaxy"
			done
			;;
		f | find)
			if [ -z "$2" ]; then
				echo "    no search string given"
				return
			fi

			for index in $(seq 0 $((galaxy_count - 1))); do
				if grep -q "$2" <<< "${galaxy_dirs[$index]}"; then
					parse_command 'seek' $index
					return
				fi
			done
			echo "    no galaxy matching search string: $2"
			;;
		m | modsub2)
			parse_command 'view' '_modsub4.fits' '_modsub3.fits' '_modsub2.fits' '_modsub1.fits'
			parse_command 'zscale'
			;;
		s | source)
			parse_command 'view' '.fits'
			parse_command 'log'
			;;
		view)
			parse_command 'reset'
			# make $@ contain all suffixes
			shift
			for band in 'g' 'i' 'r' 'u' 'z'; do
				dir="${galaxy_dirs[$galaxy_index]}"
				galaxy="$(basename "$dir")"

				xpaset -p ds9 frame new
				((frame_count++))

				region="${dir}/${galaxy}_${band}_mod2.reg"
				[ ! -f "$region" ] && region="${dir}/${galaxy}_${band}_mod1.reg"

				for suffix in "$@"; do
					image="${dir}/${galaxy}_$band$suffix"
					[ -f "$image" ] && parse_command 'load' "$image" "$region" && break
				done
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
			for_each_frame scale linear
			for_each_frame scale mode zscale
			;;
		l | log)
			for_each_frame scale log
			for_each_frame scale mode zmax
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

			parse_command 'modsub2'
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
