# Install Notes for Django Projects

See separate notes on Ubuntu installation to set up network, updates, and Samba correctly.

## Configure Django Project

```bash
$ sudo apt install python3-pip
$ pip3 install virtualenv
$ sudo adduser davorian www-data

# For integration with apache WSGI later...
$ sudo apt install libapache2-mod-wsgi-py3

$ cd /var/www
$ sudo mkdir django-test
$ sudo chown django-test davorian:www-data
$ sudo chmod g+s django-test
$ cd django-test
$ virtualenv ./env
$ source ./env/bin/activate
$ python --version  # Should say 3.x.x
$ django-admin startproject djangotest .
$ vim ./djangotest/settings.py  # For VM add '192.168.56.101' to ALLOWED_HOSTS, otherwise add public IP / domain name
$ python manage.py runserver 0.0.0.0:8000
```

### Virtualenv and Python versions

If the Python minor version number is changed (e.g. from 3.5 to 3.6) then the symbolic links in the env directory will break.  For reasons I haven't figured out, the Apache-served version of the site will still work but the `manage.py` commands and just about everything else will break (really, this probably has something to do with Python pathing).

I should probably consider including a list of local packages including version numbers so that the environment can be rebuilt.  This list can be generated using:

```bash
pip freeze > package_list.txt
```

Then reconstituted using:

```bash
pip install -r package_list.txt
```

Taken from here: https://help.pythonanywhere.com/pages/RebuildingVirtualenvs/

TODO: This could probably be put in some kind of script.

## Template Extension

Example base template (with path e.g. `app/templates/app/base.html`):

```htmldjango
<html>
<head>
...
<title>{% block title %}{% endblock %}</title>
</head>
<body>
{% block content %}
{% endblock %}
</body>
</html>
```

Child templates inherit like so:

```htmldjango
{% extends 'app/base.html' %}

{% block title %}Page Title{% endblock %}
{% block content
  ...
{% endblock %}
```

### Custom Template Tags

Custom template tags go in the `[app]/templatetags` directory.  This directory must have an (empty) `__init__.py`.

The following lines must be included ins `settings.py`:

```python
TEMPLATE_LOADERS = {
    'django.template.loaders.app_directories.load_template_source',
}
```

The file must include at least:

```python
from django import template
from memoria.models import Item, Category

register = template.Library()

# Example filter:
@register.filter()
def make_item_list(value):
   ...
```

The template that is using the custom tags/filters must use:

```djangohtml
{% load [filter_filename] %}
```

## Static Files (including 'common' files)

Add the following to settings file:

```python
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')
STATICFILES_DIRS = (os.path.join(BASE_DIR, 'common-static'),)

# Don't know why this has to be set manually, since this is the documented 'default' value anyway:
# Note 09/12/2017: Apparently working without this, not sure why I had to add it to begin with?  Leave commented out for now.
"""
STATICFILES_FINDERS = [
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
]
"""
```

This allows common static files in the /common-static directory, referenced in templates as:

```htmldjango
{% load static %}
<link rel="stylesheet" href="{% static "/css/boostrap.css" %}" />
```

## Configure Postgres

`sudo su - postgres`

`psql`

```sql
CREATE DATABASE djangotest;
CREATE USER djangotestuser WITH PASSWORD 'djangotest';
ALTER ROLE djangotestuser SET client_encoding TO 'utf8';
ALTER ROLE djangotestuser SET default_transaction_isolation TO 'read committed';
ALTER ROLE djangotestuser SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE djangtest TO djangotestuser;
```
`\q`

```bash
exit
```

**Note:** To avoid __segmentation faults__ when using SSL (i.e. HTTPS), you must install psycopg from its source distribution.  This requires an additional library libpq-dev:

```bash
sudo apt install libpq-dev
pip3 install --no-binary psycopg2 psycopg2
```

More information available here: https://github.com/psycopg/psycopg2/issues/543

```python
vim djangotest/settings.py:
    DATABASES = {
        'default': {
            'ENGINE': 'django.db.backends.postgresql_psycopg2',
            'NAME': 'djangotest',
            'USER': 'djangotestuser',
            'PASSWORD': 'djangotest',
            'HOST': 'localhost',
            'PORT': '',
        }
    }
```

```bash
python manage.py makemigrations
python manage.py migrate
```

### psql Quick Reference

`\c [database-name]` - connect to database (same as `use [database-name]` in MySQL)

