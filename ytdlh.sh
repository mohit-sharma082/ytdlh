#!/bin/bash


YT_DLP_BIN=/usr/bin/yt-dlp

# Output directory
DOWNLOAD_DIR="output"
JSON_FILE="output.json"

# Check if output directory exists, create if not
mkdir -p "$DOWNLOAD_DIR"

# Check if yt-dlp is installed with the correct version
check_ytdlp() {
  if ! command -v yt-dlp &> /dev/null; then

    echo "yt-dlp is not installed."
    read -p "Do you want to install yt-dlp? (y/n): " choice

    if [ "$choice" = "y" ]; then
      echo "Installing yt-dlp..."
      sudo apt install yt-dlp
      echo "yt-dlp installed successfully!"

    else
      echo "Please install yt-dlp before running this script."
      exit 1
    fi

  fi
}

# Check if ffmpeg is installed
check_ffmpeg() {
  if ! command -v ffmpeg &> /dev/null; then

    echo "ffmpeg is not installed."
    read -p "Do you want to install ffmpeg? (y/n): " choice

    if [ "$choice" = "y" ]; then
      echo "Installing ffmpeg..."
      sudo apt-get install ffmpeg
      echo "ffmpeg installed successfully!"

    else
      echo "Please install ffmpeg before running this script."
      exit 1
    fi

  fi
}


# Function to download videos
download_video() {
  yt-dlp --write-annotations --write-sub --write-thumbnail --paths="${DOWNLOAD_DIR}" --output "%(title)s.%(ext)s" -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[height<=720]" -a "$1"

  # yt-dlp --write-thumbnail --paths="${DOWNLOAD_DIR}" --output "%(title)s.%(ext)s" -f "bestaudio[ext=mp3]/bestaudio" -a "$1"


# TO DOWNLOAD PLAYLIST
# yt-dlp --write-annotations --write-sub --write-thumbnail --output "/home/mohit/Documents/scripts/output/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s" -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[height<=720]" "PLAYLIST_URL"
# ############################## 


  # Convert .webp thumbnails to .png and remove .webp files
  for FILE in "$DOWNLOAD_DIR"/*.webp; do
    PNG_FILE="${FILE%.webp}.png"
    ffmpeg -i "$FILE" -y "$PNG_FILE" && rm "$FILE"
  done


# for file in "$DOWNLOAD_DIR"/*.webm; do
#     if [ -f "$file" ]; then
#         newfile="${file%.webm}.mp3"
#         ffmpeg -i "$file" -vn -acodec libmp3lame -q:a 2 "$newfile"
#     fi
# done


# Write filename and file path to JSON file
  for VIDEO_FILE in "$DOWNLOAD_DIR"/*.mp4; do
    FILENAME=$(basename "$VIDEO_FILE" | tr '"' "'")
    FILEPATH=$(realpath "$VIDEO_FILE")
    if [[ $string = "*" ]]; then
        echo 'Found!'
    fi
    jq --arg filename "$FILENAME" --arg filepath "$FILEPATH" '. += [{"filename": $filename, "filepath": $filepath}]' "$JSON_FILE" > tmpfile && mv tmpfile "$JSON_FILE"
  done
}

# Check if
# Check if url.txt exists
if [ ! -f "$1" ]; then
  echo "Error: url.txt file not found."
  exit 1
fi

# Initialize JSON file if it doesn't exist
echo "[]" > "$JSON_FILE"

# Check and install yt-dlp and ffmpeg
check_ytdlp
check_ffmpeg

download_video "$1"