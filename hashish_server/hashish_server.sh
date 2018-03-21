#!/bin/bash

# Hashish is an automated wordlist generator and hash cracker. It asks for user keywords, then applies increasingly challenging mutations to bruteforce hashes intelligently until they are cracked.
# hashish_server is to run on the External Server. hashish_client connects to the server and runs hashish_server over the SSH connection it initiates.
# Started writing hashish_server on 2017-09-30

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
hashish_version=$(readlink -f "$root_dir" | awk -F 'Hashish_v' '{ print $2 }' | cut -d/ -f1)

### STYLE ##########################################################################################################

# Colors:
# First, define color variables. You can use ANSI escape codes:

#	Black        0;30     Dark Gray     1;30
#	Red          0;31     Light Red     1;31
#	Green        0;32     Light Green   1;32
#	Orange       0;33     Yellow        1;33
#	Blue         0;34     Light Blue    1;34
#	Purple       0;35     Light Purple  1;35
#	Cyan         0;36     Light Cyan    1;36
#	Light Gray   0;37     White         1;37

# Be sure to use the -e flag with echo to allow backslash escapes.

white='\e[1;37m'
grey='\e[0;37m'
darkgrey='\e[0;30m'
red='\e[0;31m'
yellow='\e[1;33m'
green='\e[1;32m'
blue='\e[0;34m'

# Prompts:
# WHITE     [!]: echo -e ""$grey"["$grey"!"$grey"]::
# GREEN     [+]: echo -e ""$grey"["$green"+"$grey"]::
# YELLOW    [-]: echo -e ""$grey"["$yellow"-"$grey"]::
# RED 		[x]: echo -e ""$grey"["$red"x"$grey"]::

#######################################################################################################################





### LAUNCH CHECKS #####################################################################################################

# Root permissions check:
if [ "$EUID" -ne 0 ]; then
	echo -e ""$grey"["$red"x"$grey"]::Hashish requires root permissions for proper operation. Please run as root with \"sudo hashish\"."
	exit
fi


# Argument check:
if [ -z "$*" ]; then
	echo -e ""$grey"["$red"x"$grey"]::You must supply hashish_server with a session name as an argument."
	exit 1
fi

#######################################################################################################################

session_name="$1"
echo -e "\nSession name is: "$session_name""
hash_type="$2"
echo -e "Hash Type is: "$hash_type" | Hashcat Mode: "
sleep 1


# clear
# When connecting to the Hashish Server remotely over SSH, your remote TTY may print out an error saying "TERM environment variable not set." This is normal. When SSH is executing in batch mode without an interactive user, a call to the 'clear' command in a startup script will yield this error. You can comment out the 'clear' command if you like. For the occasional local user or debugger, the clear command still exists.

#######################################################################################################################





##### CHECK FILE & DIRECTORY STRUCTURE ################################################################################

