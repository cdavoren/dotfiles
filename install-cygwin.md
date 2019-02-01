# Cygwin Installation Notes

## Minimum packages to be installed:

- zsh
- gettext
- libcurl-devel
- zlib-devel
- stow
- gcc-g++
- automake
- make
- tcl-tk
- python3
- vim
- screen
- tmux

## Enable ssh-agent

As per https://stackoverflow.com/questions/52113738/starting-ssh-agent-on-windows-10-fails-unable-to-start-ssh-agent-service-erro :

```
Get-Service -Name ssh-agent | Set-Service -StartupType Manual
```

