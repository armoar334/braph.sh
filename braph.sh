#!/usr/bin/env bash

# put a number in args to color ur line
case "$1" in
	[0-7]) color="$1" ;;
	*) color=7 ;;
esac

if ! [[ $(type -t braph_equation) == function ]];
then
	braph_equation() {
		x=$tick
		y=$(( 100 - $x ))
	}
fi

term_size() {
	read -r lines columns < <(stty size)
}

calculate_braille() {
	# 1 4
	# 2 5
	# 3 6
	# 7 8
	# This is dumb but god does it make it easier by conforming to a standard
	positions=($@)
	unicode=0
	if [[ "${positions[0]}" == *"1"* ]]; then ((unicode+=1)) ; fi
	if [[ "${positions[1]}" == *"1"* ]]; then ((unicode+=2)) ; fi
	if [[ "${positions[2]}" == *"1"* ]]; then ((unicode+=4)) ; fi
	if [[ "${positions[3]}" == *"1"* ]]; then ((unicode+=8)) ; fi
	if [[ "${positions[4]}" == *"1"* ]]; then ((unicode+=16)) ; fi
	if [[ "${positions[5]}" == *"1"* ]]; then ((unicode+=32)) ; fi
	if [[ "${positions[6]}" == *"1"* ]]; then ((unicode+=64)) ; fi
	if [[ "${positions[7]}" == *"1"* ]]; then ((unicode+=128)) ; fi
	unicode=$(printf '%02x' "$unicode")
	#echo "${positions[@]}"
	printf "\u28$unicode"
}

term_size
if [[ "$lines" -lt 25 ]]; then echo "Terminal must be at least 24 lines tall"; exit; fi
if [[ "$columns" -lt 50 ]]; then echo "Terminal must be at least 80 columns wide"; exit; fi

graph_array=()

for y in {0..99};
do
	graph_array+=("$(printf %*s 100 | tr ' ' '0')")
done

for tick in {0..99};
do
	braph_equation
	graph_array[$y]="${graph_array[$y]:0:$x}1${graph_array[$y]:$((x+1))}"
done

#printf '\e[H'
for y_tick in {0..99..4}; do
	#y_tick=$((100-y_tick))
	for x_tick in {0..99..2}; do
		printf '\e[3'$color'm'
		calculate_braille \
		"${graph_array[$y_tick]:$x_tick:1}" \
		"${graph_array[$((y_tick+1))]:$x_tick:1}" \
		"${graph_array[$((y_tick+2))]:$x_tick:1}" \
		"${graph_array[$y_tick]:$((x_tick+1)):1}" \
		"${graph_array[$((y_tick+1))]:$((x_tick+1)):1}" \
		"${graph_array[$((y_tick+2))]:$((x_tick+1)):1}" \
		"${graph_array[$((y_tick+3))]:$x_tick:1}" \
		"${graph_array[$((y_tick+3))]:$((x_tick+1)):1}"
	done
	echo
done

printf '\e[0m'