`\dt` - list all tables in database

`\d+ [table-name]` - list all fields for table

Change user password:

```sql
ALTER USER user PASSWORD password;
```

Delete user:

```sql
DROP USER user;
```

#### Dump and restore database (note Postgresql 10 output is not backwards compatible with Postgresql 9):

```bash
pg_dump [database] > [database].sql
```

To restore:

```bash
psql < [database.sql]
```

#### Export and restore table data (better backwards compatibility):

```
psql [database]
\copy my_table to 'my_table.csv' csv;
\q
```

Restore:

```
psql [database]
\copy my_table FROM 'my_table.csv' DELIMITER ',' CSV;
\q
```
### PostgreSQL CRONTAB Backup Script (Single Table)

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

#### Daily Crontab:

```
00    *       *       *       *       /var/lib/postgresql/backup.sh
```

## Configure Apache

Configuration required is for django (version 2.0 at time of writing)

Required packages:

```bash
$ sudo apt install libapache2-mod-wsgi-py3
```

Example host file:
```apache
<VirtualHost *:80>
        ServerName mother.rubikscomplex.net
        ServerAlias father.rubikscomplex.net

        ServerAdmin cdavoren@gmail.com
        DocumentRoot /var/www/money

        LogLevel warn

        ErrorLog ${APACHE_LOG_DIR}/money-error.log
        CustomLog ${APACHE_LOG_DIR}/money-access.log combined

        WSGIDaemonProcess djangomoney python-path=/var/www/money:/var/www/money/env/lib/python3.4/site-packages
        WSGIProcessGroup djangomoney
        WSGIScriptAlias / /var/www/money/money/wsgi.py

        Alias /static/ /var/www/money/static/

        <Location /static/>
                Options -Indexes
        </Location>

        <Directory /var/www/money/money>
                <Files wsgi.py>
                Order deny,allow
                Allow from all
                </Files>
        </Directory>
</VirtualHost>
```
### Helper Script

A helper script for creating virtual host files (ready for SSL & production):

```python
#!/usr/bin/env python3

import re

APPLICATION_DOMAIN_NAMES = ['testapp.net', 'testapp2.net']

fill_keys = {
    'APPLICATION_NAME' : 'testapp',
    'APPLICATION_ENV_DIR' : 'testapp',
    'PYTHON_VERSION' : "3.6",
    'SSL_CERT_LOCATION' :'/srv/test/test.crt',
    'SSL_KEY_LOCATION' : '/srv/test/test.key',
    'ADMIN_EMAIL' : 'cdavoren@gmail.com',
    'SERVER_REDIRECTS' : None,
    'SERVER_NAMES' : None,
}

VIRTUAL_HOST_TEMPLATE = """
<VirtualHost *:80>
#{SERVER_NAMES}

    ServerAdmin #{ADMIN_EMAIL}

    RewriteEngine on
#{SERVER_REDIRECTS}
</VirtualHost *:80>

<VirtualHost *:443>
#{SERVER_NAMES}

    ServerAdmin #{ADMIN_EMAIL}
    DocumentRoot /var/www/#{APPLICATION_NAME}

    LogLevel info
    ErrorLog ${APACHE_LOG_DIR}/#{APPLICATION_NAME}-error.log
    CustomLog ${APACHE_LOG_DIR}/#{APPLICATION_NAME}-access.log combined

    WSGIDaemonProcess #{APPLICATION_NAME}_daemon python-path=/var/www/#{APPLICATION_NAME}:/var/www/#{APPLICATION_NAME}/env-#{APPLICATION_ENV_DIR}/lib/python#{PYTHON_VERSION}/site-packages
    WSGIProcessGroup #{APPLICATION_NAME}_daemon
    WSGIScriptAlias / /srv/#{APPLICATION_NAME}/#{APPLICATION_NAME}-wsgi.py

    Alias /static/ /var/www/#{APPLICATION_NAME}/static/
    <Location /static/>
        Options -Indexes
    </Location>

    SSLEngine on
    SSLProtocol all -SSLv2 -SSLv3
    SSLOptions +StrictRequire

    SSLCertificateFile #{SSL_CERT_LOCATION}
    SSLCertificateKeyFile #{SSL_KEY_LOCATION}
    </VirtualHost *:443>
    """
if __name__ == '__main__':
    server_names = []
    for i, n in enumerate(APPLICATION_DOMAIN_NAMES):
        if i == 0:
            server_names.append('    ServerName ' + n)
        else:
            server_names.append('    ServerAlias ' + n)

    fill_keys['SERVER_NAMES'] = '\n'.join(server_names)

    server_redirects = []
    for n in APPLICATION_DOMAIN_NAMES:
        server_redirects.append('    RewriteCond %{SERVER_NAME} ='+n+'\n'+ \
            '    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]')
    fill_keys['SERVER_REDIRECTS'] = '\n'.join(server_redirects)

    template_filled = VIRTUAL_HOST_TEMPLATE
    for key in fill_keys.keys():
        print(key)
        rx = '\\#\\{'+key+'\\}'
        template_filled = re.sub(rx, fill_keys[key], template_filled)
    print(template_filled)
```