function_check_files_directories () {
# Check if each directory DOES NOT exist, and if they don't, exit 1 and abort.
echo -e "\n"$grey"Checking files and directories for proper structure..."



# config/
if [ ! -d ""$root_dir"/config/" ] ; then
	echo -e ""$grey"Configuration directory "$red"config/ "$grey"missing. Aborting."
	sleep 0.5
	exit 1
fi



# lib/
if [ ! -d ""$root_dir"/lib/" ] ; then
	echo -e ""$grey"["$red"x"$grey"]::"$yellow"/lib/ "$grey"directory missing, but Hashish requires it. Do you want Hashish to create the directory and populate it? This process will require internet downloads of a few hundred MBs. (Y/N)?" && read -r -p "[Y/N]?" response
	case "${response}" in
	    [yY][eE][sS]|[yY])

			# Make lib/ directory:
				echo -e ""$grey"Making directory: lib/"
				mkdir "$root_dir"/lib/
				echo -e ""$grey"["$green"+"$grey"]::Done."

			# Download the edited version of BEWGor:
				echo -e ""$grey"Downloading BEWGor..."
				wget https://raw.githubusercontent.com/xpelican/Hashish/master/hashish_server/lib/bewgor_edited.py && echo -e ""$grey"["$green"+"$grey"]::BEWGor installed." || echo -e ""$grey"["$red"x"$grey"]::BEWGor not installed properly!"

			# Download cap2hccapx:
				echo -e ""$grey"Downloading cap2hccapx.c..."
				wget https://raw.githubusercontent.com/hashcat/hashcat-utils/master/src/cap2hccapx.c && echo -e ""$grey"["$green"+"$grey"]::cap2hccapx installed." || echo -e ""$grey"["$red"x"$grey"]::cap2hccapx not installed properly!"

			# Download hashcat-3.6.0:
				echo -e ""$grey"Downloading Hashcat..."
				cd "$root_dir/lib/"
				wget 'https://hashcat.net/files/hashcat-3.6.0.7z'
				sleep 2
				echo -e ""$grey"Unpacking Hashcat..."
				sleep 0.5
				7z x hashcat-3.6.0.7z
				rm -f hashcat-3.6.0.7z
				cd "$root_dir"
				sleep 1
				echo -e ""$grey"["$green"+"$grey"]::Hashcat-3.6.0 installed."

			# Download hashcat-utils:
				echo -e ""$grey"Downloading hashcat-utils..."
				git clone https://github.com/hashcat/hashcat-utils && echo -e ""$grey"["$green"+"$grey"]::hashcat-utils installed." ||  echo -e ""$grey"["$red"x"$grey"]::hashcat-utils not installed properly!"
	        ;;
	    *)
			# if user doesn't want Hashish to install files needed in lib/, the program will give an error message and quit:
	        echo -e ""$grey"["$red"x"$grey"]::"$red"lib/ not found. Aborting." >&2; exit 1;
	        ;;
	esac
else
	echo -e ""$grey"["$green"+"$grey"]::lib/: Directory found."
fi



# log/
if [ ! -d ""$root_dir"/log/" ] ; then
	echo -e ""$yellow"/log/ directory missing. Creating..."
	sleep 0.5
	mkdir ""$root_dir"/log/"
	echo -e ""$green"[+]"$grey"::Done."
else
	echo -e ""$grey"["$green"+"$grey"]::log/: Directory found."
fi



# temp/
if [ ! -d ""$root_dir"/temp/" ] ; then
	echo -e $yellow"/temp/ directory missing. Creating..."
	sleep 0.5
	mkdir ""$root_dir"/temp/"
	echo -e ""$green"[+]"$grey"::Done."
else
	echo -e ""$grey"["$green"+"$grey"]::temp/: Directory found."
fi



# All files and directories checked and OK
sleep 1.5
echo -e ""$white"["$green"+"$white"]"$grey"::Files and directories in proper structure."
sleep 2
}

#######################################################################################################################





##### CHECK DEPENDENCIES ##############################################################################################
# aircrack-ng | BEWgor | crunch | findmyhash | hashcat | hashid | hashtag | postfix | python2 | mutt

function_check_dependencies () {
echo -e "\n"$grey"Checking dependencies..."
sleep 0.5



# Check aircrack-ng:
#if [[ ! command -v aircrack-ng > /dev/null 2>&1 ]]; then
#echo -e ""$grey"["$red"x"$grey"]::aircrack-ng not installed, but it is required." && sleep 0.5 && read -r -p "Do you want Hashish to install it [Y/N]?" response
#    case "${response}" in
#    [yY][eE][sS]|[yY])
#        sleep 1 && apt -y install aircrack-ng && echo -e ""$grey"["$green"+"$grey"]::hashid installed"
#        ;;
#    *)
#        echo -e ""$grey"["$red"x"$grey"]::"$red"Aborting." >&2; exit 1;
#        ;;
#    esac
#else
#        echo -e ""$grey"["$green"+"$grey"]::aircrack-ng installed"
#fi



# Check crunch:
if [ ! command -v crunch > /dev/null 2>&1 ]; then
echo -e ""$grey"["$red"x"$grey"]::crunch not installed, but it is required." && sleep 0.5 && read -r -p "Do you want Hashish to install it [Y/N]?" response
    case "${response}" in
    [yY][eE][sS]|[yY])
        sleep 1 && apt -y install crunch && echo -e ""$grey"["$green"+"$grey"]::crunch installed"
        ;;
    *)
        echo -e ""$grey"["$red"x"$grey"]::"$red"Aborting." >&2; exit 1;
        ;;
    esac
