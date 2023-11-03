-- Personal Neovim configuration
-- Much of the content is originally from the kickstart.nvim template, however the file
-- layout has taken extensive inspiration from the Neovim from Scratch (NFS) series, 
-- repository available at https://github.com/LunarVim/Neovim-from-scratch

-- NOTE: Ideally if following the NFS layout, all plugin configuration would be in
-- separate files in /lua/user/[plugin].lua.  Unfortunately as some configuration is taken
-- straight from kickstart.nvim, setup/configuration may also be found directly in the
-- /lua/user/plugin.lua file on load/install of the plugin.  Be sure to look in both 
-- places.

-- Original kickstart.nvim preamble follows --

--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================

Kickstart.nvim is *not* a distribution.

Kickstart.nvim is a template for your own configuration.
  The goal is that you can read every line of code, top-to-bottom, understand
  what your configuration is doing, and modify it to suit your needs.

  Once you've done that, you should start exploring, configuring and tinkering to
  explore Neovim!

  If you don't know anything about Lua, I recommend taking some time to read through
  a guide. One possible example:
  - https://learnxinyminutes.com/docs/lua/


  And then you can explore or search through `:help lua-guide`
  - https://neovim.io/doc/user/lua-guide.html


Kickstart Guide:

I have left several `:help X` comments throughout the init.lua
You should run that command and read that help section for more information.

In addition, I have some `NOTE:` items throughout the file.
These are for you, the reader to help understand what is happening. Feel free to delete
them once you know what you're doing, but they should serve as a guide for when you
are first encountering a few different constructs in your nvim config.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now :)
--]]

require('user.options')
require('user.keymaps')

require('user.plugins')

require('user.telescope')
require('user.treesitter')
require('user.lsp')
require('user.cmp')

require('user.formatter')
require('user.overlength')
require('user.markdownpreview')