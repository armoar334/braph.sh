#!/usr/bin/env bash

# put a number in args to color ur line
if [[ -z "$1" ]];
then
	color=7
else
	color="$1"
fi

if ! [[ $(type -t declare_y) == function ]];
then
	declare_y() {
		if [[ $x -lt 0 ]];
		then
			y=$(( 0 - x ))
		else
			y=$x
		fi

		y=$(bc -l <<<"sqrt("$(( y * 4 ))")")
		if [[ $x -lt 0 ]]; then y=$(bc -l <<<" 0 - $y"); fi
	}
fi

term_size() {
	read -r lines columns < <(stty size)
}

axes() {
	x1=$(( columns / 2 ))
	y1=$(( $(( lines / 2 )) - 10 ))
	printf "\e[1;"$x1"H"
	for i in $(seq 1 $y1)
	do
		printf "\u28B8\n\e["$(( x1 - 1 ))"C"
	done
	printf '\r%-*s' "$(( x1 - 1 ))" | sed "s/ /$(printf '\u2809')/g"
	printf '\u28B9'
	printf '%-*s' "$(( columns - x1 ))" | sed "s/ /$(printf '\u2809')/g"
	printf "\r\e["$(( x1 - 1 ))"C\e[B"
	for i in $(seq 1 $(( y1 - 1 )) )
	do
		printf "\u28B8\r\e[B\e["$(( x1 - 1 ))"C"
	done
}

calculate_braille() {
	# 1 4
	# 2 5
	# 3 6
	# 7 8
	# This is dumb but god does it make it easier by conforming to a standard
	positions="$1"
	unicode=0
	if [[ "$positions" == *"1"* ]]; then ((unicode+=1)) ; fi
	if [[ "$positions" == *"2"* ]]; then ((unicode+=2)) ; fi
	if [[ "$positions" == *"3"* ]]; then ((unicode+=4)) ; fi
	if [[ "$positions" == *"4"* ]]; then ((unicode+=8)) ; fi
	if [[ "$positions" == *"5"* ]]; then ((unicode+=16)) ; fi
	if [[ "$positions" == *"6"* ]]; then ((unicode+=32)) ; fi
	if [[ "$positions" == *"7"* ]]; then ((unicode+=64)) ; fi
	if [[ "$positions" == *"8"* ]]; then ((unicode+=128)) ; fi
	unicode=$(printf '%02x' "$unicode")
	printf "\u28$unicode"
}

calculate_position() {
	# Get braille dot position this is calculated by modulus of the x position by 2
	# and y by 4, so it works like normal co-ordinates, just with 0 instead of the highest
	x="$1"
	y="$2"
	if [[ "$x" == "1" ]];
	then
		case "$y" in
			1) printf "7" ;;
			2) printf "3" ;;
			3) printf "2" ;;
			0) printf "1" ;;
		esac
	else
		case "$y" in
			1) printf "8" ;;
			2) printf "6" ;;
			3) printf "5" ;;
			0) printf "4" ;;
		esac
	fi
	# Add extra dots so that axes are not interuppted
	if [[ $xpos == 0 ]];
	then
		printf '4568'
	fi
	if [[ $ypos == 0 ]];
	then
		printf '14'
	fi


}

term_size
#if [[ "$lines" -lt 24 ]]; then echo "Terminal must be at least 24 lines tall"; exit; fi
#if [[ "$columns" -lt 80 ]]; then echo "Terminal must be at least 80 columns wide"; exit; fi
axes

# First number is x starting point
for x in $(seq "-$(( x1 * 2 ))" $(( x1 * 2 )) )
do
	declare_y
	y=$(echo "$y" | cut -d '.' -f1 ) # Cut of everything b4 decimal point

	oldypos="$ypos"
	oldxpos="$xpos"

	# Temp
	brailley="$(( y % 4 ))"
	braillex="$(( x % 2 ))"

	if [[ $y -lt 0 ]]; # Invert if negative
	then
		brailley=$(( brailley + 4 ))
		if [[ $brailley -eq 4 ]]; then brailley=0; fi
	fi

	if [[ $x -lt 0 ]]; # Invert if negative
	then
		braillex=$(( braillex + 1 ))
		if [[ $braillex -eq 1 ]];
		then
			braillex=0
		else
			braillex=1
		fi
	fi

	# Position relative to graph 0,0

	if [[ $y -lt 0 ]]; # THE WORK I DO to accomodate a bitchass negative number
	then
		ypos="$(( y / 4 ))" # Bash's rounding down is helpful here, so we keep it :)
	else
		ypos="$(( 1 + $(( $(( y - 1 )) / 4 )) ))"
	fi
	if [[ $y == 0 ]];
	then
		ypos=0 # Because of bash
	fi

	if [[ $x -lt 0 ]];
	then
		xpos="$(( x / 2 ))"
	else
		xpos="$(( 1 + $(( $(( x - 1 )) / 2 )) ))" # Have to add one for cursor movement reasons
	fi
	if [[ $x == 0 ]];
	then
		xpos=1
	fi


	same="True"
	if [[ "$oldypos" != "$ypos" ]] || [[ "$oldxpos" != "$xpos" ]];
	then
		braille_code=''
		same="False"
	fi

	printf "\e["$(( y1 - ypos + 1 ))";"$(( x1 + xpos ))"H"

	printf '\e[3'$color'm'
	braille_code="$braille_code$(calculate_position $braillex $brailley)"
	calculate_braille "$braille_code"
	printf '\e[0m'

done
printf '\e['$(( y1 * 2 ))'H'
for i in $(seq $(( y1 * 2 )) $(( lines - 2 )) )
do
	printf '\e[2K\n'
done
printf '\e['$(( y1 * 2 ))'H'
