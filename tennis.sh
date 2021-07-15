#!/bin/bash

courts=(
["353"]="Lower Woodland Playfield Tennis Court 01"
["354"]="Lower Woodland Playfield Tennis Court 02"
["355"]="Lower Woodland Playfield Tennis Court 03"
["356"]="Lower Woodland Playfield Tennis Court 04"
["357"]="Lower Woodland Playfield Tennis Court 05"
["358"]="Lower Woodland Playfield Tennis Court 06"
["359"]="Lower Woodland Playfield Tennis Court 07"
["360"]="Lower Woodland Playfield Tennis Court 08"
["361"]="Lower Woodland Playfield Tennis Court 09"
["362"]="Lower Woodland Playfield Tennis Court 10"
["1344"]="Gilman Playfield Tennis Court 01"
)

url="https://anc.apm.activecommunities.com/seattle/rest/reservation/resource/reservationtimegroup?locale=en-US"

while getopts ":d:s:e:" opt; do
  case $opt in
    d) date="$OPTARG"
    ;;
    s) start_hour="$OPTARG"
    ;;
    e) end_hour="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2 && exit 2
    ;;
  esac
done

if [ -z ${date} ]; then
	date=$(date '+%Y-%m-%d')
fi

if [ -z ${start_hour} ]; then
	echo 'missing -s [start_hour], expecting "18:00"' >&2
	exit 2
fi

if [ -z ${end_hour} ]; then
	echo 'missing -e [end_hour], expecting "19:00"' >&2
	exit 2
fi

echo "Available courts on ${date} from ${start_hour} to ${end_hour}:"

for id in "${!courts[@]}"
do
	
	resp=$(curl -s -X POST -H "Content-Type: application/json;charset=utf-8" $url \
	       -d "{\"resource_id\":\"$id\",\"datetime_periods\": [{\"from_date_time\":\"${date} ${start_hour}:00\",\"to_date_time\":\"${date} ${end_hour}:00\",\"id\":-1}],\"datetime_length\":{\"hours_per_day\":-1,\"start_time\":\"\",\"dates\":[]},\"reservation_unit\":1}" \
	       | jq '.body.reservation_times | .[] | select(.availability == "Available") | {available:.availability, startTime:.start_event_datetime, endTime:.end_event_datetime}')  

	if [[ ! -z ${resp} ]]; then
		echo "- ${courts[$id]}"
	fi

done
