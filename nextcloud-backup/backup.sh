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

# Backup sequence:

# Preps
#   
# Backup of app_docker
# 1. Prep backup_dir
date 
mkdir -p $out_path
# 2. Turn maintinance mode on
#echo "$time - Turn maintinance mode on"
#docker exec $app_container php /nextcloud/occ maintenance:mode --on 
case $1 in
  images) 					# Make backup of docker images:
echo "$time - Saving images"
    for i in $images 
    do
    filename=$(echo $i|sed 's/[:/]/_/g')
    backup_dest=$out_path/$filename_image.tar.bz2
    echo "$time - Saving $i image to $backup_dest"
    docker save $i |pbzip2 -c -p4 > $backup_dest
    done
    ;;
  db)						# Make backup of database from docker container
    echo "$time - DB Backup start"
    echo "creating backup to $out_path/nextcloud.sql"
    docker exec $db_container sh -c 'exec /usr/bin/mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' > $out_path/nextcloud.sql
    ;;
  user_data)					# Make backup of user_data directory
    echo "$time - Backup user data directory from '$user_archive/' to '$out_path/user_archive.tar.bz2'"
#    tar cf $out_path/user_archive-$date.tar.bz2 --use-compress-prog=pbzip2 $user_archive/
    tar -c $user_archive/| pbzip2 -c -p4 > $out_path/user_archive.tar.bz2
    ;;
  *)
echo "Choose from 'images', 'db' and 'user_data'"
    ;;
esac
# 7. Turn maintinance mode off
#echo "$time - Turn maintinance mode off"
#docker exec $app_container php /nextcloud/occ maintenance:mode --off
time=`date +%H:%M:%S`
echo "$time - Backup process is DONE"

