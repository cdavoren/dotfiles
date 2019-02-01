# Linux Server Backup Notes

This file outlines the requirements for backup of my personal linux server.

```bash
cd ~
mkdir full-backup
```

## MySQL Database

```bash
mysqldump -u root -prootpassword --all-databases > ~/full-backup/mysql-all.sql
cd ~/full-backup
tar -cJf mysql-all.sql.tar.xz mysql-all.sql
rm mysql-all.sql
```

## Postgres Database

```bash
sudo su - postgres
pg_dumpall -W -f /tmp/postgres.sql
# You will have to enter your password multiple times - it's not an error
exit
cp /var/postgres.sql ~/full-backup
cd ~/full-backup
tar -cJf postgres.sql.tar.xz postgres.sql
rm postgres.sql
```

### Cron Backup Scripts

Most recent example script (backs up one database only, located in ```/var/lib/postgresql```):

```bash
#!/bin/bash

FILENAME_PREFIX=`date "+%Y-%m-%d-%T"`-backup

PSQL_INPUT_FILE="$FILENAME_PREFIX-commands.sql:"

rm -rf "$PSQL_INPUT_FILE"

touch "$PSQL_INPUT_FILE"

echo "\copy times_practiceperiod to '$FILENAME_PREFIX.csv' csv;" >> "$PSQL_INPUT_FILE"

psql ahpra < "$PSQL_INPUT_FILE"

rm "$PSQL_INPUT_FILE"
```

Then to copy backups:

```bash
cd /var/lib/
tar -cjf ~/full-backup/postgres-backup.tar.xz postgresql/*.csv postgresql/*.sh
```

## Git Repositories

Use the following bash scrupt (at e.g. ```~/workspace/backup-git-dirs.sh```):

```bash
#!/bin/bash

mkdir /tmp/git
for DIRECTORY in `ls -1`
do
    echo "$DIRECTORY"...
    tar -cJf /tmp/git/git-$DIRECTORY.tar.xz $DIRECTORY/
done
```

Then the following commands:

```bash
cd /Git
bash ~/workspace/backup-git-dirs.sh
...
mkdir ~/full-backup/git
cp /tmp/git/* ~/full-backup/git
```

## Personal Workspace 

```bash
cd ~
tar -cJf ~/full-backup/workspace.tar.xz workspace/
```

## Final Steps

To assist with downloading speed, zip the whole ```full-backup``` directory:

```
cd ~/
tar -cJf full-backup.tar-xz full-backup/
```

## Apache

### Site Configuration Files

```bash
cd /etc/apache2
tar -cJf ~/full-backup/apache-sites.tar.xz sites-available/ sites-enabled/
```

### Existing /www Directories

Use the following bash script (at e.g. ```~/workspace/backup-www-dirs.sh```):

```bash
#!/bin/bash

for DIRECTORY in `ls -1`
do
    echo "$DIRECTORY"...
    tar -cJf /tmp/www-$DIRECTORY.tar.xz $DIRECTORY/
done
```

Then use the following command sequence:

```bash
cd /var/www
bash ~/workspace/backup-www-dirs.sh
cp /tmp/www* ~/full-backup
```

## LetsEncrypt SSL Certificates

```bash
sudo su -
certbot certificates > /tmp/certificates.txt
cd /etc/
tar -cJf /tmp/letsencrypt.tar.xz letsencrypt/
exit
cd ~/full-backup
cp /tmp/certificates.txt .
cp /tmp/letsencrupt.tar.xz .
```

## Cron Scripts

```bash
sudo bash
cd /var/spool/cron
tar -cJx /tmp/crontabs.tar.xz crontabs/
exit
cp /tmp/crontabs.tar.xz ~/full-backup
```
##
