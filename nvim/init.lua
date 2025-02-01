-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.opt.title = true
vim.opt.titlestring = [[%t - %{fnamemodify(getcwd(), ':t')}]]

function listoptions()
  print("Listing options:")
  local count = 0
  for k, _ in pairs(vim.o) do
    print(k)
    count = count + 1
  end
  print(string.format("Count: %i", count))
  print(vim.o.lines)
end

local code_expandtab = true
local code_shiftwidth = 4
local code_tabstop = 4
local code_softtabstop = 4
local code_autoindent = true
local code_smartindent = true
local code_smarttab = true
local code_formatoptions = "jncroql"
local code_textwidth = 0

local code_types = {
  "python",
  "lua",
  "html",
  "htmldjango",
  "javascript",
}

for i, code_type in ipairs(code_types) do
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
    end,
  })
end
