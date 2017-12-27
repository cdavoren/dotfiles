# Install Notes for Ubuntu Server

Notes for Ubuntu Server 17.10

Valid as at 7th December 2017.

## Enable host-only network interface

/etc/netplan/01-netcfg.yaml - add:
```json
enp0s8:
    dhcp4: yes
```

## Disable automatic updates

/etc/apt/apt.conf.d/10periodic - change:

`APT::Periodic::Update-Package-Lists "0";`

## Configure Samba

**/etc/samba/smbd.conf:**

```conf
[davorian]
   comment = home
   path = /home/davorian
   browseable = yes
   read only = no
   guest only = no
   valid users = davorian

[www]
   comment = www
   path = /var/www
   browseable = yes
   read only = no
   guest only = no
   valid users = davorian
```

`sudo smbpasswd -a davorian`

`sudo systemctl restart smbd`

## Disable Network Wait Error

`sudo systemctl disable systemd-networkd-wait-online.service`

`sudo systemctl mask systemd-networkd-wait-online.service`

## Configure Django Project

```
sudo apt install python3-pip

sudo adduser davorian www-data

cd /var/www

sudo mkdir django-test

sudo chown django-test davorian:www-data

sudo chmod g+s django-test

cd django-test

virtualenv ./env

source ./env/bin/activate

python --version (should say 3.x.x)

django-admin startproject djangotest .

vim ./djangotest/settings.py - add '192.168.56.101' to ALLOWED_HOSTS

python manage.py runserver 0.0.0.0:8000
```
### Template Extension

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

### Static files including common

Add the following to settings file:

```python
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')
STATICFILES_DIRS = (os.path.join(BASE_DIR, 'common-static')

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


exit

pip3 install psycopg2
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

## Configure Apache

Configuration required is for django (version 2.0 at time of writing)

Install required packages:
sudo apt install libapache2-mod-wsgi-py3

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

## Install SASS

Enter the following commands:

```bash
sudo apt install ruby-dev rubygems

sudo gem install sass

sass --watch /path/to/scss:/path/to/outputcss
```

## Deployment

For deployment, sensitive data such as database access credentials and the SECRET_KEY should not be stored in settings.py (i.e. in the *source repository*).  They can be accessed using **environment variables**, but note that the usual Apache environment settings don't work with WSGI.  The solution is to use a separate wsgi.py stored *outside* the application directory, in e.g. `/srv`.  So do the following:

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

    os.environ['SKILLDRIVE_SECRET_KEY'] = 'really-long-string-using-eg-pwgen-with-the-secure-switch';
    os.environ['SKILLDRIVE_DATABASE_PASSWORD'] = 'skilldrive20171207';
    os.environ['SKILLDRIVE_DATABASE_USER'] = 'skilldriveuser';
    os.environ['SKILLDRIVE_DATABASE_NAME'] = 'skilldrive';
    os.environ['SKILLDRIVE_USE_RAVEN'] = '1';
    os.environ['SKILLDRIVE_ALLOWED_HOSTS'] = ';'.join(['skilldrive.ubuntuvm.net'])
    os.environ['SKILLDRIVE_PRODUCTION'] = '1';

    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "skilldrive.settings")

    application = get_wsgi_application()
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
1. Alter the settings.py to use the environment variables instead of hardcoded values (with maybe some default non-sensitive values for convenience):
    ```python
    # SECURITY WARNING: keep the secret key used in production secret!
    SECRET_KEY = os.environ.get('SKILLDRIVE_SECRET_KEY', '(#ndzme(jt4w)=(z^sretalk170dx(lww=lq$o+j15e5lxxi1s')

    # SECURITY WARNING: don't run with debug turned on in production!
    DEBUG = os.environ.get ('SKILLDRIVE_PRODUCTION') is None

    ALLOWED_HOSTS = ['skilldrive.ubuntuvm.net']
    ALLOWED_HOSTS_STRING = os.environ.get('SKILLDRIVE_ALLOWED_HOSTS')
    if ALLOWED_HOSTS_STRING is not None:
        ALLOWED_HOSTS = ALLOWED_HOSTS_STRING.split(';')

    ...

    DATABASES = {
        'default': {
            'ENGINE' : 'django.db.backends.postgresql_psycopg2',
            'NAME' : os.environ.get('SKILLDRIVE_DATABASE_NAME', 'skilldrive'),
            'USER' : os.environ.get('SKILLDRIVE_DATABASE_USER', 'skilldriveuser'),
            'PASSWORD' : os.environ.get('SKILLDRIVE_DATABASE_PASSWORD', 'skilldrive20171207'),
            'HOST' : 'localhost',
            'PORT' : '',
        }
    }

    ...

    # Remote logging with Sentry
    RAVEN_CONFIG = {
    }

    if os.environ.get('SKILLDRIVE_USE_RAVEN') is not None:
        INSTALLED_APPS.append('raven.contrib.django.raven_compat')
        RAVEN_CONFIG = {
            'dsn' : 'https://5fb1ce5f3f5847658f5e4fd0aca659fe:878e14234463469b93f4ac0f128574a0@sentry.io/256852',
            'release' : raven.fetch_git_sha(BASE_DIR),
        }
    ```