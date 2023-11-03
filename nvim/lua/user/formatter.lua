local formatter_status_ok, formatter = pcall(require, 'formatter')
if not formatter_status_ok then
  return
end

-- We need black for python formatting, for use with formatter.nvim
-- TODO: Find a way to ensure black is automatically installed by Mason
--     * Currently, Mason has no way to automate/ensure the installation of specific
--       packages.  mason-lspconfig can only do so for language servers, not formatters.
--       Candidates include https://github.com/jay-babu/mason-null-ls.nvim combined with
--       https://github.com/nvimtools/none-ls.nvim, however the future of none-ls is not
--       guaranteed (as a 'community' replacement for the now-archives null-ls) and this
--       seems like a lot of extra baggage for such a simple requirement.
-- TODO: Find a way to use python-lsp-server internal formatting

formatter.setup {
  logging = true,
  log_level = vim.log.levels.INFO,
  filetype = {
    python = {
      require('formatter.filetypes.python').black,
    }
  }
}