## Install SASS

Enter the following commands:

```bash
sudo apt install ruby-dev rubygems

sudo gem install sass

sass --watch /path/to/scss:/path/to/outputcss
```

## Deployment

For deployment, sensitive data such as database access credentials and the SECRET_KEY should not be stored in settings.py (i.e. in the *source repository*).  They can be accessed using **environment variables**, but note that the usual Apache environment settings don't work with WSGI.  The solution is to use a separate wsgi.py stored *outside* the application directory, in e.g. `/srv`.  

An additional advantage of this solution is that it allows `python manage.py` calls on the server to reference the server-specific configuration if required, by setting the relevant environment variable beforehand.

Steps:

1. Enable access to `/srv/` in the global `/etc/apache2/apache2.conf` file:
    ```apache
    <Directory /srv/>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
    ```
1. Create the new wsgi.py file e.g. `/srv/skilldrive/skilldrive-wsgi.py` with the environment settings:
    ```python
    """
    WSGI config for skilldrive project.

    It exposes the WSGI callable as a module-level variable named ``application``.

    For more information on this file, see
    https://docs.djangoproject.com/en/2.0/howto/deployment/wsgi/
    """

    import os

    from django.core.wsgi import get_wsgi_application

    os.environ['SKILLDRIVE_ADDITIONAL_SETTINGS'] = '/srv/skilldrive/settings.py'
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "skilldrive.settings")

    application = get_wsgi_application()
    ```
1. Create the server-specific settings file to be read e.g. `/srv/skilldrive/settings.py' (example for SSL/HTTPS):
   ```python
   SECRET_KEY = 'special value'

   ALLOWED_HOSTS = ['skilldrive.rubikscomplex.net']

   DATABASES = {
       'default': {
           'ENGINE' : 'django.db.backends.postgresql_psycopg2',
           'NAME' : 'skilldrive',
           'USER' : 'skilldriveuser',
           'PASSWORD' : 'skilldrive20171207',
           'HOST' : 'localhost',
           'PORT' : '',
       }
   }

   # Remote logging with Sentry
   INSTALLED_APPS.append('raven.contrib.django.raven_compat')
   RAVEN_CONFIG = {
       'dsn' : '--value--',
       'release' : raven.fetch_git_sha(BASE_DIR),
   }

   # SSL settings
   SECURE_HSTS_SECONDS=1
   SECURE_HSTS_PRELOAD=True
   SECURE_HSTS_INCLUDE_SUBDOMAINS=True

   # Because manage.py check --deploy said so
   SECURE_CONTENT_TYPE_NOSNIFF=True
   SECURE_SSL_REDIRECT=True
   SECURE_BROWSER_XSS_FILTER=True
   SESSION_COOKIE_SECURE=True
   CSRF_COOKIE_SECURE=True
   X_FRAME_OPTIONS='DENY'

   DEBUG=False
   ```
1. Set the virtual host config to use this file instead of the original in the relevant config e.g. `/etc/apache2/sites-available/003-skilldrive.conf`:
    ```apache
    WSGIScriptAlias / /srv/skilldrive/skilldrive-wsgi.py

    ...

    <Directory /srv/skilldrive/>
        <Files skilldrive-wsgi.py>
            Order deny,allow
            Allow from all
        </Files>
    </Directory>
    ```
1. Add the following to the **end** (to allow overriding of default values) of settings.py to facilitate use the external file specified by the environment variable:
    ```python
    if os.environ.get('SKILLDRIVE_ADDITIONAL_SETTINGS') is not None:
        exec(open(os.environ.get('SKILLDRIVE_ADDITIONAL_SETTINGS')).read())
    ```

