#!/bin/bash

# Hashish is an automated wordlist generator and hash cracker. It asks for user keywords, then applies increasingly challenging mutations to bruteforce hashes intelligently until they are cracked.
# hashish-client is the hash sending & utility interface for Hashish.
# Started writing this client on 2017-09-10.

session_date=$(date +"%Y%m%d-%H%M")
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





### LAUNCH CHECKS #####################################################################################################

# Root permissions check:
if [ "$EUID" -ne 0 ]; then
	echo -e ""$white"["$red"x"$white"]::Hashish requires root permissions for proper operation. Please run as root with \"sudo hashish\"."
	exit
fi

# Argument check:
if [ -z "$*" ]; then
	sleep 0.5
	echo -e "\n"$grey"["$red"x"$grey"]::You must supply Hashish with a hash, or the absolute path to a WPA2 .cap file as an argument."
	echo -e "\n"$blue"The correct syntax goes something like "$yellow"\"hashish a7a393feda19993d97de246f52af469f\""
	echo -e ""$blue"or if you're going to crack WPA capture files, "$yellow"\"hashish /root/Desktop/capture_file.cap [.hccapx | .pcap | .cap]\""
	sleep 1
	echo -e "\n"$grey"["$red"x"$grey"]::Improper launch. Exiting...\n"
	exit 1
fi

#######################################################################################################################



clear
echo -e ""$grey"["$green"+"$grey"]::root permissions and operation arguments in place. Initializing..."
sleep 1



# Call installer.sh to check file & directory structure, and dependencies:
#/bin/bash "$root_dir"/installer.sh





### READ & DETERMINE ENVIRONMENT VARIABLES ############################################################################

function_learn_environment () {
echo -e "\n\n"$grey"Determining environment variables..."

distro=$(lsb_release -i | awk '{print $3}')
os=$(uname)

# Get external IP for client.
client_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)

	# Check for no external IP:
	if [ -z "$client_IP" ]; then
			echo -e ""$grey"["$red"x"$grey"]Unable to get this client's external IP. If you know it, you can enter it by hand below and hit [ENTER]."
			read -r -p "Otherwise, press [CTRL + C] to exit Hashish." client_IP
	fi

sleep 1

# Reporting to user about gathered environment variables
echo -e ""$grey"Running on                            "$yellow""$distro" "$os""
sleep 0.5
echo -e ""$grey"Your client's external IP address is  "$yellow""$client_IP""
sleep 2
echo -e "\n\n"$white"Launching Hashish client..."
}

#######################################################################################################################





##### INTRO BANNER #######################################################################################################

function_intro_colored () {
#Good fonts at http://patorjk.com/software/taag: "AMC AAA01" / "ANSI SHADOW" / "Alligator" / "Alligator 2" / "Georgia11" / "Univers"
echo -e ""$darkgrey"||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
echo -e "$white"'                                                                                                                       '
echo -e ""$grey"                                                                     v."$green""$hashish_version"                                            "
echo -e "$white"'M""MMMMM""MM MMP"""""""MM MP""""""`MM M  MMMMM""MM  oo            dP                                                   '
echo -e "$white"'M  MMMMM  MM M  mmmm   MM M  mmmmm .M M  MMMMM  MM  ^^            88                                                   '
echo -e "$white"'M         `M M         MM M.      `YM M         MM  dP .d8888b. 88d888b.                                               '
echo -e "$white"'M  MMMMM  MM M  MMMMM  MM MMMMMMM.  M M  MMMMM  MM  88 Y8ooooo. 88"  `88                                               '
echo -e "$white"'M  MMMMM  MM M  MMMMM  MM M. .MMM"  M M  MMMMM  MM  88       88 88    88                                               '
echo -e "$white"'M  MMMMM  MM M  MMMMM  MM Mb.     .dM M  MMMMM  MM  dP `88888P" dP    dP                                               '
echo -e "$white"'MMMMMMMMMMMM MMMMMMMMMMMM MMMMMMMMMMM MMMMMMMMMMMM                                                                     '
echo -e ""$white"                                                   "$grey"by "$red"xpelican                                            "
echo -e ""$darkgrey"||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
echo -e ""$grey"An automated hash-cracking and wordlist permutation tool                                                               "
echo -e ""$darkgrey"||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"$red"/"$darkgrey"|||||"
echo -e ""$white"                                                                                                                         "
}



