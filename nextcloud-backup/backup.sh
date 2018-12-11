#!/bin/bash

###  Variables:
## Local variables:
## Path to backup folder:
date=`date +%Y-%m-%d`
time=`date +%H:%M:%S` 
out_path="/backup/nextcloud/$date"
home_dir="/home/centos/nextcloud"
passwords="./nextcloud.password"
## Docker variables:
images=(wonderfall/nextcloud,mariadb:10) 		# List of nextcloud images
user_archive=$home_dir/data/data 			# Path to source dir in app_docker
IFS=$','
app_container="nextcloud"
## Database docker container:
db_container="db_nextcloud" 				# Name of DB docker container:
db_name="nextcloud" 					# DB name in DB docker container

#   Username and password of DBA in db_docker:
. $passwords
# Backup sequence:

# Preps
#   
# Backup of app_docker
# 1. Prep backup_dir
date 
mkdir -p $out_path
# 2. Turn maintinance mode on
echo "$time - Turn maintinance mode on"
docker exec $app_container php /nextcloud/occ maintenance:mode --on 
case $1 in
  images) 					# Make backup of docker images:
echo "$time - Saving images"
    for i in $images 
    do
    echo "$time - Saving $i image" 
    docker save $i |pbzip2 -c -p4 > $outpath/$i-$date.tar.bz2 
    done
    ;;
  db)						# Make backup of database from docker container
echo "$time - DB Backup"
#docker exec $db_container /usr/bin/mysqldump -u $dba_user --password=$dba_pass nextcloud > backup.sql
    ;;
  user_data)					# Make backup of user_data directory
echo "backup user data directory"
    ;;
  *)
echo "Choose from 'images', 'db' and 'user_data'"
    ;;
esac
# 7. Turn maintinance mode off
echo "$time - Turn maintinance mode off"
docker exec $app_container php /nextcloud/occ maintenance:mode --off
echo "$time - Backup process is DONE"

