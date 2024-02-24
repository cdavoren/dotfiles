# Windows 11 Installation Notes

Start with Windows 10 installation notes -> as of 24/02/2024.

Additionally however the Windows 11 taskbar *sucks*.  Especially when it comes to forced "taskbar overflow" which there is no way to disable.  The Windows UX team are not nice people.

Relevant:
- MS forums thread discussing this: https://answers.microsoft.com/en-us/windows/forum/all/how-to-disable-taskbar-overflow-menu-and-restore/459e7adc-c85a-4e2a-8dc7-a14eadcdca32
- This is a tool that appears to work to fix it: https://github.com/valinet/ExplorerPatcher
- This is also mentioned: https://www.startallback.com/ (looks proprietary)

# Windows 10 Installation Notes

## Partitioning Considerations

As at 18th December 2017:

**Directory sizes:**

- `C:/Users/[user]` (not including "rebaseable" media folders e.g. Documents, Downloads, etc): 16.9 GB
- `C:/Windows/`: 22.7 GB
- `C:/Program Files`: 5.9 GB
- `C:/Program Files (x86)`: 9.7 GB
- `C:/ProgramData`: 5.5 GB
- `G:/MainUser/`(rebased Documents/Downloads/Pictures): 73.8 GB

Total size: 135.9 GB

Size without rebased folders: 60.7 GB

I have included a list of [installed programs](windows/installed_programs.txt).

**Note**: This list was obtained via a PowerShell script, see the relevant section under "PowerShell" below.

**Conclusion**: A main partition size of 120 GB with rebased user folders would likely be fine, or 250 GB without.

### Application Disk Usage

