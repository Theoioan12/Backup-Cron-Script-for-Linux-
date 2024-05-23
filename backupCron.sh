# Buliga Theodor Ioan

# ETSISI, Universidad Politecnica de Madrid - 
# Operating Systems Administration 2023 - 2024

#! /bin/bash
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

	# if the directory does not exist abort the backup
	if [ ! -d "$2" ]; then
		echo "Invalid directory path. Backup aborted." >&2
		sudo echo "Invalid directory path: $dir_name" >> /backups/backups.log

		return 1
    fi
	
	sudo chmod u+w /backups
	sudo chmod 777 /backups/backups.log

# doing the actual backup
date=$(date '+%y%m%d-%H%M')
tar czf /backups/$1-$date.tgz $2