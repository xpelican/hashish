#!/bin/bash
# The functions within installer.sh used to be part of the main Hashish scripts, but I cut them out to save space and make the code easier to inspect & debug.
# installer.sh might be reintegrated into the main Hashish script at one point. For now, it is called from hashish_client.sh as needed.
# For proper function, installer.sh should be kept in the main hahish_client directory.

root_dir="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
hashish_version=$(readlink -f "$root_dir" | awk -F 'Hashish_v' '{ print $2 }' | cut -d/ -f1)

### STYLE #############################################################################################################

# Colors:
# First, define color variables. You can use ANSI escape codes:
#
#	Black        0;30     Dark Gray     1;30
#	Red          0;31     Light Red     1;31
#	Green        0;32     Light Green   1;32
#	Orange       0;33     Yellow        1;33
#	Blue         0;34     Light Blue    1;34
#	Purple       0;35     Light Purple  1;35
#	Cyan         0;36     Light Cyan    1;36
#	Light Gray   0;37     White         1;37
#
# Be sure to use the -e flag in your echo commands to allow backslash escapes.

white='\e[1;37m'
grey='\e[0;37m'
darkgrey='\e[0;30m'
red='\e[0;31m'
yellow='\e[1;33m'
green='\e[1;32m'
blue='\e[0;34m'

#bold_white='\e[1;37m'
#bold_yellow='\e[1;33m'
#bold_green='\e[1;32m'

# Prompts:
# WHITE     [!]: echo -e ""$grey"["$grey"!"$grey"]::
# GREEN     [+]: echo -e ""$grey"["$green"+"$grey"]::
# YELLOW    [-]: echo -e ""$grey"["$yellow"-"$grey"]::
# RED 		[x]: echo -e ""$grey"["$red"x"$grey"]::

#######################################################################################################################


### CHECK FILE & DIRECTORY STRUCTURE ##################################################################################

function_check_files_directories () {
# Check Files & Directories
echo -e "\n"$grey"Checking files & directories..."
#echo -e ""
sleep 0.5

# /config/
if [ ! -d ""$root_dir"/config/" ] ; then
	echo -e ""$yellow"/config/ directory missing. Creating..."
	sleep 0.5
	mkdir ""$root_dir"/config/"
	touch ""$root_dir"/config/client_IP.cfg" && touch ""$root_dir"/config/server_IP.cfg"
	echo -e ""$grey"["$green"+"$grey"]::Done."
else
	echo -e ""$grey"["$green"+"$grey"]::config/: Directory found."
fi

# /log/
if [ ! -d ""$root_dir"/log/" ] ; then
	echo -e ""$yellow"/log/ directory missing. Creating..."
	sleep 0.5
	mkdir ""$root_dir"/log/"
	echo -e ""$grey"["$green"+"$grey"]::Done."
else
	echo -e ""$grey"["$green"+"$grey"]::log/: Directory found."
fi

# /temp/
if [ ! -d ""$root_dir"/temp/" ] ; then
	echo -e $yellow"/temp/ directory missing. Creating..."
	sleep 0.5
	mkdir ""$root_dir"/temp/"
	echo -e ""$grey"["$green"+"$grey"]::Done."
else
	echo -e ""$grey"["$green"+"$grey"]::temp/: Directory found."
fi



# Files checked and OK
echo -e ""$grey"["$green"+"$grey"]::Files and directories in proper structure."
}
#######################################################################################################################





### CHECK DEPENDENCIES ################################################################################################
# cap2hccapx | hash-buster | hashid | no-more-secrets | sshpass | wpaclean

function_check_dependencies () {
echo -e "\n\v"$grey"Checking dependencies..."
sleep 0.5



# Check cap2hccapx:
# following syntax checks if file exists, and is not empty.
if [ ! -f ""$root_dir"/lib/cap2hccapx" ] ; then
	sleep 0.5
	echo -e ""$white"["$red"x"$white"]::cap2hccapx not installed, but it is required."
	sleep 0.5
	read -r -p "Do you want Hashish to install it [Y/N]? " response
		case "${response}" in
		    [yY][eE][sS]|[yY]) 
			# Go to temp directory, wget hashcat-utils there and extract from 7z archive, copy cap2hccapx from the archive into ./lib/, and remove the dowloaded archive and extracted directories from root_dir
				sleep 0.5 && cd "$root_dir"/lib/ && wget --no-verbose https://github.com/hashcat/hashcat-utils/releases/download/v1.8/hashcat-utils-1.8.7z && 7z x hashcat-utils-1.8.7z && sleep 0.5 && gcc "$root_dir"/lib/hashcat-utils-1.8/src/cap2hccapx.c -o "$root_dir"/lib/cap2hccapx && rm -rf "$root_dir"/lib/hashcat-utils* && sleep 1 && echo -e ""$grey"["$green"+"$grey"]::cap2hccapx installed"
				;;
			*)
					echo -e ""$grey"["$red"x"$grey"]::"$red"cap2hccapx not installed. Aborting." >&2; exit 1;
	        ;;
		esac
