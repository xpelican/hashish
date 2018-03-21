#!/bin/bash

# Check for superuser permissions
#[WIP]





# Quick check for symlink setup
if [ ! -f "/usr/local/bin/winot" ] ; then
	root_dir=$(pwd)
	echo -e "WINOT is not configured to launch with a terminal command."
	read -r -p "Do you want WINOT to set it up?" response
		case "${response}" in
	    	[yY][eE][sS]|[yY])
			sleep 0.5
			echo -e "Creating symbolic link from current directory to /usr/local/bin"
			ln -s "$root_dir"/winot.sh /usr/local/bin/winot
			sleep 0.5
			echo -e "Symlink created from "$root_dir" to /usr/local/bin/winot!"
		esac	
fi

sleep 0.5
echo -e "winot is populating the screen with the necessary terminals!"

gnome-terminal --hide-menubar --zoom=1 --working-directory="$PENTEST_DIR" -e "watch -n 1 ifconfig" --geometry=80x67+0+0
sleep 0.3
gnome-terminal --hide-menubar --zoom=1 --working-directory="$PENTEST_DIR" -e "watch -n 1 rfkill list all" --geometry=35x35+400+0
sleep 0.3
gnome-terminal --hide-menubar --zoom=1 --working-directory="$PENTEST_DIR" -e "dmesg --follow" --geometry=125x20+0+800
sleep 0.3

# GREP MULTIPLE TERMS!!!: gnome-terminal --hide-menubar --zoom=0.8 --working-directory="$PENTEST_DIR" -e 'watch -n 1 lsmod | grep -E 'wl|802'' --geometry=90x15+400+1000
sleep 0.3
#gnome-terminal --hide-menubar --zoom=0.8 --working-directory="$PENTEST_DIR" -e "sleep 0.5 && rfkill unblock all && modprobe "  --geometry=125x40+800+1000



# Learn to: Dynamic window sizing in bash terminal - for adapting to changing screen resolutions.


#[WIP] Close all opened terminals with a CTRL+C on the main terminal.