else
        echo -e ""$grey"["$green"+"$grey"]::crunch installed"
fi





# Check hashid:
if [ ! command -v hashid > /dev/null 2>&1 ]; then
echo -e ""$grey"["$red"x"$grey"]::hashid not installed, but it is required." && sleep 0.5 && read -r -p "Do you want Hashish to install it [Y/N]?" response
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





# Check mutt:
if [ ! command -v mutt > /dev/null 2>&1 ]; then
	echo -e ""$grey"["$red"x"$grey"]::mutt not installed, but it is required."
            sleep 1
            apt -y install mutt
            sleep 1
            echo -e ""$grey"["$green"+"$grey"]::mutt installed"
            mutt_config_file="~/.mutt/muttrc"
			            mkdir -p ~/.mutt/cache/headers
			            mkdir -p ~/.mutt/cache/bodies
			            touch ~/.mutt/certificates
			            touch "$mutt_config_file"
			            hashish_email_smtp_url=$(echo -e "$hashish_email_address" | cut -d@ -f 1)
			            echo -e "set ssl_starttls=yes
		set ssl_force_tls=yes
		set imap_user = '"$hashish_email_address"'
		set imap_pass = '"$hashish_email_password"'
		set from='"$hashish_email_address"'
		set realname='Hashish "$distro""$os"'
		set folder = imaps://imap.gmail.com:993/
		set spoolfile = imaps://imap.gmail.com/INBOX
		set postponed='imaps://imap.gmail.com/[Gmail]/Drafts'
		set header_cache = "~/.mutt/cache/headers"
		set message_cachedir = "~/.mutt/cache/bodies"
		set certificate_file = "~/.mutt/certificates"
		set smtp_url = 'smtp://"$hashish_email_smtp_url"smtp.gmail.com:"$hashish_email_smtp"'
		set move = no
		set imap_keepalive = 900" > "$mutt_config_file"
			sleep 1
			echo -e ""$grey"mutt configuration installed."
			cat "$mutt_config_file"
			read -r key
			sleep 1
else
        echo -e ""$grey"["$green"+"$grey"]::mutt installed"
fi




# Check Python2:
if [ ! command -v python2 > /dev/null 2>&1 ]; then
	echo -e ""$grey"["$red"x"$grey"]::python2 not installed, but it is required." && sleep 0.5 && read -r -p "Do you want Hashish to install it [Y/N]?" response
	    case "${response}" in
        [yY][eE][sS]|[yY])
            sleep 1 && apt -y install python2 && echo -e ""$grey"["$green"+"$grey"]::python2 installed"
            ;;
        *)
            echo -e ""$grey"["$red"x"$grey"]::"$red"Aborting." >&2; exit 1;
            ;;
	    esac
else
        echo -e ""$grey"["$green"+"$grey"]::python2 installed"
fi



# Check Postfix:
# apt install postfix mailutils libsasl2-2 ca-certificates libsasl2-modules
# First of all you need to install and configure Postfix to Use Gmail SMTP. | If you do not have postfix installed before, postfix configuration wizard will ask you some questions.
#	Check for a way to do a local portable installation of postfix in Hashish_Server/Lib/

# Check Graphics card requirements, required libs for vms?
# apt-get install libhwloc-dev ocl-icd-dev ocl-icd-opencl-dev
# apt-get install pocl-opencl-icd



