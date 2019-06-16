#!/bin/bash

##############################
# LINUX SERVER BACKUP SCRIPT #
##############################

# Current as at 16th June 2019.

# Run as root  

GIT_DIR=git

TIMESTAMP=`date +%F`
BACKUP_DIR="/tmp/backup-$TIMESTAMP"

mkdir -pv $BACKUP_DIR

# 1 - Git Repository Backup
# -------------------------

echo '1 - Git Repository Backup ...'

tar -C / -chf "$BACKUP_DIR/git.tar.xz" $GIT_DIR

echo '    Done.'

# 2 - MySQL Backup
# ----------------

echo '2 - MySQL Backup ...'

MYSQL_DATABASE_IGNORE="Database information_schema performance_schema mysql sys"
MYSQL_USER=root
export MYSQL_PWD=fred

MYSQL_DATABASES=`echo 'show databases;' | mysql -u$MYSQL_USER`
MYSQL_DIR=$BACKUP_DIR/mysql

mkdir -pv $MYSQL_DIR

for DATABASE in $MYSQL_DATABASES
do
    if [[ "$MYSQL_DATABASE_IGNORE" =~ "$DATABASE" ]];
    then
        continue
    fi
    FILENAME="${MYSQL_DIR}/mysql-$DATABASE.sql"
    echo "    Backing up $DATABASE --> $FILENAME ..."
    mysqldump -u$MYSQL_USER $DATABASE > $FILENAME
done

# 3 - PostgreSQL Backup
# ---------------------

echo '3 - PostgreSQL Backup ...'

POSTGRES_DATABASES=`su - postgres -c "echo 'select datname from pg_database where datistemplate = false;' | psql -t" `
POSTGRES_DATABASE_IGNORE='postgres'
POSTGRES_DIR=$BACKUP_DIR/postgres

mkdir -pv $POSTGRES_DIR

# Allow writing from postgres user
chmod a+w $POSTGRES_DIR

for DATABASE in $POSTGRES_DATABASES
do
    if [[ "$POSTGRES_DATABASE_IGNORE" =~ "$DATABASE" ]];
    then
        continue
    fi
    FILENAME="${POSTGRES_DIR}/postgres-$DATABASE.sql"
    echo "    Backing up $DATABASE --> $FILENAME ..."
    sudo su postgres -c "pg_dump -f \"$FILENAME\" \"$DATABASE\" "
done

chmod go-w $POSTGRES_DIR

# 4 - SQLite Backup
# -----------------

echo '4 - SQLite backup ...'

updatedb
SQLITE_DATABASE=`locate db.sqlite`

SQLITE_DIR=$BACKUP_DIR/sqlite

mkdir -pv $SQLITE_DIR

for DATABASE_PATH in $DATABASES
do 
    DATABASE_NAME=`basename $(dirname $DATABASE_PATH)`
    FILENAME="${SQLITE_DIR}/sqlite-$DATABASE_NAME.sql"
    echo "    Backing up $DATABASE_PATH --> $FILENAME ..."
    sqlite3 $DATABASE_PATH .dump > $FILENAME
done

# 5 - Home Directory Backup
# -------------------------

echo '5 - Home directory backup ...'

USERNAME='davorian'
HOME_DIR=/home/$USERNAME

declare -a files
while IFS= read -r -d '' n; do
    files+=( "$n" )
done < <(cd $HOME_DIR && find . -maxdepth 1 -type f -print0)

files+=("workspace/")
files+=(".ssh/")
files+=(".vim/")

mkdir -pv $BACKUP_DIR/home

tar -C $HOME_DIR -chf $BACKUP_DIR/home/home-$USERNAME.tar.xz "${files[@]}"

tar -C / -cf $BACKUP_DIR/home/root.tar.xz root

POSTGRES_DIR='/var/lib/postgresql'

tar -C $POSTGRES_DIR -cf $BACKUP_DIR/home/postgresql.tar.xz --exclude='10' .

echo '    Done.'

# 6 - Apache Backup
# -----------------

echo '6 - Apache backup ...'

APACHE_DIR=/etc/apache2

mkdir -pv $BACKUP_DIR/apache2

tar -C $APACHE_DIR -cf $BACKUP_DIR/apache2/apache2-sites.tar.xz sites-available/ sites-enabled/

echo '    Done.'

# 7 - www Backup
# --------------

echo '7 - www backup ...'

mkdir -pv $BACKUP_DIR/www

tar -C /var/www -cf $BACKUP_DIR/www/www.tar.xz `cd /var/www && ls -1`

echo '    Done.'

# 8 - Django Additional Configuration Backup
# ------------------------------------------

echo '8 - Django additional configuration backup ...'

mkdir -pv $BACKUP_DIR/django

DJANGO_DIRECTORIES=`cd /srv && ls -1 -I git`

for DIRECTORY in $DJANGO_DIRECTORIES
do
    FILENAME=${BACKUP_PREFIX}/django-$DIRECTORY.tar.xz
    echo "    Backing up $DIRECTORY --> $FILENAME ..."
    tar -C /srv -cf $FILENAME $DIRECTORY
done

# 9 - LetsEncrypt Certificate Backup
# ----------------------------------

echo '9 - LetsEncrypt certificate backup ...'

mkdir -pv $BACKUP_DIR/letsencrypt

tar -C /etc/letsencrypt -cf $BACKUP_DIR/letsencrypt/letsencrypt.tar.xz .

certbot certificates > $BACKUP_DIR/letsencrypt/certificates.txt 2> /dev/nullt 

echo '    Done.'

# 10 - Cron scripts
# -----------------

echo '10 - Cron script backup ... '

mkdir -pv $BACKUP_DIR/cron

tar -C /var/spool/cron -cf $BACKUP_DIR/cron/crontabs.tar.xz crontabs

echo '     Done.'

# 11 - Final Archive
# ------------------

echo '11 - Final archive ...'

FULL_ARCHIVE_FILENAME=full-$(date +%F).tar.xz

rm -vf $BACKUP_DIR/$FULL_ARCHIVE_NAME
tar -C /tmp -cf /tmp/$FULL_ARCHIVE_FILENAME $(basename $BACKUP_DIR)
mv -v /tmp/$FULL_ARCHIVE_FILENAME $BACKUP_DIR

echo '     Done.'
