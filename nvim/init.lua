-- Global variables to be declared first, as they are used in LazyVim plugin setup
code_expandtab = true
code_shiftwidth = 4
code_tabstop = 4
code_softtabstop = 4
code_autoindent = true
code_smartindent = true
code_smarttab = true
code_formatoptions = "jncroql"
code_textwidth = 0
code_conceallevel = 0

code_types = {
  "python",
  "lua",
  "html",
  "htmldjango",
  "javascript",
}

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.opt.title = true
vim.opt.titlestring = [[%t - %{fnamemodify(getcwd(), ':t')}]]

local function listoptions()
  print("Listing options:")
  local count = 0
  for k, _ in pairs(vim.o) do
    print(k)
    count = count + 1
  end
  print(string.format("Count: %i", count))
  print(vim.o.lines)
end

for _, code_type in pairs(code_types) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = code_type,
    callback = function()
      vim.bo.expandtab = code_expandtab
      vim.bo.shiftwidth = code_shiftwidth
      vim.bo.tabstop = code_tabstop
      vim.bo.softtabstop = code_softtabstop
      vim.bo.autoindent = code_autoindent
      vim.bo.smartindent = code_smartindent
      vim.o.smarttab = code_smarttab
      vim.bo.formatoptions = code_formatoptions
      vim.bo.textwidth = code_textwidth
      vim.wo.conceallevel = code_conceallevel
    end,
  })
end

-- Disable auto-format on save
-- I used this initially because the default behaviour of stylua was to use 2 spaces tabstops no matter the global settings, and since the use of stylua comes with LazyVim it was either (a) disable global autoformatting, or (b) fix it to inherit my setings; it took me a while to figure out the latter
-- vim.g.autoformat = false