sleep 1.5
# All dependencies checked and OK
echo -e ""$white"["$green"+"$white"]"$grey"::Dependencies installed"
sleep 0.5
}

#######################################################################################################################





##### READ & DETERMINE ENVIRONMENT VARIABLES ##########################################################################

function_learn_environment () {
echo -e "\n"$grey"Determining environment variables..."
sleep 0.5

# Get distro and OS information:
distro=$(lsb_release -i | awk '{print $3}')
os=$(uname)



# Read who is connected over SSH, define a variable for user information #(or who --ips)
server_IP=$(echo ""$SSH_CONNECTION"" | awk '{print $3}')
client_IP=$(echo ""$SSH_CONNECTION"" | awk '{print $1}')
# As it is, adding checks for server and client IPs are pointless since hashish_server currently only runs properly when connected to by SSH. These values will always be correct if someone is able to reach the server in the first place. These distinctions are here for future updates where running locally will be more stable and feasible.



# Check SSH Service Status, and start service if it's down:
echo -e ""$grey"\nChecking SSH status..."
sleep 0.3
if `service ssh status | grep -q inactive` ; then
    service ssh start
	echo -e ""$grey"["$green"+"$grey"]::SSH started by Hashish."
else
	echo -e ""$grey"["$green"+"$grey"]::SSH service is running."
fi



# Reporting to user about gathered environment variables
echo -e "\n"$grey"Running on:                 "$yellow" "$distro" "$os"."
sleep 0.5
echo -e "\n"$grey"Hashish Server IP address:  "$yellow" "$server_IP""
echo -e ""$grey"Hashish Client IP address:  "$yellow" "$client_IP""
sleep 2



# If user is on Kali Linux, let them know about it's possible problems with OpenCL:
if [ "$distro"="Kali" ] ; then
	echo -e ""$grey"["$yellow"-"$grey"]::"$yellow"!CAUTION!"$grey" You're running Kali Linux, infamous for not getting along well with OpenCL drivers for proper function with Hashcat. You're advised to use a different distro in case you have problems."
	sleep 3
fi



sleep 2

clear
}

#######################################################################################################################





### Send E-Mail ##############################################################################################

# This function is a direct copy of the first one from hashish_client. It is called right after this section, if hashish_server cannot find email information about the user, and user accepts prompt for local manual entry.
function_email_set () {
# Get user e-mail for later connection from the Hashish Server to user, when the hash is cracked.
echo -e "\n"$grey"Please enter the e-mail address you want Hashish to connect you at, and press [ENTER]:"$grey""
read user_email_address && echo "$user_email_address" > "$root_dir"/config/user_email_address.cfg 2>/dev/null
sleep 0.5

echo -e "\n"$grey"Please enter the e-mail address you want Hashish to use to send you mail, and press [ENTER]:"$grey""
read hashish_email_address && echo "$hashish_email_address" > "$root_dir"/config/hashish_email_address.cfg 2>/dev/null
sleep 0.5

echo -e "\n"$grey"Please enter password for the e-mail address Hashish will be using to send mail, and press [ENTER]:"
read hashish_email_password && echo "$hashish_email_password" > "$root_dir"/config/hashish_email_password.cfg 2>/dev/null
sleep 0.5

echo -e "\n"$grey"Please enter SMTP port number for e-mail server, and press [ENTER] (leave empty to default to 587):"
read hashish_email_smtp && echo "$hashish_email_smtp" > "$root_dir"/config/hashish_email_smtp.cfg 2>/dev/null
    if [ -z "$hashish_email_smtp" ] ; then
    	hashish_email_smtp="587"
    fi
}





function_email_send () {
echo -e "This is an automated message from your Hashish server at "$server_IP". Your hash has been cracked: "$hash_cracked"" |  mutt -s "Hashish Session Results for "$session_name"" "$user_email_address" 
sleep 1
}

#######################################################################################################################





### READ CONFIG FILES #################################################################################################