function_intro_plain () {
#Good fonts at http://patorjk.com/software/taag: "AMC AAA01" / "ANSI SHADOW" / "Alligator" / "Alligator 2" / "Georgia11" / "Univers"
echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
echo '                                                                                                  '
echo '                                                                                                  '
echo 'M""MMMMM""MM MMP"""""""MM MP""""""`MM M  MMMMM""MM  oo            dP                              '
echo 'M  MMMMM  MM M  mmmm   MM M  mmmmm .M M  MMMMM  MM  ^^            88                              '
echo 'M         `M M         MM M.      `YM M         MM  dP .d8888b. 88d888b.                          '
echo 'M  MMMMM  MM M  MMMMM  MM MMMMMMM.  M M  MMMMM  MM  88 Y8ooooo. 88"  `88                          '
echo 'M  MMMMM  MM M  MMMMM  MM M. .MMM"  M M  MMMMM  MM  88       88 88    88                          '
echo 'M  MMMMM  MM M  MMMMM  MM Mb.     .dM M  MMMMM  MM  dP `88888P" dP    dP                          '
echo 'MMMMMMMMMMMM MMMMMMMMMMMM MMMMMMMMMMM MMMMMMMMMMMM                                                '
echo '                                                                                                  '
echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
echo "An automated hash-cracking and wordlist permutation tool                                          "
echo "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
echo "                                                                                                  "
}



# We're taking the unescaped echo plain version of the logo intro and feeding it into NMS with arguments. -a for auto decipher, -s for encyption of empty characters, -f green for the color since echo color doesn't pass through NMS.



# Check which banner & Execute:
function_print_banner () {
#	We previously checked for the presence of NMS in CHECK DEPENDENCIES section, and are now determining which intro to show based on NMS presence status.
if [ "$NMS_intro" = "true" ] ; then
	clear
	function_intro_plain | nms -a -s -f green
	sleep 2
	clear
	function_intro_colored
else
	clear
	function_intro_colored
fi

# We're done printing the banner. Sleep 3 to give the users some time to check out that cool ass banner.
sleep 3
clear
}

#######################################################################################################################






### SESSION DETAILS ###################################################################################################

# Get session name:
function_session_name_set () {
echo -e "\n"$grey"["$white"!"$grey"]::Please enter a session name for your process (Session date will be logged as this exact moment you press [ENTER] )"$white""
read -r session_name
echo "$session_name" > "$root_dir"/config/session_name.cfg
}

#######################################################################################################################