Viewed using [WinDirStat (free software)](https://windirstat.net).

Main offenders:

Folder | Size | Contents
--- | --- | ---
`C:/Program Files` | 5.9 GB | -
`-`Microsoft Office | 6 GB | -
`-`NVIDIA Coroporation | 3 GB | -
`-`Common Files | 655.1 MB | -
`C:/Program Files (x86)` | 9.7 GB | -
`-`Microsoft Visual Studio 14 | 8 GB | -
`-`Adobe | 6 GB | -
`C:/Users/Chris` | 16.9 GB | -
`-`AppData/Local/Plex Media Server | 3.7 GB | Metadata cache
`-`AppData/Local/Spotify/Data | 6 GB | Cache or downloads?
`-`AppData/Local/Temp | 1 GB | -
`-`AppData/Local/NVIDIA | 1 GB |  '`nvBackend`', looks like GeForce Experience game optimisation interface cache, e.g. game images etc.
`-`AppData/Local/Steam/htmlcache | 915.7 MB | -
`-`Other Appdata/Local files e.g. Google, Battle.net, Microsoft | All ~500 MB | Looks to be mostly cache data
`-`AppData/Roaming/Curse Client | 458 MB | Binaries
`-`AppData/Roaming/Mozilla | 367 MB | Profile data
`G:/MainUser` | 73.8 GB | -
`-`Documents/My Games | 2.0 GB | -
`--`Documents/My Games/Skyrim | 9.1 GB | Saved games, includes TESVSGM files
`--`Documents/My Games/Company of Heroes | 2 6.9 GB | Mods and saved games
`--`Documents/My Games/Company of Heroes Relaunch | 2.0 GB | Saved games
`-`Documents/StarCraft II | 12.6 GB | Account-specific saved games
`-`Documents/BioWare | 9.7 GB | -
`--`Documents/BioWare/Dragon Age | 7.0 GB | Approx. half packages, half saved games
`--`Documents/BioWare/Dragon Age 2 | 2.6 GB | Saved games
`-`Documents/Professional 2013 | 13.0 GB | Office Professional 2013 files? Now deleted.
`-`Documents/The Witcher | 5.7 GB | Saved games

## PowerShell

To use scripts from the internet (.ps1 files), remote signed execution should first be enabled (in both 32/64 bit modes):

1. Run PowerShell as Administrator
1. Run the command:
    ```powershell
    Set-ExecutionPolicy RemoteSigned
    ```
1. This may still exclude downloaded unsigned scripts.  You can enable ALL scripts by using:
    ```powershell
    Set-ExecutionPolicy Unrestricted
    ```
    **Note**: This should only ever be **_temporary_**.

1. You can also explicitly mark a script as safe via:
    ```powershell
    Unblock-File -Path C:\Downloads\script1.ps1
    ```

To bring a script that contains a function into the local namespace, use the following command (similar to Bash `source`):

```powershell
. ./ScriptName.ps1
```

You can then call the function from the command line like any of the built-in functions.

From: https://www.opentechguides.com/how-to/article/powershell/105/powershel-security-error.html

**Note:** PowerShell can be run either in 64-bit and 32-bit modes, and will accordingly behave differently for certain contexts (e.g. when getting a list of 64 vs 32 bit install programs)

### Installed Programs Script

Downloaded originally from: https://gallery.technet.microsoft.com/scriptcenter/Get-RemoteProgram-Get-list-de9fd2b4

Execution example:

```powershell
. ./Get-RemotePrograms.ps1
 Get-RemoteProgram -ComputerName CHRISDESKTOP -Property EstimatedSize, InstallDate, Publisher, Version, VersionMinor, VersionMajor > installed_programs.txt
```

Note: The simple way to do this is apparently:
```powershell
Get-WmiObject -class win32_product
```

However, this fails to list some applications (e.g. Mozilla Firefox).  Some sources suggest this is because it must be run in both 32/64 bit mode, but running it in both gave no difference in output.  The above script is faster anyway.

## Activation

`Microsoft Toolkit` or `(KMSPico) KMSAuto Net` - these both appear to be kind of the same thing/from the same person.  Not sure of the difference?

Official thread: https://forums.mydigitallife.net/forums/kms-tools.51/ (will need to login, user Davorian)

Do **not** download from TLDs.  Use the official thread only, as above.

KMSAuto Net (portable) is the one that has worked so far, but "KMS Tools" may also work.

## Basic Drivers

1. Graphics card (nVidia 970 GTX)
1. Printer (Canon MG5765)
1. Network driver (Netgear WNA3100 N300)
1. Wireless headphones (Corsair VOID Wireless Dolby 7.1 RGB Gaming Headset)

## Basic Software

1. Mozilla Firefox
1. Google Chrome
1. 7-Zip
1. NitroPDF & crack
1. Google Drive ("Backup and Restore")
1. Office 2016 & activator (KMSPico as above)
1. KiTTY

## Development

1. SSH keys (private and public).
1. VirtualBox
1. Python 3
1. Visual Studio Code  
  Extensions installed:
    - Django template (bibhasdn)
    - Python (microsoft)
    - Vim (vscodevim)
    - VimL (vscodevim)
    - markdownlint (David Anson)
1. Sublime Text Editor 3

### Optional Dev Tools (rarely used)

1. gVim (?)
    - Config files from the dotfiles/vim directory (`.vimrc` → `_vimrc` & `.vim/` → `vimfiles/`)
1. PowerShell
1. MinGW (from website)

## Gaming

1. Steam
1. Battle.net
1. Origin
1. UPlay

## Commonly Used Software

1. VLC
1. Deluge
1. Spotify
1. Paint.net

## Graphics/Publishing

1. Adobe ?version
1. Adobe Acrobat Reader (just in case)

## File Management and Tracking

1. **WinDirStat** - for assessing disk usage of folders/files
1. **WinMerge** - for comparing folders/files

## Video File Tweaking

1. **MKVToolNix** - Useful for adding subtitles to existing mkv files
1. **HandBrake** - Transcoder (rarely used)
1. **Mp3Tag** - ?editing metadata only

## Keyboard Debouncing

Using a mechanical keyboard can sometimes result in unwanted key repetition due to the high sensitivity of the hardware.  The debouncing time can be increased in the following registry key:

```HKEY_CURRENT_USER\Control Panel\Accessibility\Keyboard Response\BounceTime```

Suggested values are 20-35 (I believe this is in milliseconds).

Ref: https://superuser.com/questions/1296081/change-debounce-time-of-keyboard