function_read_config () {
# Read the variables from config file at this point:
echo -e "\n"$grey"["$grey"!"$grey"]::Reading config file variables from "$yellow"config/"$grey"..."

# Get session name:
session_name=$(cat "$root_dir"/config/session_name.cfg)


# If session_name is empty, require user to actively enter it:
if [ -z "$session_name" ]; then
	echo -e "\n"$grey"["$yellow"-"$grey"]::No session name found!"
	echo -e ""$grey"Checking config/session_name.cfg for a saved session name written over scp..."
	session_name=$(cat "$root_dir"/config/session_name.cfg)

		if [ -z "$session_name" ]; then
			echo -e "\n"$grey"["$yellow"-"$grey"]::No session name found in ./config/session_name.cfg !"
			echo -e ""$grey"["$grey"!"$grey"]::Please enter a session name for your process and press [ENTER]:"
			read -r session_name
		fi

fi



# If session name exists in the logs, see if there's a hashcat restore file for it, and if there is, restore the hashcat session using the $session_name provided:
if [ -e "$root_dir"/log/"$session_name"-restore-file ] && [ -e "$root_dir"/log/"$session_name"-hashcat-commands.log ]; then
	echo -e "\n"$grey"["$yellow"-"$grey"]::Previous unfinished session found!"
	function_hashcat_continue_session
fi







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
            function_read_config
			;;
        *)
            echo -e ""$grey"["$yellow"x"$grey"]::Email settings not correct. Hashish will "$red"NOT "$grey"send email when your session finishes."
            status_will_send_email="false" ;
			;;
	    esac
else
	echo -e "\n"$white"["$green"+"$white"]::User email information is set."
	sleep 0.5
	echo -e ""$grey"User email address:    "$user_email_address""
	echo -e ""$grey"Hashish email address: "$hashish_email_address""
	echo -e ""$grey"Email password:        "$hashish_email_password""
	echo -e ""$grey"Email SMTP port #:     "$hashish_email_smtp""
	status_will_send_email="true"
fi
}





function_check_client_IP () {
# if client_IP can't be seen in the SSH_CONNECTION environment variable, then we look at the last visiting IP saved in /logs/client_IP.cfg
if [ -z "$client_IP" ]; then
	
	echo -e "\n"$grey"["$yellow"x"$grey"]::Client IP could not be determined by reading SSH_CONNECTION. Checking config files..."
	
	client_IP=$(cat "$root_dir"/config/client_IP.cfg)
	
	if [ -z "$client_IP" ]; then
		echo -e "\n"$grey"["$yellow"x"$grey"]::Client IP not set even after reading config files; Hashish must be running "$yellow"locally"$grey"."
	fi

fi
}

##### Note for update: find a way to store all these different details in a single config file. #######################
#######################################################################################################################





### HASH FILE, TYPE & NUMBER ################################################################################################

function_make_hashfile_temp () {
# The "last resort" function called below if neither a hash nor a hccapx file has been found:
echo -e ""$grey"["$white"!"$grey"]::"$yellow"This is your last chance to emergency-enter a new hash for Hashish. Type or paste your hash below, or press [CTRL+C] to exit."
read -r hashfile_temp
echo -e "$hashfile_temp" > "$root_dir"/temp/hashfile
}





function_hccapx_count () {
# Check to see there is only one hccapx file in the Hashish directory
# The Hashish client makes a backup of the original cap file during the initial transaction initiated by client. So no need to backup data before we begin

hccapx_count=$(find "$root_dir"/temp/ -name *.hccapx 2>/dev/null | wc -l)


if [ "$hccapx_count" -gt 1 ] ; then
	echo -e ""$red"[x]"$grey"Please place ONE hccapx file in the Hashish directory. Hashish will now stop. Open a TTY, navigate to "$root_dir" and remove the extra hccapx files, then press [ENTER] to retry."
	read key
	function_hccapx_count_checker
fi

if [ "$hccapx_count" -eq 1 ] ; then
	status_wpa_mode="true"
	hccapx_file=$(cd "$root_dir"/temp/ && ls --width=1 -a | grep -i .hccapx)
	echo -e ""$grey"["$green"+"$grey"]::"$grey"::hccapx file found: "$hccapx_file""
	sleep 2
fi

if [ "$hccapx_count" -lt 1 ] ; then
	status_wpa_mode="false"
	echo -e "\n"$grey"No hccapx file found. WPA cracking mode is "$yellow"off."
	sleep 2
fi

cd "$root_dir"
}





