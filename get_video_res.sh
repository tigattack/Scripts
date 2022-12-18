#!/bin/bash

# Small script to get resolution of all files in
# a given directory. Works recursively.
# All files must be video files.

# Usage: ./get_video_res.sh /path/to/file-or-directory

video_regex="\.webm$|\.flv$|\.vob$|\.ogg$|\.ogv$|\.drc$|\.gifv$|\.mng$|\.avi$|\.mov$|\.qt$|\.wmv$|\.yuv$|\.rm$|\.rmvb$|/.asf$|\.amv$|\.mp4$|\.m4v$|\.mp*$|\.mkv$|\.svi$|\.3gp$|\.flv$|\.f4v$"

path="$1"

# Ensure dependencies
if ! command -v 'ffprobe' >/dev/null; then
	printf 'ffprobe (part of the ffmpeg suite) is required. Please install ffmpeg.\n'
elif ! command -v 'jq' >/dev/null; then
	printf 'jq is required. Please install jq.\n'
fi


printres() {
	ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "$1"
}

if [ -d "$path" ] ; then
	printf "Finding files in: $path\n"

	files=$(
		find "$path" -type f | grep -E "$video_regex"
	)
	files_count=$(echo "$files" | wc -l)

	printf "Found $files_count video files in total.\n\n"
	printf 'File resolutions:\n'

	find "$path" -type f | grep -E "$video_regex" | while IFS=$'\n' read -r FILE; do
		printf "${FILE#$path}: "
		printres "$FILE"
	done

elif [ -f "$path" ]; then
	printf 'File resolution:\n'
	printf "$1: "
	printres "$path"
else
	printf "Path does not exist: $path\n"
fi

# Alt. method:
# ffprobe -v quiet -print_format json -show_format -show_streams "$1" | \
# jq --raw-output '"\(.format.filename): \(.streams[] | select(.codec_type == "video") | "\(.width) x \(.height)")"'
