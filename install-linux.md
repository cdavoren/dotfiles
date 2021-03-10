# Linux Server Installation Notes

Notes originally created for Ubuntu Server 17.10, however valid as at 23rd August 2020 for Ubuntu 20.04.

## Create user

Only relevant if non-root user has not already been created during installation process.

```bash
$ adduser davorian
# ... add details ...
# For SUDO access:
$ addgroup admin
$ adduser davorian admin
```

## Legacy Networking

**NOTE:** No longer seems to be relevant for 20.04 (either on Linode or as VM).  Left here for completeness.

### Enable host-only network interface

In file:

`/etc/netplan/01-netcfg.yaml`

Add:

```yaml
enp0s8:
    dhcp4: yes
```

### Disable Network Wait Error

On Ubuntu 17.10, after I added a host-only adapter for virtual machine, there was a wait error on every boot (some kind of DHCP error?).  I don't know why, but this disables it:

`sudo systemctl disable systemd-networkd-wait-online.service`

`sudo systemctl mask systemd-networkd-wait-online.service`

## Disable automatic updates

In files:

```
/etc/apt/apt.conf.d/10periodic
/etc/apt/apt.conf.d/20auto-upgrades
```

Edit appropriate lines:

```
APT::Periodic::Update-Package-Lists "0";
APT::Periodic::Unattended-Upgrade "0";
```

## Configure Samba

In file:

`etc/samba/smbd.conf`:

Add:

```conf
[davorian]
   comment = home
   path = /home/davorian
   browseable = yes
   read only = no
   guest only = no
   valid users = davorian
   map archive = no
   create mask = 0664
   directory mask = 0775

[www]
   comment = www
   path = /var/www
   browseable = yes
   read only = no
   guest only = no
   valid users = davorian
   map archive = no
   create mask = 0664
   directory mask = 0775
```

Then:

`sudo smbpasswd -a davorian`

`sudo systemctl restart smbd`

## Local Installs and Programs

Install additional libraries required by git:
- `sudo apt install build-essential`
- `sudo apt install gettext`
- `sudo apt install libz-dev`
- `sudo apt install libcurl4-openssl-dev # For HTTPS support e.g. github`

- Install git to `~/.local`
- Install git manpages tarfile to `~/.local/share/man`
- Clone dotfiles repository
- `sudo apt install stow`

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

When fixing paths, ensure to put 'export PATH=...' at **TOP** of .bashrc before 'interactive shell' check, else it won't be executed on ssh commands, e.g. git push

## SSH Configuration

Add keys as appropriate.