function_hashfile_check () {

if [ -z "$root_dir"/temp/hashfile ] ; then
	echo -e "\n"$grey"["$white"!"$grey"]::No hashfile found. Checking for a .hccapx WPA handshake capture file instead..."
	sleep 2
	echo -e ""$grey"Hashish will now allow you to manually enter a hash as a last resort. If this was a total fail, just hit [CTRL+C] and save yourself the shame."
	sleep 2
	function_make_hashfile_temp
	function_hashfile_check

else
	hashfile="$root_dir"/temp/hashfile
	target_hash=$(cat "$hashfile" 2>/dev/null)
	echo -e "\n"$grey"["$green"+"$grey"]::"$grey"Hashfile found. Your hash is: "$red""$target_hash""$grey""
fi
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
	hash_type=$(hashid -m "$root_dir"/temp/hashfile | head -n 3 | tail -1 | awk '{print $2}')
	hash_type_human_readable=$(hashid "$root_dir"/temp/hashfile | head -n 3 | tail -1 | awk '{print $4}')
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
echo -e "\n"$grey"If you know your hash type, please type it in ALL CAPS and Press ENTER."
echo -e ""$grey"Leave empty for automatic hash identification (less reliable)."
echo -e ""$grey"(You can also specify hashcat type number to use with the -m parameter)"
read hash_type_input

# TO-DO: This user-entered hash_type_input should ideally either be picked by the user from a pre-determined list of available hash modes, or
# OR, it should simply first of all go through a check against a list of strings (like "MD5,md5,NTLM,ntlm,..." to see if hash_type_input will indeed be a hashcat-supported type of hash.)


# First check if it's empty (implying use of HashID):
if [[ "$hash_type_input"='' ]]; then
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
		echo -e ""$grey"["$green"+"$grey"]::"$grey"::Hash type set."        ;;
    *)
        echo -e ""$red"[x]"$grey"Hash format not set. You will now be prompted to set it again."
        function_hash_type_determine
        ;;
    esac
}

#######################################################################################################################





### Collect Information & Generate Wordlists ##########################################################################

function_bewgor_launch () {
# hashish_server will be running over SSH. Can this type of command call be used through an SSH terminal, and return back to this main script after BEWgor is done? ### NEEDS TESTING!
echo -e ""$grey"Hashish will now launch BEWgor to form a target-specific wordlist"
sleep 1
python2 "$root_dir"/lib/BEWGor_Edited/b.py
}

#######################################################################################################################





### HASHCAT ###########################################################################################################

function_hashcat_continue_session () {
# The idea is to have this as a bootup check. If there's signs of a leftover session in log/, then this command will come in, prepare the information from the logs of that last session to form a new hashcat command to pick up where the last one left off, and go from there.
# For instance, hashcat commands in the hashcat_main section, each of them can include a line that writes currently attempted stage to a log file - so when the user comes back they can continue.
	echo -e "Continuing with previous Hashish session: "$session_name""
	cp "$root_dir"/log/"$session_name"* "$root_dir"/temp/
	hashcat --session "$session_name" --restore

}





function_check_outfile () {
# Use this function after each hashcat command in the HASHCAT section to check for results, and if they exist, email them to the user.
	sleep 2

	if [ -s "$root_dir"/temp/outfile_"$session_name".txt ] ; then
		hash_cracked_status="true"
		echo -e ""$green"Your hash has been cracked!"
		hash_cracked=$(cat "$root_dir"/temp/outfile_"$session_name".txt)
		echo -e ""$grey"It is: "$green""$hash_cracked""
		function_email_send
		exit 1
	fi
}





