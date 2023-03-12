# WordPress Installation

Date: 24th December 2022

WordPress version: 6.1.1

**Note:** Due to tight coupling between WordPress settings and the hosted domain, it is better use the WordPress installation process on each host.  You'll need to *export* posts from the old install if migrating - this can be done from the administration section.

## Download WordPress

Download latest tarball from the [WordPress home page](https://wordpress.org/download/).

## Installing PHP and/or MySQL

On the Linode server, the default 17.10 install didn't include PHP, MySQL, or the PHP-MySQL extension.  To install:

```bash
sudo apt install mysql-server php php-mysql

sudo systemctl restart apache2
```

## MySQL Configuration

WordPress is strongly coupled to MySQL, so alternatives (e.g. PostreSQL) are not really feasible without a lot of messing around.  Also plugins are reliant on MySQL-specific syntax/features so that will complicate things.

There have been pushes for development to solve this problem; I found more information on the offical site [here](https://codex.wordpress.org/Using_Alternative_Databases).

Create the WordPress database and user:

```sql
CREATE DATABASE wordpressblog;
GRANT ALL PRIVILEGES ON wordpressblog.* TO "wordpressbloguser"@"localhost" IDENTIFIED BY "wordpressbloguser20171220";
FLUSH PRIVILEGES;
```

## Apache Configuration

This VirtualHost config was amalgamated hurredly from 2 or 3 sources, with some educated guesses.  TODO: To verify formally.

```apache
<VirtualHost *:80>
        ServerAdmin cdavoren@gmail.com
    DocumentRoot /var/www/wordpress-blog

    ServerName blog.ubuntuvm.net

    LogLevel warn
    ErrorLog ${APACHE_LOG_DIR}/wordpress-blog-error.log
    CustomLog ${APACHE_LOG_DIR}/wordpress-blog-access.log combined

    DirectoryIndex index.html, index.php
    DocumentRoot /var/www/wordpress-blog

    AccessFileName .htaccess

    <Directory /var/www/wordpress-blog>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Order deny,allow
    </Directory>

</VirtualHost>
```

### Password Protection

Examle `.htaccess` file:

```apache
AuthType Basic
AuthName "Password Required"
AuthUserFile "/var/www/apache-passwords/password.file"
Require user admin
```

**Note:** Using a `.htaccess` file requires the `AllowOverride All` setting in the `<Directory>` config.

## Configuring WordPress

Use the default installation script: navigate to the root and the config should be invoked automatically.

## Importing Old Posts

Can be done using the import function under "Tools" in the administration section.  You have to install the [WordPress Importer plugin](https://en-au.wordpress.org/plugins/wordpress-importer/).

## FTP Access

WordPress requires direct FTP access to the server if you are intending to perform automatic upgrades.  For Ubuntu, this can be facilitated via the vsftpd service:

```bash
sudo install vsftpd
```

There will need to be some initial configuration in the `/etc/vsftdp.conf` file.  In the latest version as at 24/12/2022 on Ubuntu 22.04, the relevant options were:

```
listen=YES
listen_port=21
anonymous_enable=NO
local_enable=YES
write_enable=YES
```

When prompted by WordPress for FTP credentials, you should provide the same user and password as that of the WordPress directory itself.
