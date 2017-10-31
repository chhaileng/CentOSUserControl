#!/bin/sh
# Group 6
#  Peng Chhaileng
#  Phang Ratanak
#  Ret Sokheang
#  On Bunthoeurn
#  Heng Bunhak
#  Phot Pheanitya
#  Kev Chhunly


# Functions Area
check_root_user() {
	if [ "$EUID" -ne 0 ]
		then echo "[-] Permission denied! Are you root?"
		exit
	fi
}

menu() {
	echo "#--------------------MENU---------------------"
	echo "#     1. Create Users from File               "
	echo "#     2. Delete User                          "
	echo "#     3. Update User                          "
	echo "#     4. Create Group                         "
	echo "#     5. Delete group                         "
	echo "#     6. Add User to Group                    "
	echo "#     7. Show all users in system             "
	echo "#     8. Show all groups in system            "
	echo "#     9. Show account information             "
	echo "#     0. Exit                                 "
	echo -n "#     Choose options: "
}

menu_update_user() {
	echo "#--------------------MENU---------------------"
	echo "#     1. Update Information                   "
	echo "#     2. Change Password                      "
	echo "#     3. Add Description to User              "
	echo "#     4. Change Username (Login Name)         "
	echo "#     0. Back                                 "
	echo -n "#     [Update User] options: "
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
					add_user ${record[0]} ${record[1]}
					count=`expr $count + 1`
				done
				pause "Press enter to continue..."
			;;
			"2")	read -p "[*] Enter username: " usr
				userdel -r $usr > /dev/null 2>&1
				del_status=$?
				if [ $del_status -eq 0 ]; then
					echo "[+] User $usr deleted successfully!"
				else
					echo "[-] User $usr is not exist!"
				fi
				pause "Press enter to continue..."
			;;
			"3")	read -p "[*] Enter username: " usr
				id $usr > /dev/null 2>&1
				usr_status=$?
				if [ $usr_status -eq 0 ]; then
					while true
					do
						menu_update_user
						read c
						case $c in
							"1")	chfn $usr
								pause "Press enter to continue..."
							;;
							"2")	passwd $usr
								pause "Press enter to continue..."
							;;
							"3")	read -p "[*] Description (no space): " cmt
								usermod -c $cmt $usr
								cat /etc/passwd | grep $usr
								pause "Press enter to continue..."
							;;
							"4")	read -p "[*] Enter new username: " n_usr
								usermod -l $n_usr $usr
								echo "[+] Username update successfully!"
								pause "Press enter to continue..."
							;;
							"0")	break
							;;
						esac
						clear
					done
				else
					echo "[-] User $usr is not exist!"
					pause "Press enter to continue..."
				fi
			;;
			"4")	#clear
				read -p "[*] Enter group name: " gro
				groupadd $gro
				pause "Press enter to continue..."
			;;
			"5")	#clear
				read -p "[*] Enter group name: " gro
				groupdel $gro
				pause "Press enter to continue..."
			;;
			"6")	#clear
				read -p "[*] Enter group name: " gro
				read -p "[*] Enter user name: " usr
				usermod -G $gro $usr
				pause "Press enter to continue..."
			;;
			"7")	clear
				cut -d: -f1 /etc/passwd
				pause "Press enter to continue..."
			;;
			"8")	clear
				cat /etc/group
				pause "Press enter to continue..."
			;;
			"9")	#clear
				read -p "[*] Enter username: " usr
				id $usr > /dev/null 2>&1
				usr_status=$?
				if [ $usr_status -eq 0 ]; then
					chage -l $usr
					pause "Press enter to continue..."
				else
					echo "[-] User not found!"
					pause "Press enter to continue..."
				fi
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
	read -p "[*] Enter users file name (users.txt): " file_name
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