function_hashcat_main () {
# --markov-disable
# -t --markov-threshold
# --runtime <number>: Abort session after X seconds of runtime# pause

# len: Each word going into STDIN is parsed for its length and passed to STDOUT if it matches a specified word-length range.
# Syntax: ./len.bin <min> <max> <infile> <outfile>

# len.exe 2 4 < dictionary.txt > outfile.txt
# dictionary.txt dosyasindan 2, 3 veya 4 karakter uzunlugundaki ogeleri secip, outfile.txt dosyasina yazacak.

########################################################
## Hashcat Built-in Charsets ##########################
# (l, u, d, s : Lowercase, Uppercase, Digits, Symbols)
# ?l = abcdefghijklmnopqrstuvwxyz
# ?u = ABCDEFGHIJKLMNOPQRSTUVWXYZ
# ?d = 0123456789
# ?s = !”#$%&'()*+,-./:;⇔?@[\]^_`{|}~
# ?a = ?l?u?d?s
#######################################################



echo -e ""$grey"Hashish is now about to start launching password cracking attacks using "$blue"Hashcat"$grey"..."
sleep 3
echo -e "\n"$grey"Order of attacks:"

echo -e ""$grey"1st attack: Brute force with local charset, up to 7 characters."
echo -e ""$green"hashcat --session "$session_name" --restore-file-path "$root_dir"/log/"$session_name"-restore-file -m "$hash_type" --status --workload-profile 4 -a 3 -i --increment-min=1 --increment-max=7 --force --outfile "$root_dir"/temp/outfile_"$session_name".txt "$target_hash""

echo -e "\n"$grey"2nd attack: Quick Rockyou attempt."
echo -e ""$green"hashcat -m "$hash_type" --status --workload-profilse 4 -a 0 "$root_dir"/lib/wordlists/rockyou.txt --force --show --outfile "$root_dir"/temp/outfile_"$session_name".txt "$hashfile""

echo -e "\n"$grey"Press any key to start cracking."
read key




tmux new -s "$session_name" -n bewgor -d
tmux send-keys -t "$session_name":bewgor "python2 ~/Hashish_v"$hashish_version"/hashish_server/lib/BEWGor_Edited/b.py" ENTER C-b W
tmux select-window -t "$session_name":bewgor



# First attack; brute force with TR charset up to 7 characters: 
tmux new-window -t "$session_name" -n hashcat
tmux send-keys -t "$session_name":hashcat "hashcat --force --show -m "$hash_type" -a 3 "$target_hash"" ENTER
#hashcat --force --show --status --workload-profile 4 -i --increment-min=1 --increment-max=7 -m "$hash_type" -a 3 --outfile "$root_dir"/temp/outfile_"$session_name".txt "$target_hash"
tmux select-window -t "$session_name":hashcat



sleep 2
tmux select-window -t "$session_name":bewgor

tmux send-keys -t "$session_name":hashcat "hashcat --force --show --status --workload-profile 4 -m "$hash_type" -a 0 "$root_dir"/lib/wordlists/rockyou.txt --outfile "$root_dir"/temp/outfile_"$session_name".txt "$hashfile"" ENTER
tmux select-window -t "$session_name":hashcat


read -r -p "This is the first stopping prompt" key



sleep 3
#function_check_outfile
#clear



# 2nd attack: Quick Rockyou attempt:
#hashcat -m "$hash_type" --status --workload-profile 4 -a 0 "$root_dir"/lib/wordlists/rockyou.txt --force --show --outfile "$root_dir"/temp/outfile_"$session_name".txt "$hashfile"



sleep 3
#function_check_outfile
#clear



# 3rd attack: Custom wordlist
#function_bewgor_launch





# hashcat -m "$hash_type" --status --session "$session_name" --restore-file-path "$root_dir"/log/"$session_name"-restore-file --outfile "$root_dir"/outfile_"$session_name".txt --outfile-format 2 --workload-profile 4 -a 3 -i --increment-min=1 --increment-max=7 --show "$target_hash"
# hashcat --show --status --session "$session_name" --workload-profile 4 -i --increment-min=1 --increment-max=7 -1 "$root_dir"/lib/hashcat-3.6.0/charsets/turkish_ALL.hcchr --restore-file-path "$root_dir"/log/"$session_name"-restore-file --outfile "$root_dir"/outfile_"$session_name".txt --outfile-format 2 -m "$hash_type" -a 3 "$target_hash""

# Brute force 7 chars, Windows working tested command:
# hashcat64.exe --force --show --session testsession01 --workload-profile 4 -i --increment-min=1 --increment-max=7 --restore-file-path C:\Users\ybread\Desktop\testsession01_restore_file --outfile C:\Users\ybread\Desktop\testsession01_outfile.txt --outfile-format 2 -m 0 -a 3 5d41402abc4b2a76b9719d911017c592

}




