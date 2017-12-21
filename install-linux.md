# Linux (Ubuntu 17.10) Server Installation Notes

Notes for Ubuntu Server 17.10.

Valid as at 7th December 2017.

## Enable host-only network interface

In file:

`/etc/netplan/01-netcfg.yaml`

Add:

```yaml
enp0s8:
    dhcp4: yes
```

## Disable automatic updates

In file:

`/etc/apt/apt.conf.d/10periodic` 

Edit appropriate line:

`APT::Periodic::Update-Package-Lists "0";`

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

## Disable Network Wait Error

On Ubuntu 17.10, after I added a host-only adapter for virtual machine, there was a wait error on every boot (some kind of DHCP error?).  I don't know why, but this disables it:

`sudo systemctl disable systemd-networkd-wait-online.service`

`sudo systemctl mask systemd-networkd-wait-online.service`

## Local Installs and Programs

Install additional libraries required by git:
- sudo apt install build-essential
- sudo apt install gettext`
- sudo apt install libz-dev`
- sudo apt install libcurl4-openssl-dev # For HTTPS support e.g. github

- Install git to ~/.local
- Clone dotfiles repository
- apt install stow

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
