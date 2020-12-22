#!/bin/bash
audio_file="audio.m3u8"
video_file="video.m3u8"

download_and_process () 
{
	fname=$1
	content_type=$2
	
	# Create new directory and move the file into it 
	mkdir $content_type

	# Remove metadata lines 
	sed -i '/^\#/d' $fname

	# wget every URL for the stream files 
	i=0
	while IFS= read -r line
	do
	  	current_file=$content_type"/stream"$i".ts"
		wget -q $line -O $current_file
		echo $current_file
	  	((i=i+1))
	done < $fname

	# cat all files into a total file 
	for ((file_i=0; file_i<$i; file_i++)) 
	do 
		current_file=$content_type"/stream"$file_i".ts"
		cat $current_file >> $content_type".ts"
		rm $current_file
	done

	rmdir $content_type
}

download_and_process "video.m3u8" "video"
download_and_process "audio.m3u8" "audio"

# Combine the audio and video into one final video
ffmpeg -i video.ts -i audio.ts -c:v copy -c:a aac final.mp4

rm *.ts
