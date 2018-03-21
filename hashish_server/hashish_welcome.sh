#!/bin/bash

# This is a test script for launching tmux
# The goal is to get it to display multiple screens over the same SSH connection, using TMUX.

echo "you have executed hashish_welcome.sh"
sleep 0.2

session_name="$1"
hashish_version="$2"
echo -e "session name is "$session_name""
echo -e "hashish version is "$hashish_version""

tmux new -s "$session_name" -d
tmux send-keys -t "$session_name" "cd ~/Hashish_v"$hashish_version"/hashish_server/" ENTER
tmux send-keys -t "$session_name" "./hashish_server.sh "$session_name"" ENTER
tmux attach -t "$session_name"
