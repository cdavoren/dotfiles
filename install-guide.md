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

## Local Installs and Programs

Install additional libraries required by git:
- sudo apt install build-essential
- sudo apt install gettext
- sudo apt install libz-dev
- sudo apt install libcurl4-openssl-dev # For HTTPS support e.g. github
- Install git to ~/.local
- Get dotfiles repository and GNU stow via apt

To create new local repostory and link to server:

```bash
git init [name]
git remote add origin ssh:/[address]
git push -u origin master #The -u sets *DEFAULT* upstream
```

Resulting config:
```ini
[core] repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
[remote "origin"]
	url = ssh://davorian@rubikscomplex.net/Git/dotfiles.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
	remote = origin
	merge = refs/heads/master
```

When fixing paths, ensure to put 'export PATH=...' at TOP of .bashrc before 'interactive shell' check, else it won't be executed on ssh commands, e.g. git push

## SSH Configuration

Add keys as appropriate.

Add persistent SSH management to .bashrc and .zshrc:
https://help.github.com/articles/working-with-ssh-key-passphrases/#auto-launching-ssh-agent-on-msysgit)
OR
http://mah.everybody.org/docs/ssh

```bash
env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2= agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi

unset env
```

## ZSH Installation

1. Used **oh-my-zsh** one-liner pasted on home webpage.

2. Stow zsh configuration.

Note had to add in a .zshenv so that git can access local installs via SSH:

```bash
export PATH=$HOME/.local/bin:$PATH

```