function_hashcat_wpa2 () {
echo -e ""$grey"Hashish is now about to start launching password cracking attacks against your WPA handshake using "$blue"Hashcat"$grey"..."
sleep 3
echo -e "\n"$grey"Order of attacks:"

echo -e ""$grey"1st attack: Brute force with local charset, up to 7 characters."
echo -e ""$green"hashcat --force --show --status --session --workload-profile 4 --restore-file-path "$root_dir"/log/"$session_name"-restore-file --outfile "$root_dir"/log/"$session_name"_outfile.txt --outfile-format 2 --workload-profile 4 -a 3 -i --increment-min=1 --increment-max=7 --show "$wpa

}
############################################################################################################




### EXIT ############################################################################################################

function_exit () {
# Clean up unused temporary files and EXIT:
if [ "$hash_cracked_status"="true" ] ; then
	echo -e "\n"$grey"Your hash has been cracked - no need to log."
	echo -e "\n"$grey"Deleting everything from "$yellow"temp/"$grey""
	rm "$root_dir"/temp/*
else
	echo -e "\n"$grey"Copying all files in temp/ to "$yellow"log/"$session_date"_"$session_name"/..."
	mkdir "$root_dir"/log/"$session_name"
	cp "$root_dir"/temp/* "$root_dir"/log/"$session_name"/"$session_date"_"$session_name"

	echo -e ""$grey"Deleting the processed files for this session..."
	rm "$root_dir"/temp/*
	sleep 1
	echo -e ""$green"[+]"$grey"::Done."
	sleep 0.5
fi

echo -e "\n"$grey"Thank you for using Hashish Server! Exiting..."
sleep 2
exit
}

#######################################################################################################################





### EXECUTION OF FUNCTIONS ############################################################################################

function_learn_environment
sleep 1
function_read_config
sleep 1
function_check_client_IP
sleep 1
function_hccapx_count
sleep 1


#Check for WPA mode:
if [ "$status_wpa_mode" = "true" ] ; then
	function_hashcat_wpa2
else
	echo -e "this is a test. status_wpa_mode variable is: "$status_wpa_mode" | should be false if you're seeing this. Should move on to Hashfile checking right after this."
fi



# If operation has come this far, it must be a hash. Check for hashfile:
function_hashfile_check
sleep 2



# Extra step to determine hash type IF it isn't already determined:
# You can think of these functions like gatekeepers. For the final Hashcat code to work, it needs values for various variables that will become values in the Hashcat options. If any crucial ones don't exist, we prompt the user to enter them before the final operation.
if [ -z "$hash_type" ]; then
	function_hash_type_determine
fi


# At this point, all variables should have been set, and we can engage the Hashcat operations.
function_hashcat_main

sleep 2
function_exit

#######################################################################################################################
# md5/ hello: 5d41402abc4b2a76b9719d911017c592
# md5/ welcomehome: efeea535a2a71d4a380ba4d311686eca
#######################################################################################################################