##### BACKUP & LOG PREVIOUS SESSION FILES #############################################################################
function_check_previous_session () {
# Check previous hashfile:
# Check to see if there's currently an existing hashfile in temp/ right now, as it's supposed to start up empty and fill in from $1 when the program starts. If there's a file left, it means Hashish's last session exited unexpectedly, so we make a log of the previous file.
echo -e "\n"$grey"Checking for existence of a previous hashfile in "$yellow"temp/ "$grey"directory..."
if  [ -f ""$root_dir"/temp/hashfile" ] ; then
	previous_hashfile_date=$(stat -c %y ""$root_dir"/temp/hashfile" | awk '{print $1 $2}')
	echo -e "\n"$grey"["$white"!"$grey"]::You have a previously used hash in your temp/ directory. Hashish is now logging this in "$white"/log/"$yellow""$previous_hashfile_date""$grey"/"
	mkdir -p "$root_dir"/log/"$previous_hashfile_date"/
	cp "$root_dir"/temp/hashfil* "$root_dir"/log/"$previous_hashfile_date"/
	rm -f "$root_dir"/temp/hashfil*
	sleep 1
		echo -e ""$green"[+]"$grey"::Done."
else
	echo -e ""$green"[+]"$grey"::No previous hashfile found."
fi



sleep 1



# Check previous capfile(s):
echo -e "\n"$grey"Checking for existence of .cap file in "$yellow"temp/ "$grey"directory..."
if  [ -f ""$root_dir"/temp/*cap*" ] ; then
	previous_capfile_date=$(stat -c %y ""$root_dir"/temp/capfile" | awk '{print $1 $2}')
	echo -e ""$grey"["$white"!"$grey"]::You have a previously placed cap file in your temp directory. Hashish is now logging this in "$white"/log/cap/"$yellow""$previous_capfile_date""$grey"/"
	mkdir -p "$root_dir"/log/cap/"$previous_capfile_date"/
	cp "$root_dir"/temp/*.cap" ""$root_dir"/log/cap/"$previous_capfile_date"/
	rm -f "$root_dir"/temp/*.cap
	sleep 1
	echo -e ""$green"[+]"$grey"::Done."
	# Add a function that counts the number of .cap files in the capture directory.
else
	echo -e ""$green"[+]"$grey"::No previous capfile found."
fi
}

function_create_session_log () {
# Create log folder and logfile and start writing the local_logfile:
echo -e ""$grey"Saving and starting current Hashish session log in: "$yellow""$root_dir"/log/"$session_date"_"$session_name".log"
mkdir "$root_dir"/log/"$session_date"_"$session_name"/ && local_log_dir="$root_dir"/log/"$session_date"_"$session_name"/ || echo -e ""$grey"["$yellow"-"$grey"]::Could not create log directory. Logging will be disabled." && logging="false"
touch "$root_dir"/log/"$session_date"_"$session_name"/"$session_date"_"$session_name".log && local_log_file="$root_dir"/log/"$session_date"_"$session_name"/"$session_date"_"$session_name".log && logging="true" || echo -e ""$grey"["$yellow"-"$grey"]::Could not create log file. Logging will be disabled." ; logging="false"
}
#######################################################################################################################






### CONNECTION DETAILS ################################################################################################

function_ssh_set () {
# See if the user, perhaps during previous use, or through editing Hashish's files manually, has established an IP address for the Hashish Server:
echo -e "\n \n"$grey"Checking for previously established Hashish server..."

sleep 1

if [ ! -s ""$root_dir"/config/server_IP.cfg" ] ; then
# No previous Hashish Server IP found in /config/server_IP.cfg. Prompt the user to enter new IP address, and save that into /config/server_IP.cfg
	echo -e ""$white"["$yellow"-"$white"]::No previous Hashish server connection found. Please enter Hashish server IP with NO whitespaces, then press ENTER:"
	read server_IP
	# touch /config/server_IP.cfg
	echo "$server_IP" > "$root_dir"/config/server_IP.cfg
fi



# Either user just wrote server_IP to be written to config, or it was already there; but now we're reading it. Just to be sure, we ask once if they want to change IP
	server_IP=$(cat "$root_dir"/config/server_IP.cfg)
	echo -e ""$grey"["$white"!"$grey"]::Hashish Server IP saved as: "$yellow""$server_IP""$white""
	read -r -p "Do you want to change it [Y/N]? " response
		case "${response}" in
	    [yY][eE][sS]|[yY]) 
		echo -e ""$grey"Please enter Hashish server IP with NO whitespaces, then press ENTER:"$white""
		read server_IP
		echo "$server_IP" > "$root_dir"/config/server_IP.cfg
			;;
			*)
		echo -e ""$grey"Server IP stays as "$white""$server_IP""$grey"."
	        ;;
		esac
# In future updates, specify port as well.

	sleep 1

# Get username and password for using in Hashish Server SSH connection
	echo -e "\n"$grey"Please enter the SSH username registered on Hashish Server:"$white""
	read server_username
	echo -e "\n"$grey"Please enter the SSH password registered on Hashish Server:"$white""
	read -s server_password
	sleep 1
}





function_email_set () {
# Get user e-mail details for later connection from the Hashish Server to user, when the hash is cracked.

# Get user's email address:
echo -e ""$grey"Please enter the e-mail address you want Hashish to connect you at, and press [ENTER]:"$white""
read user_email_address
echo -e "$user_email_address" > "$root_dir"/config/user_email_address.cfg
sleep 1

# Get hashish email address:
echo -e "\n"$grey"Please enter the email address Hashish will be using to send you mail, and press [ENTER]:"$white""
read hashish_email_address
echo -e "$hashish_email_address" > "$root_dir"/config/hashish_email_address.cfg
sleep 1

# Get hashish email password:
echo -e "\n"$grey"Please enter password for hashish's e-mail address "$white""
read -s hashish_email_password
echo -e "$hashish_email_password" > "$root_dir"/config/hashish_email_password.cfg
sleep 1

# Get hashish email SMTP port:
echo -e "\n"$grey"Please enter SMTP port number for e-mail server (leave empty to default to 587): "$white""
read hashish_email_smtp
echo -e "$hashish_email_smtp" > "$root_dir"/config/hashish_email_smtp.cfg
}



function_email_show () {
# Print reported values:
echo -e "\n"$grey"["$green"+"$grey"]::User email information is set."
sleep 1
echo -e ""$grey"User email address:    "$user_email_address""
echo -e ""$grey"Hashish email address: "$hashish_email_address""
echo -e ""$grey"Email password:        "$hashish_email_password""
echo -e ""$grey"Email SMTP port #:     "$hashish_email_smtp""

sleep 0.5

echo -e "\n"$grey"["$yellow"?"$grey"]::Would you like to change your email settings [Y/N]? "$grey""
read -r response
    case "${response}" in
    [yY][eE][sS]|[yY])
		status_will_send_email="false";
        function_email_set
        function_email_show
		;;
    *)
        echo -e ""$grey"["$green"+"$grey"]::Email settings determined."
        status_will_send_email="true" ;
		;;
    esac
}



function_email_check () {
# Get E-Mail details:
user_email_address=$(cat "$root_dir"/config/user_email_address.cfg 2>/dev/null)
hashish_email_address=$(cat "$root_dir"/config/hashish_email_address.cfg 2>/dev/null)
hashish_email_password=$(cat "$root_dir"/config/hashish_email_password.cfg 2>/dev/null)
hashish_email_smtp=$(cat "$root_dir"/config/hashish_email_smtp.cfg 2>/dev/null)



if [[ -z "$user_email_address" || -z "$hashish_email_address" || -z "$hashish_email_password" || -z "$hashish_email_smtp" ]] ; then
	sleep 1
  	echo -e "\n"$grey"["$yellow"-"$grey"]::User's email information was not found! Do you want to reset email settings manually now? [Y/N]? "$grey""
  	read -r response
	    case "${response}" in
        [yY][eE][sS]|[yY])
            function_email_set
            function_email_show
			;;
        *)
            echo -e ""$grey"["$yellow"-"$grey"]::Email settings not correct. Hashish will "$red"NOT "$grey"send email when your session finishes."
            status_will_send_email="false" ;
			;;
	    esac
else
function_email_show
fi
}



function_ssh_test () {
# IP and credentials have been determined at this point. Attempt a healthy SSH connection to specified server with credentials to see if everything works. Write your hashish_client_IP to a config file on Server, too:
# (Also incorporate session_name for this sort of thing)

# Write client IP to server's Hashish/config/server_IP.cfg file:
sshpass -p "$server_password" ssh -q "$server_username"@"$server_IP" "echo -e "\$SSH_CONNECTION" | awk '{print "\$1"}' > ~/Hashish_v"$hashish_version"/hashish_server/config/client_IP.cfg" || { echo -e ""$grey"["$red"x"$grey"]::Error writing client IP value to Hashish Server. Exiting." ; exit 1 ; }

# Write user's email address to server's Hashish/config/user_email_address.cfg file:
sshpass -p "$server_password" scp "$root_dir"/config/user_email_address.cfg "$server_username"@"$server_IP":"~/Hashish_v"$hashish_version"/hashish_server/config/user_email_address.cfg" && echo -e "\n"$grey"["$green"+"$grey"]::Written user email address to Hashish Server." || { echo -e ""$grey"["$yellow"-"$grey"]::Error writing user email address to Hashish Server." ; exit 1 ; }
sshpass -p "$server_password" scp "$root_dir"/config/hashish_email_address.cfg "$server_username"@"$server_IP":"~/Hashish_v"$hashish_version"/hashish_server/config/hashish_email_address.cfg" && echo -e ""$grey"["$green"+"$grey"]::Written hashish email address to Hashish Server."  || { echo -e ""$grey"["$yellow"-"$grey"]::Error writing hashish email address to Hashish Server..." ; exit 1 ; }
sshpass -p "$server_password" scp "$root_dir"/config/hashish_email_password.cfg "$server_username"@"$server_IP":"~/Hashish_v"$hashish_version"/hashish_server/config/hashish_email_password.cfg" && echo -e ""$grey"["$green"+"$grey"]::Written hashish email password to Hashish Server."  || { echo -e ""$grey"["$yellow"-"$grey"]::Error writing email password to Hashish Server." ; exit 1 ; }
sshpass -p "$server_password" scp "$root_dir"/config/hashish_email_smtp.cfg "$server_username"@"$server_IP":"~/Hashish_v"$hashish_version"/hashish_server/config/hashish_email_smtp.cfg" && echo -e ""$grey"["$green"+"$grey"]::Written hashish email SMTP port number to Hashish Server."  || { echo -e ""$grey"["$yellow"-"$grey"]::Error writing email SMTP port number to Hashish Server. Exiting." ; exit 1 ; }

echo -e ""$green"SSH connection tested and working."
}
#######################################################################################################################








### PROCESS HASHES AND CAPS INTO HASHFILE & HCCAPX ####################################################################

function_write_arg1_to_hashfile () {
# This function should be called only if argument #1 is NOT a WPA file.
# This function creates the "hashfile" file and defining the "hashfile" variable to point to it's path, and finally writes argument #1 into that file:
	touch "$root_dir"/temp/"$session_date"_"$session_name".hashfile
	hashfile="$root_dir"/temp/"$session_date"_"$session_name".hashfile

	echo -e "\n"$grey"Writing your hash ("$red"" $1" "$grey") to "$yellow""$hashfile""$grey"..."
	echo -e "$1" > "$hashfile" && echo -e ""$grey"["$green"+"$grey"]::Done"
}





function_hash_type_auto_determine () {
echo -e "\n"$grey"Please choose which method you want to use for auto hash-detection:"
echo -e "\n"$blue"[1]:"$grey"hashID"
echo -e ""$blue"[2]:"$grey"hashtag.py"

read -r -p "Please type 1/2, or 0 to go back: " reply



if [ "$reply"="0" ] ; then
	function_hash_type_determine
fi



if [ "$reply"="1" ] ; then
	echo -e ""$grey"Launching HashID (hash-identifier) to auto-detect hash type..."
	sleep 0.3
	cd "$root_dir"
	hash_type=$(hashid -m "$hashfile" | head -n 3 | tail -1 | awk '{print $2}')
	hash_type_human_readable=$(hashid "$hashfile" | head -n 3 | tail -1 | awk '{print $4}')
	sleep 0.3
fi



if [ "$reply"="2" ] ; then
	echo -e ""$grey"Launching HashTag to auto-detect hash type..."
	sleep 0.3
	cd "$root_dir"
	hash_type=$("$root_dir"/lib/hashtag.py -sh "$target_hash" |  head -n 4 | tail -1 | awk '{print $6}')	
	hash_type_human_readable=$("$root_dir"/lib/hashtag.py -sh "$target_hash" | head -n 4 | tail -1 | awk '{print $2}')
	sleep 0.3
fi
}





function_hash_type_determine () {
# Ask if user knows hash type. Enter with no input to pass to HashID
echo -e "\n"$grey"If you know your hash type, please type it in "$white"ALL CAPS "$grey"and press "$green"[ENTER]"$grey"."
echo -e ""$grey"Leave "$white"empty "$grey"for automatic hash identification "$darkgrey"(less reliable)."
echo -e ""$darkgrey"(You can also specify hashcat type number to use with the -m parameter)"$white""
read hash_type_input

# TO-DO: This user-entered hash_type_input should ideally either be picked by the user from a pre-determined list of available hash modes, or
# OR, it should simply first of all go through a check against a list of strings (like "MD5,md5,NTLM,ntlm,..." to see if hash_type_input will indeed be a hashcat-supported type of hash.)


# First check if it's empty (implying use of HashID):
if [[ "$hash_type_input" = '' ]]; then
	function_hash_auto_determine
fi

# If it's not empty, first we see if it's NOT made of just numbers (Hashcat mode #), it's probably a string and has to be converted:
if [[ "$hash_type_input" != ^[0-9]+$ ]]; then
	# Small chain of commands applied to user-entered convert Human Readable hash type into HASHCAT MODE. We use a list of which mode # corresponds to which human-readable that's found in the hash_types.txt file.
	hash_type=$(cat "$root_dir"/config/hashcat_hash_types.txt | grep -i -w "$hash_type_input" | cut -d'=' -f 1 | sed -n '1p')
	hash_type_human_readable="$hash_type"
fi

if [ "$hash_type"="$hash_type_input" ] ; then
# And finally, if it's not empty, nor is not NOT numbers, then it must be numbers; hence, its probably a hashcat mode no.; so we can use it directly when feeding $hash_type into hashcat later on:
	hash_type_human_readable=$(cat "$root_dir"/config/hashcat_hash_types.txt | grep -i -w "$hash_type_input" | cut -d'=' -f 2 | sed -n '1p')
fi



# Hash type confirmation:
echo -e ""$grey"Your hash type is: "$white""$hash_type_human_readable" | "$grey"Hashcat mode: "$white""$hash_type""$grey""
	read -r -p "Are you happy with the results? [Y/N]? " reply2
	    case "${reply2}" in
    [yY][eE][sS]|[yY])
		echo -e ""$grey"["$green"+"$grey"]::Hash type set."
        ;;
    *)
        echo -e ""$red"[x]"$grey"Hash format not set. You will now be prompted to set it again."
        function_hash_type_determine
        ;;
    esac
}




function_extract_wpa2_hccapx () {
echo -e "\n"$white"Extracting WPA2 handshake from your capture file..."
# wpaclean usage: wpaclean <out.cap> <in.cap> [in2.cap] [...]
# wpaclean "$root_dir"/temp/wpa2_stripped.cap "$root_dir"/temp/wpa2_unstripped && sleep 0.5 && echo -e ""$grey"["$green"+"$grey"]::Done" || echo -e ""$grey"["$yellow"-"$grey"]::WPA handshake could not be stripped from capture file. Most likely not a big deal. Moving on..."
mv "$root_dir"/temp/wpa2_unstripped "$root_dir"/temp/wpa2_stripped.cap && sleep 0.5 && echo -e ""$grey"["$green"+"$grey"]::Done" || echo -e ""$grey"["$yellow"-"$grey"]::WPA handshake could not be stripped from capture file. Most likely not a big deal. Moving on..."

# Now we convert the cleaned-up cap to hccapx:
echo -e ""$grey"Converting handshake file format from "$yellow"cap "$grey"to "$yellow"hccapx"$grey"..."
# cap2hccapx usage: gcc cap2hccapx.c -o cap2hccapx && ./cap2hccapx <input.cap/pcap> <output.hccapx> [filter by essid] [additional network essid:bssid]
"$root_dir"/lib/cap2hccapx "$root_dir"/temp/wpa2_stripped.cap "$root_dir"/temp/"$session_date"_"$session_name".hccapx && sleep 0.5 && echo -e ""$grey"["$green"+"$grey"]::Done" || echo -e ""$grey"["$red"x"$grey"]::Could not convert capture file to hccapx format. Operation failure - Exiting..." && exit 1
}





function_check_arg1_for_cap () {
wpa2file=$(echo "$1" | grep -i "\.cap$\|\.pcapx$\|\.hccapx$" | head -n 1 | sed '/^$/d')

if [ ! -z "$wpa2file" ]; then
	echo "WPA/WPA2 capture file found: "$wpa2file""
	echo "$wpa2file" | grep -i .hccapx && cp "$wpa2file" "$root_dir"/temp/"$session_date"_"$session_name".hccapx && echo -e "\n"$white""$wpa2file2" copied over to "$yellow""$root_dir"/temp/"$session_date"_"$session_name".hccapx"$grey"."
	echo "$wpa2file" | grep -i .hccapx || cp "$wpa2file" "$root_dir"/temp/wpa2_unstripped && function_extract_wpa2_hccapx && echo -e "\n"$white""$wpa2file2" copied over to "$yellow"	"$root_dir"/temp/"$session_date"_"$session_name".hccapx"$grey"."
	capfile="$root_dir"/temp/"$session_date"_"$session_name".hccapx

else

	# wpa2file being empty or undefined (-z) means there were no .cap, .pcap or .hccapx files in $1. So since it passed the earlier checks for an argument, we can assume it's a hash string and write it to hashfile with "function_write_argument1_to_hashfile" :
	echo -e "\n"$white"[!]"$grey"::No WPA handshake files found."
	capfile=''
fi
}
#######################################################################################################################





### ONLINE HASH CRACKING SERVICES #####################################################################################

function_online_hashcrack_prompt () {
# Prompt to ask user whether to use online cracking services:
echo -e "\n"$grey"Do you want to utilize third-party online hash cracking services while you also continue Hashish processing? [Y/N]? "
read -r response
	case "${response}" in
	    [yY][eE][sS]|[yY]) 
	        status_online_hashcrack="true"
	        ;;
	    *)
	        echo -e "Hashish will not be utilizing third-party cracking services."
	        ;;
	esac
}



funcion_online_hashcrack_sites_ping () {
# Ping onlinehashrack.com:
echo -e "\n"$grey"This is the ping function. The variable status_online_hashcrack is currently set as: "$status_online_hashcrack""
echo -e "\n"$grey"Checking to see if "$yellow"onlinehashcrack.com "$grey"is up..."
sleep 0.5

if ping -c 1 onlinehashcrack.com &> /dev/null ; then
	echo -e ""$grey"Onlinehashcrack.com is "$green"UP!"$grey"" && status_onlinehashcrack_com="up"
else
	echo -e ""$grey"Onlinehashcrack.com is "$red"DOWN"$grey"." && status_onlinehashcrack_com="down"
fi



sleep 1



# Ping crackstation.net:
echo -e "\n"$grey"Checking to see if "$yellow"crackstation.net "$grey"is up..."
sleep 0.5

if ping -c 1 crackstation.net &> /dev/null ; then
	echo -e ""$grey"crackstation.net is "$green"UP!"$grey"" && status_crackstation_net="up"
else
	echo -e ""$grey"crackstation.net is "$red"DOWN"$grey"." && status_crackstation_net="down"
fi

}



#function_online_hashcrack_sites_choose () {
# Sites are assigned static numbers for now, since there are so few choices. We print whichever ones that responded to our pings earlier:
#echo -e "\n"$grey"Here are your choices for free online hash cracking solutions: \n"
#
#	if [ "$status_onlinehashcrack_com"="up" ]; then
#		echo -e ""$grey"[ "$red"1"$grey" ]::"$white"onlinehashcrack.com"
#	fi
#
#
#	if [ "$status_crackstation_net"="up" ]; then
#		echo -e ""$grey"[ "$red"2"$grey" ]::"$white"crackstation.net"
#	fi
#
## Now we ask the user to input the numbers for the services they want to try.
#echo -e "\n"$grey"Please enter the NUMBERS for each service you want to use, and press [ ENTER ]" && read -p -r online_hashcrack_choices
#
#if [ echo -e "$online_hashcrack_choices" | grep "1" ]; then
#	use_onlinehashcrack_com="true"
#fi
#
#if [ echo -e "$online_hashcrack_choices" | grep "2" ]; then
#	use_crackstation_net="true"
#fi
#}



#function_online_hashcrack_sites_use () {
#if [ "$use_onlinehashcrack_com"="true" ]; then
#	echo -e ""$grey"Hashish will now send your hash to https://www.onlinehashcrack.com/hash-cracking.php"

#curl_request_original=	curl 'https://www.onlinehashcrack.com/hash-cracking.php' -H 'origin: https://www.onlinehashcrack.com' -H 'accept-encoding: gzip, deflate, br' -H 'accept-language: en-US,en;q=0.9,tr;q=0.8' -H 'upgrade-insecure-requests: 1' -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36' -H 'content-type: application/x-www-form-urlencoded' -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'cache-control: max-age=0' -H 'authority: www.onlinehashcrack.com' -H 'referer: https://www.onlinehashcrack.com/hash-cracking.php' --data 'textareaHashes=6e809cbda0732ac4845916a59016f954&algorithm=MD5&emailHashes=erim.bilgin%40cyberage.com.tr&submit=Submit' --compressed | grep -io Done
#user_email_address_%=$(echo -e "$user_email_address" | sed 's/@/%40/g')
#curl_request_changed="curl "https://www.onlinehashcrack.com/hash-cracking.php" -H "origin: https://www.onlinehashcrack.com" -H "accept-encoding: gzip, deflate, br" -H "accept-language: en-US,en;q=0.9,tr;q=0.8" -H "upgrade-insecure-requests: 1" -H "user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.132 Safari/537.36" -H "content-type: application/x-www-form-urlencoded" -H "accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" -H "cache-control: max-age=0" -H "authority: www.onlinehashcrack.com" -H "referer: https://www.onlinehashcrack.com/hash-cracking.php" --data "textareaHashes="$target_hash"&algorithm=MD5&emailHashes="$user_email_address_%"&submit=Submit" --compressed | grep -io Done"
#curl_
#}



#if [ "$use_crackstation_net"="true" ]; then
#	echo -e ""$grey"Hashish will now send your hash to crackstation.net"
#	nodejs "$root_dir"/lib/crackstation_post.js "$target_hash"
#echo -e "Hashish will now launch a web browser to let you type in some CAPTCHAs."
#read -r "Please wait for the Nightmare browser window to show the CAPTCHA, then type it in it's box and press [ENTER]" key
#read -r key
#fi



#function_onlinehashcrack.com () {
# echo -e ""$grey"Testing your hash on onlinehashcrack.com..."
# First check if there's a capfile for WPA/WPA2 operation:
# if [ -f "$capfile" ]; then
#	[ Line to upload temp/capfile.hccapx to onlinehashcrack.com ]
# else
# If WPA/WPA2 doesn't exist for this operation, then upload a hashfile:
#	[ Line to upload hashfile to onlinehashcrack.com, while pulling hash types etc. out of config files.]
# fi
# }



function_hashbuster () {
# Check online sites for MD5, SHA1, SHA2 using hash-buster:
# Since hash-buster only supports those three formats, first we check if the hash type is one of those three:
if [[ "$hash_type_human_readable" = "MD5" || "$hash_type_human_readable" = "SHA1" || "$hash_type_human_readable" = "SHA256" ]]; then
	
	python "$root_dir"/lib/hashbuster.py --path "$hashfile"

	echo -e "\n"$white"Press "$green"[ANY KEY] "$white"to continue, or "$red"[CTRL+C] "$white"to quit."$grey""
	read  -r -p ""
fi
}

#######################################################################################################################





### EXIT ##############################################################################################################
function_exit () {
echo -e "\n"$grey"Cleaning up..."
sleep 0.2
echo -e "\n"$grey"Copying all files in temp/ to "$yellow"log/"$session_date"_"$session_name"/..."
mkdir "$root_dir"/log/"$session_date"_"$session_name"/
cp -R "$root_dir"/temp/. "$root_dir"/log/"$session_date"_"$session_name"/
sleep 0.5
echo -e ""$grey"Deleting the processed files for this session..."
rm -r "$root_dir"/temp/*
sleep 1
echo -e ""$green"[+]"$grey"::Done."
sleep 0.5
echo -e "\n\n"$white"Thank you for using Hashish Client! Exiting..."
sleep 2
exit
}
#######################################################################################################################



#function_check_active_sessions () {
#	sshpass -p "$server_password" ssh -q "$server_username"@"$server_IP" "ls -lah ~/Hashish_v"$hashish_version"/hashish_server/log/ | grep -i "restore""
#}



### EXECUTION OF FUNCTIONS ############################################################################################

#function_check_files_directories
#sleep 1
#function_check_dependencies
#sleep 1
function_learn_environment
sleep 1
#function_print_banner
#sleep 3
function_session_name_set
sleep 1
function_check_previous_session
sleep 1
function_ssh_set
sleep 1
function_email_check
sleep 1
function_ssh_test
sleep 1
function_hash_type_determine
sleep 1

function_check_arg1_for_cap "$1"

if [ ! -z "$capfile" ]; then

	# WPA-Mode cracking:
	function_extract_wpa2_hccapx
	sleep 1
	echo -e "\n"$grey"["$white"-"$grey"]::Sending your WPA2 capture file to Hashish Server."
	sshpass -p "$server_password" scp "$capfile" "$server_username"@"$server_IP":"~/hashish_server/temp/capfile.hccapx" && echo -e ""$grey"["$green"+"$grey"]::Sent capfile to Hashish Server." || echo -e ""$grey"["$yellow"-"$grey"]::Error writing capfile to Hashish Server."

	echo -e "\n"$grey"["$white"!"$grey"]::Establishing SSH connection to Hashish Server..."
	sleep 1
	sshpass -p "$server_password" ssh "$server_username"@"$server_IP" "./~/hashish_server/hashish_server.sh ../temp/capfile.hccapx "$session_name"" || echo -e ""$grey"["$red"x"$grey"]::Error establishing SSH connection to Hashish Server."


else

	# Hash-Mode cracking:
	function_online_hashcrack_prompt

	if [ "$status_online_hashcrack" = "true" ]; then
		function_hashbuster
	fi

	sleep 1


	function_write_arg1_to_hashfile "$1"
	sleep 1
	echo -e "\n"$grey"Sending your hash to Hashish Server..."
	sshpass -p "$server_password" scp "$hashfile" "$server_username"@"$server_IP":"~/Hashish_v"$hashish_version"/hashish_server/temp/hashfile" && echo -e ""$grey"["$green"+"$grey"]::Sent hashfile address to Hashish Server." || { echo -e ""$grey"["$yellow"-"$grey"]::Error writing hashfile to Hashish Server."  ; exit 1 ; }
	sleep 1

	echo -e "\n"$grey"["$white"!"$grey"]::Establishing SSH connection to Hashish Server..."
	sleep 0.3
	echo -e "\n"$grey"["$white"!"$grey"]::Using target hash: "$red""$target_hash" "$grey"[ with Hashcat Mode "$red""$hash_type" "$grey"| "$red""$hash_type_human_readable""$grey" ]"
	sleep 2
	sshpass -p "$server_password" ssh -t "$server_username"@"$server_IP" "~/Hashish_v"$hashish_version"/hashish_server/hashish_server.sh "$session_name" "$hash_type"" || { echo -e ""$grey"["$yellow"-"$grey"]::Error connecting to Hashish Server. Please check SSH availability on both machines." ; exit 1 ; }

fi

sleep 1
function_exit

#######################################################################################################################
