# Buliga Theodor Ioan

# ETSISI, Universidad Politecnica de Madrid - 
# Operating Systems Administration 2023 - 2024

#! /bin/bash

#the function for a normal backup
function backupNormal() {
	# in case the directory /backups does not exist
	# I create it
	if [ ! -d /backups ]; then
		sudo mkdir /backups
		sudo touch /backups/backups.log
    	fi

	# in case there is no backups.log
	if [ ! -e "/backups/backups.log" ]; then
    	sudo touch /backups/backups.log
	fi

	# getting the directory path to backup
	read -p "Absolute path of the directory: " -r dir_name
	
	sudo chmod u+w /backups
	sudo chmod 777 /backups/backups.log

	# if the directory does not exist abort the backup
	if [ ! -d "$dir_name" ]; then
		echo "Invalid directory path. Backup aborted." >&2
		sudo echo "Invalid directory path: $dir_name" >> /backups/backups.log

		return 1
    fi
	
	echo "We will do a backup of the directory $dir_name."

	read -p "Do you want to proceed(y/n)? " -r response
	
	# abort if the answer is not yes
	if [ $response != "y" ]; then
		echo "Backup programming aborted."
		return 1
	fi
	
	# doing the actual backup

	# first setting the name
	backup_name=$(basename "$dir_name")-$(date +%y%m%d-%H%M).tgz
	echo " "

	# doing the actual backup using tar
	# redirecting the error to /dev/null in case there is one
    sudo tar -czf "/backups/$backup_name" "$dir_name" 2>/dev/null
}

# the function for backing up with cron
function backupCron() {
	read -p "Absolute path of the directory: " -r dir_name

	# if the directory does not exist abort the backup
	if [ ! -d "$dir_name" ]; then
		echo "Invalid directory path. Backup aborted." >&2
		sudo echo "Invalid directory path: $dir_name" >> /backups/backups.log

		return 1
    fi	
	
	read -p "Hour for the backup (0:00-23:59): " -r time
	read -p "The backup will execute at $hour. Do you agree? (y/n) " -r response
	
	# aborting if the answer is not yes
	if [ $response != "y" ]; then
		echo "Backup programming aborted."
		return 1
	fi
	
	# doing the actual backup with cron
	backup_name=$(basename "$dir_name")

	echo "$time"
	
	hour=${time%:*}
    	minute=${time#*:}

	date=$(date -d "$hour:$minute" '+%y%m%d-%H%M')

	echo $minute
	echo $hour

	#echo "$minute $hour * * * tar czf /home/student/Desktop/ASO/backups/$backup_name-$date.tgz $dir_name"
	#bash backupCron.sh $backup_name $dir_name 
	backup_command="$minute $hour * * * sudo bash /home/student/Desktop/ASO/backupCron.sh $backup_name $dir_name"
	
	(crontab -l ; echo "$backup_command") | sudo crontab -

	echo " "
}

#restore function
function restore() {
	# listing all the existent backups
    echo "The list of existing backups is:"
    ls /backups/*.tgz | xargs -n 1 basename
	
	# choosing which one to restore
    echo -n "Which one do you want to recover: "
    read backup_to_recover
	
	# checking if it was written correctly
    if [ -e "/backups/$backup_to_recover" ]; then
		# performing the restore
        echo "Restoring $backup_to_recover to the current directory..."
	
		# actual command for restoring
        sudo tar xzvf "/backups/$backup_to_recover" -C $PWD
        echo "Recovery of $backup_to_recover complete."
    else
		# otherwise displaying an error message
        echo "Error: Backup file $backup_to_recover does not exist."
    fi
}

# main loop
while true; do
	# displaying the information
	echo "ASO 2023 - 2024"
	echo "Buliga Theodor Ioan"
	echo " "

	echo "Backup tool for directories"
	echo "---------------------------"

	echo "Menu" 
	echo -e "\t1) Perform a backup"
	echo -e "\t2) Perform a backup with cron"
	echo -e "\t3) Restore the content of a backup"
	echo -e "\t4) Exit"

	echo " "
	#echo -e "\tOption:"

	# reading the option
	read -p $'\tOption: ' -r option

	# checking which option we go
	case $option in
		    1)
		        backupNormal
			echo " "
		        ;;
		    2)
		        backupCron
			echo " "
		        ;;
		    3)
		        restore
			echo " "
		        ;;
		    4)
		        echo "Exiting..."
		        exit 0
		        ;;
		    *)
		        echo "Invalid option. Please select again."
		        ;;
		esac
done
	


