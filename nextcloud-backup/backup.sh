#!/bin/sh

###  Variables:
## Local variables:
## Path to backup folder:
date=`date +%Y-%m-%d` 
out_path="/backup/nextcloud/$date"
home_dir="/home/centos/nextcloud"
passwords="./nextcloud.password"
## Docker variables:
## Application docker container:
#   Tag of application docker container:
app_tag="nextcloud"
app_image="wonderfall/nextcloud"
#   Path to source dir in app_docker:
user_archive=$home_dir/data/data

## Database docker container:
#   Tag of DB docker container:
db_tag="db_nextcloud"
db_image="mysql/mysql-server"
#   DB name in DB docker container:
db_name="nextcloud"

#   Username and password of DBA in db_docker:
. $passwords

## Backup sequence:

# Preps
#   
# Backup of app_docker
# 1. Prep backup_dir
date 
mkdir $outpath
# 2. Turn maintinance mode on
docker exec $app_tag php /nextcloud/occ maintenance:mode --on 
case $1 in
	images)
# 3. Make backup of application docker image 
docker save $app_image |pbzip2 -c -p4 > $outpath/$app_image-$date.tar.bz2
# 4, Make backup of database docker image
docker save $db_image |pbzip2 -c -p4 > $outpath/$db_image-$date.tar.bz2;;
	db)
# 5. Make backup of database from docker container
;;
	user_data)
# 6. Make backup of user_data directory
;;
	*)
echo ""
esac
# 7. Turn maintinance mode off
docker exec $app_tag php /nextcloud/occ maintenance:mode --off
echo "Backup process is DONE"

