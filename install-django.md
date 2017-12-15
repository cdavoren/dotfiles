# Django (2.0) and Apache Installation Notes

Django version: 2.0, 

Apache version: 2.4, under Ubuntu Server 17.10

Current as at 15th December 2017.

## Create and Configure Django Project

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
### Custom Template Note

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

## #Static files including common

Add the following to settings file:

```python
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')
STATICFILES_DIRS = (os.path.join(BASE_DIR, 'common-static')

# Don't know why this has to be set manually, since this is the documented 'default value:
STATICFILES_FINDERS = [
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
]
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

## Configure Apache

Install required packages:

`sudo apt install libapache2-mod-wsgi-py3`

Example host file (in e.g. `/etc/apache/sites-available`):

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
