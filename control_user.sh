#!/bin/sh
#Group 6


# Functions Area
check_root_user() {
	if [ "$EUID" -ne 0 ]
		then echo "[-] Permission denied! Are you root?"
		exit
	fi
}
#cut -d: -f1 /etc/passwd
menu() {
	echo "#--------------------MENU---------------------"
	echo "#     1. Create User from File                "
	echo "#     2. Delete User                          "
	echo "#     3. Update User                          "
	echo "#     4. Create Group                         "
	echo "#     5. Add User to Group                    "
	echo "#     0. Exit                                 "
	echo -n "#     Choose options: "
}
pause() {
	echo -n $1
	read
}

add_user() {
	egrep "^$1" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "[-] User $1 exists!"
	else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $2)
		useradd -m -p $pass $1
		[ $? -eq 0 ] && echo "[+] User has been added to system!" || echo "[-] Failed to add a user!"
	fi
}

controller() {
	users=()
	while IFS='' read -r user || [[ -n "$user" ]]; do
		if ! [ -z $user ]; then
   			users+=("$user")
		fi
	done < "$1"
	echo "[+] Found ${#users[@]} users"
	while true
	do
		menu
		read choose
		case $choose in 
			"1")	count=1
				for i in ${users[@]}
				do
					IFS=':' read -ra record <<< "$i"
					echo "User record : $count"
					echo "Username: ${record[0]}"
					echo "Password: ${record[1]}"
					read -p "[*] Create this user? [y/*/exit]: " yn
					if [ "$yn" == "y" -o "$yn" == "Y" ]; then
						add_user ${record[0]} ${record[1]}
					elif [ "$yn" == "exit" ]; then
						break
					else
						echo "[-] Create user canceled!"
					fi
					pause "Press enter to continue..."
					clear
				done
			;;
			"2")	echo "2"
				pause "Press enter to continue..."
			;;
			"0") exit
			;;
			*) echo "Command Not Found"
			;;		
		esac
		clear
	done
}

main() {
	read -p "[*] Enter users file name (blank if users.txt): " file_name
	#file_name="users.txt"

	if [ -z $file_name ]; then
		file_name="users.txt"
	fi

	if ! [ -s $file_name ]; then
		echo "[-] File $file_name is not found!"
	else
		echo "[+] Using file $file_name..."
		echo "[+] Reading user from file..."

		controller $file_name
	fi
}

# Main Area
check_root_user

main

