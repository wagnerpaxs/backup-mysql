#!/bin/bash
#
# MySQL Database Backup
#
# Autor: Wagner Santos <wagner@xarx.co>
# Version: 0.1

set -e

if [ -e ./mysql.conf ]; then
	. ./mysql.conf

	if [ ! -d $BACKUP_PATH ]; then
		echo "Creating backup directory: $BACKUP_PATH"
		mkdir $BACKUP_PATH
		mkdir -p $BACKUP_PATH/full
		mkdir -p $BACKUP_PATH/single
	fi

	if [ -e ./databases.conf ] ; then
		for DBNAME in `cat databases.conf`; do
			if [ ! -d "$BACKUP_PATH/single/$DBNAME" ]; then
				mkdir -p $BACKUP_PATH/single/$DBNAME
			fi
			BACKUPFILEPATH="$BACKUP_PATH/single/$DBNAME"
			FILENAME="$DBNAME-`date "+%Y%m%d_%H%M%S"`.sql"
		
			echo "Making backup for: $DBNAME"
			echo "Start: `date "+%Y-%m-%d %H:%M:%S"`"
			$MYSQLDUMP -h $DBHOST -u $DBUSER -p$DBPASS $DBNAME > $BACKUPFILEPATH/$FILENAME

			echo "Compressing File..."
			cd $BACKUPFILEPATH
			$TAR cfj $FILENAME.tar.bz2 $FILENAME
			rm $FILENAME
			echo "Finish: `date "+%Y-%m-%d %H:%M:%S"`"
			cd $CURRENT_PATH
		done
	fi

	# Backup All Databases
	BACKUP_ALL_DBS="backup-all-`date "+%Y%m%d_%H%M%S"`.sql"
	echo "Making Full Databases Backup... | Start: `date "+%Y-%m-%d %H:%M:%S"`"
	$MYSQLDUMP $PARAMS -h $DBHOST -u $DBUSER -p$DBPASS > $BACKUP_PATH/full/$BACKUP_ALL_DBS
	echo "Compressing File..."
	cd $BACKUP_PATH/full
	$TAR cfj $BACKUP_ALL_DBS.tar.bz2 $BACKUP_ALL_DBS
	rm $BACKUP_ALL_DBS
	cd $CURRENT_PATH
	echo "Backup Finished at: `date "+%Y-%m-%d %H:%M:%S"`"
else
	echo ""
	echo "Configuration file not found!"
	echo ""
	exit 1;
fi

