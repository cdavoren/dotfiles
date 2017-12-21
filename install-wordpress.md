# WordPress Installation

Date: 20th December 2017
WordPress version: 4.9.1

## Download WordPress

Download latest tarball from the [WordPress home page](https://wordpress.org/download/).

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