From [https://help.github.com/articles/working-with-ssh-key-passphrases/#auto-launching-ssh-agent-on-msysgit](here) or [http://mah.everybody.org/docs/ssh](here).

Add persistent SSH management to .bashrc and/or .zshrc:

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

1. Use **oh-my-zsh** one-liner pasted on home webpage.
2. `stow` zsh configuration from dotfiles repo.

Note had to add in a .zshenv so that git can access local installs via SSH:

```bash
export PATH=$HOME/.local/bin:$PATH
```

## Apache Installation

Use the following commands anticipating both PHP / MySQL and Python 3 Django / PostgreSQL sites:

```bash
$ sudo apt install apache2
$ sudo apt install libapache2-mod-php php-mysql
$ sudo apt install libapache2-mod-wsgi-py3
# Following lines are optional; they are for the installation of some previously used Python modules (and may be outdated!)
$ sudo apt install libpq-dev
$ sudo apt install libtiff5-dev libjpeg8-dev libopenjp2-7-dev zlib1g-dev \
    libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python3-tk \
    libharfbuzz-dev libfribidi-dev libxcb1-dev
```

### Powerline Installation

Install powerline:

```bash
$ sudo apt install powerline
```

To use powerline with zsh, the following line must be added to ```~/.zshrc```:

```bash
. /usr/share/powerline/bindings/zsh/powerline.zsh
```

To use powerline with tmux, the following should be added to ```~/.tmux.conf```:

```ini
set -g default-terminal "screen-256color"
source "/usr/share/powerline/bindings/tmux/powerline.conf"
```

In the above, ensure that the path corresponds to the correct location of powerline - this varies considerably on different platforms.  Use ```locate powerline.zsh``` to find it.

Then create the following files:

```bash
~/.config/powerline/config.json
~/.config/powerline/colors.json
~/.config/powerline/colorschemes/shell/default.json
~/.config/powerline/themes/shell/default.json
```

```config.json```:

```json
{
        "common": {
                "term_truecolor": true
        }
}
```

```colors.json```:

```json
{
        "colors": {
                "darkdarkblue" : 17,
                "darkdarkpurple" : 54,
                "darkpurple0" : [53, "13073a"],
                "darkpurple1" : [54, "261758"],
                "darkpurple2" : [55, "403075"],
                "darkpurple3" : [56, "615192"],
                "darkpurple4" : [57, "887caF"],
                "darkstaticpurple0" : [53, "1e1529"],
                "darkstaticpurple1" : [54, "251639"],
                "darkstaticpurple2" : [55, "271341"],
                "darkstaticpurple3" : [56, "2f2340"],
                "darkstaticpurple4" : [57, "413157"],
                "darkblue0" : [17, "0b031d"],
                "darkblue1" : [18, "0d0225"],
                "darkblue2" : [19, "130730"],
                "darkblue3" : [20, "1a044f"],
                "darkblue4" : [21, "290973"]
        }
}
```

```colorschemes/shell/default.json```:

```json
{
        "name": "Default color scheme for shell prompts",
        "groups": {
                "hostname":             { "fg": "white", "bg": "darkpurple1", "attrs": [] },
                "environment":          { "fg": "white", "bg": "darkpurple4", "attrs": [] },
                "mode":                 { "fg": "darkestgreen", "bg": "brightgreen", "attrs": ["bold"] },
                "attached_clients":     { "fg": "white", "bg": "darkestgreen", "attrs": [] },
                "virtualenv":           { "fg": "white", "bg": "darkpurple2", "attrs" : [] },
                "user":                 { "fg": "white", "bg": "darkpurple3", "attrs" : [] },
                "cwd":                  { "fg": "white", "bg": "darkpurple4", "attrs" : [] },
                "cwd:current_folder":   { "fg": "white", "bg": "darkpurple4", "attrs" : ["bold"] }
        },
        "mode_translations": {
                "vicmd": {
                        "groups": {
                                "mode": {"fg": "darkestcyan", "bg": "white", "attrs": ["bold"]}
                        }
                }
        }
}
```

```themes/powerline_terminus.json```:

```json
{
        "dividers": {
                "left": {
                        "hard": " ",
                        "soft": " "
                },
                "right": {
                        "hard": " ",
                        "soft": " "
                }
        },
        "segment_data" : {
                "powerline.segments.common.net.hostname": {
                        "before" : " "
                }
        }
}
```

```themes/shell/default_leftonly.json```:

```json
{
        "segments": {
                "left": [
                        {
                                "function": "powerline.segments.common.net.hostname",
                                "args": {
                                        "exclude_domain": true
                                }
                        },
                        {
                                "function": "powerline.segments.shell.mode"
                        },
                        {
                                "function": "powerline.segments.common.env.virtualenv",
                                "priority": 50
                        },
                        {
                                "function": "powerline.segments.common.env.user",
                                "priority": 30
                        },
                        {
                                "function": "powerline.segments.shell.cwd",
                                "priority": 10,
                                "args": {
                                        "use_path_separator": true,
                                        "dir_limit_depth": 2
                                }
                        },
                        {
                                "function": "powerline.segments.shell.jobnum",
                                "priority": 20
                        }
                ]
        }
}

```

You may have to restart the shell / session (or execute ```powerline-daemon --replace```) in order to see changes.