fi



# Check hashbuster (originally hash.py):
if [ ! -f ""$root_dir"/lib/hashbuster.py" ] ; then
	sleep 0.5
	echo -e ""$white"["$red"x"$white"]::hashbuster not installed, but it is required."
	sleep 0.5
	read -r -p "Do you want Hashish to install it [Y/N]? " response
		case "${response}" in
		    [yY][eE][sS]|[yY]) 
				sleep 0.5 && cd "$root_dir"/lib/ && wget https://raw.githubusercontent.com/UltimateHackers/Hash-Buster/master/hash.py && sleep 0.5 && mv "$root_dir"/lib/hash.py "$root_dir"/lib/hashbuster.py && chmod +x "$root_dir"/lib/hashbuster.py && echo -e ""$grey"["$green"+"$grey"]::hashbuster.py installed"
				;;
			*)
					echo -e ""$grey"["$red"x"$grey"]::"$red"hashbuster not installed. Aborting." >&2; exit 1;
	        ;;
		esac
fi



# Check hashid:
if [ ! command -v hashid > /dev/null 2>&1 ]; then
echo -e ""$white"["$red"x"$white"]::hashid not installed, but it is required." && sleep 0.5 && read -r -p "Do you want Hashish to install it [Y/N]?" response
	case "${response}" in
	    [yY][eE][sS]|[yY]) 
	        sleep 1 && apt -y install hashid && echo -e ""$grey"["$green"+"$grey"]::hashid installed"
	        ;;
	    *)
	        echo -e ""$grey"["$red"x"$grey"]::"$red"Aborting." >&2; exit 1;
	        ;;
	esac
else
	echo -e ""$grey"["$green"+"$grey"]::hashid installed"
fi



# Check NMS | also determine if INTRO will be NMS-enabled.
if [ ! -d ""$root_dir"/lib/no-more-secrets/" ] ; then
	echo -e ""$grey"["$yellow"-"$grey"]::nms (No More Secrets) not found. Not a big deal. You'll just miss the fancy intro." && NMS_intro=false
else
	echo -e ""$grey"["$green"+"$grey"]::nms installed."
	NMS_intro=true
	sleep 0.5
fi



# Check Nodejs:
if [ ! command -v npm > /dev/null 2>&1 ]; then
echo -e ""$white"["$red"x"$white"]::Nodejs not installed, but it is required." && sleep 0.5 && read -r -p "Do you want Hashish to install it [Y/N]?" response
	case "${response}" in
	    [yY][eE][sS]|[yY]) 
			sleep 1
	        cd "$root_dir"/lib/
	        curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
	        sleep 1 && apt -y install nodejs && echo -e ""$grey"["$green"+"$grey"]::Nodejs installed"
	        npm i nightmare
	        ;;
	    *)
	        echo -e ""$grey"["$red"x"$grey"]::"$red"Aborting." >&2; exit 1;
	        ;;
	esac
else
	echo -e ""$grey"["$green"+"$grey"]::Nodejs installed"
fi



# Check sshpass:
if [ ! command -v sshpass > /dev/null 2>&1 ]; then
echo -e ""$white"["$red"x"$white"]::sshpass not installed, but it is required." && sleep 0.5 && read -r -p "Do you want Hashish to install it [Y/N]?" response
	case "${response}" in
	    [yY][eE][sS]|[yY]) 
	        sleep 1 && apt -y install sshpass && echo -e ""$grey"["$green"+"$grey"]::sshpass installed"
	        ;;
	    *)
	        echo -e ""$grey"["$red"x"$grey"]::"$red"Aborting." >&2; exit 1;
	        ;;
	esac
else
	echo -e ""$grey"["$green"+"$grey"]::sshpass installed"
fi



# Check wpaclean:
if [ ! command -v wpaclean > /dev/null 2>&1 ]; then
echo -e ""$white"["$red"x"$white"]::wpaclean not installed, but it is required." && sleep 0.5 && read -r -p "Do you want Hashish to install it [Y/N]?" response
	case "${response}" in
	    [yY][eE][sS]|[yY]) 
	        sleep 1 && apt -y install wpaclean && echo -e ""$grey"["$green"+"$grey"]::wpaclean installed"
	        ;;
	    *)
	        echo -e ""$grey"["$red"x"$grey"]::"$red"Aborting." >&2; exit 1;

	        ;;
	esac
else
	echo -e ""$grey"["$green"+"$grey"]::wpaclean installed"
fi



sleep 0.5



# Dependencies checked and OK:
echo -e ""$grey"["$green"+"$grey"]::Dependencies installed"
sleep 0.5
}

function_check_files_directories
function_check_dependencies
#######################################################################################################################
