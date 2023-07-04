Installation Notes
==================

Valid as of **05/07/2023**.

General notes on installation and configuration of Neovim.

Don't use `.vim` files if you don't have to!  The Lua config files should be used wherever possible.

Good videos to watch regarding configuration:

1. Effective Neovim: Instant IDE (`kickstarter.nvim` guide) : https://www.youtube.com/watch?v=stqUbv-5u2s
2. 0 to LSP: Neovim RC From Scratch (good for review of neovim configuration structure/Lua use) : https://www.youtube.com/watch?v=w7i4amO_zaE

Other useful places are Primeagen's template configuration:

https://github.com/ThePrimeagen/init.lua/tree/249f3b14cc517202c80c6babd0f9ec548351ec71

Windows Installation
--------------------

### Config File Location

I seem to continually forget this, and the documentation is not (immediately) straightforward.  *The Neovim configuration files are located in %USERPROFILE%\AppData\Local\nvim*.

### Using kickstarter.nvim 

All these problems can be solved by reading the README.md (especially the troubleshooting sections), but I'm summarising it here because it caused me *so* much trouble.

The hardest part of installation under windows is the compilation of telescope-fzf-native by far.  Points to remember:

Firstly, use *only LLVM compliation tools*.  Do *not* use Visual Studio or MinGW even though it looks like these should be supported.  This *is* actually in the README but it's easy to miss.

Secondly, use *CMake* as the make tool.  This requires a manual edit of the kickstarter template, specifically change the section that looks like this:


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

Thirdly, there are two binaries that should ideally be installed and added to the default %PATH% for use by `telescope` and probably other plugins:

1. ripgrep - https://github.com/BurntSushi/ripgrep
2. fd - https://github.com/sharkdp/fd

Then follow the default instructions for configuration, including e.g. installing the python LSP.

I haven't yet figured out how to turn off python linting, which can be very annoying.
