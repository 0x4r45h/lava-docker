#!/bin/bash

# Define the directory to watch
directory_to_watch="/go/bin/.lavavisor/upgrades"

# Function to handle file creation
handle_file_creation() {
  file="$1"
  if [ -f "$file" ] && [ "$(basename "$file")" = "lavap" ]; then
    echo "File 'lavap' has been created: $file"
    sleep 5
    supervisorctl restart lavap
  fi
}

# Monitor the directory and its subdirectories for file creation events
inotifywait -m -r -e create --format "%w%f" "$directory_to_watch" | while read -r file_created; do
  handle_file_creation "$file_created"
done
