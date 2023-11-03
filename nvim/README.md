# Installation Notes

Valid as of **05/07/2023**.

General notes on installation and configuration of Neovim.

Don't use `.vim` files if you don't have to!  The Lua config files should be used wherever possible.

Good videos to watch regarding configuration:

1. Effective Neovim: Instant IDE ([`kickstart.nvim`](https://github.com/nvim-lua/kickstart.nvim) guide) : https://www.youtube.com/watch?v=stqUbv-5u2s
2. 0 to LSP: Neovim RC From Scratch (good for review of neovim configuration structure/Lua use) : https://www.youtube.com/watch?v=w7i4amO_zaE

Other useful places are Primeagen's template configuration:

https://github.com/ThePrimeagen/init.lua/tree/249f3b14cc517202c80c6babd0f9ec548351ec71

## Additional Commands

The following commands will have to be run manually on first installation:

1. `:PylspInstall pyls-flake8 pyls-mypy pyls-isort` - Unable to automate subpackages for LSPs (yet), see `user/lsp.lua`
1. `:MasonInstall black` - No (good) way to automate installation of non-LSP packages, see `user/formatter.lua`

## Windows Installation

### Config File Location

I seem to continually forget this, and the documentation is not (immediately) straightforward.  *The Neovim configuration files are located in `%USERPROFILE%\AppData\Local\nvim`*.

### Using kickstart.nvim 

#### LSP / Mason

If using the `python-lsp-server` LSP (also abbreviated `pylsp`) then ensure that python and virtualenv are in the system PATH.

Also, if using the `csharp_ls` LSP then the `dotnet` command will need to be in PATH.  This comes with the .NET SDK which can be downloaded as a component of Visual Studio Community (which needs to be installed anyway, see `telescope` notes below), but can also be installed separately (although I have not tested this).

#### Telescope

Ostensibly, all these problems can be solved by reading the README.md (especially the troubleshooting sections), but I'm summarising it here because it caused me *so* much trouble.

The hardest part of installation under windows is the compilation of `telescope-fzf-native` by far.  It would *appear* that this only works with a Visual Studio Community installation, which by default installs all the necessary MSBuild CLI tools including most especially `nmake`.  In theory one should also be able to do this using only the MSBuild (non-IDE) installation, but I did not manage to find the correct settings for this (namely, it did not install `nmake`).  

Although not strictly in line with the README instructions, I have also tried using e.g. LLVM and [Make for Windows](https://gnuwin32.sourceforge.net/packages/make.htm) (with some tweaks to the Makefile) and this appears to work although I was unable to verify that telescope was successfully using the libfzf.dll by this method.  For reference, the changes that needed to be made to the Makefile were:

1. `CC = gcc` to `CC = clang`
2. `CFLAGS += -Wall -Werror -fpic -std=gnu99` to `CFLAGS += -Wall -stdgnu99` (`-fpic` causes some kind of compatibility error, `-Werror` fails with deprecated function calls)

To use CMake (instead of the default `make`), a manual edit of the `telescope-fzf-native` setup template is required. Look for the section that looks like this (this change is taken from the kickstart README:


	{
		'nvim-telescope/telescope-fzf-native.nvim',
		-- NOTE: If you are having trouble with this installation,
		--       refer to the README for telescope-fzf-native for more instructions.
		build = 'make',
		cond = function()
		  return vim.fn.executable 'make' == 1
		end,
	},

... to this:

	{'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }

Initially this may not appear to work, but at some point "just does".  It is unclear to me also at what point CMake suddenly is able to find the VS build tools, as these are not in the path.  Considering that it only appears to start working if the compile

The basic `telescope` plugin relies on two (optional?) binaries that should ideally be installed and added to the default %PATH% for use by `telescope` and probably other plugins:

1. ripgrep - https://github.com/BurntSushi/ripgrep
2. fd - https://github.com/sharkdp/fd

The command `:checkhealth` can be used to check whether `telescope` is correctly finding these utilities.

Then follow the default instructions for configuration, including e.g. installing the python LSP.
