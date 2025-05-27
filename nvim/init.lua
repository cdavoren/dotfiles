-- Global variables to be declared first, as they are used in LazyVim plugin setup

function T(t)
  return setmetatable(t, {__index = table})
end

function table.deepcopy(org)
    local orig_type = type(org)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, org, nil do
            copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
        end
        setmetatable(copy, table.deepcopy(getmetatable(org)))
    else -- number, string, boolean, etc
        copy = org
    end
    return copy
end

function table.replace_value(tbl, key, value)
  tbl[key] = value
  return tbl
end

local default_format_options = T{
  code_expandtab = true,
  code_shiftwidth = 4,
  code_tabstop = 4,
  code_softtabstop = 4,
  code_autoindent = true,
  code_smartindent = true,
  code_smarttab = true,
  code_formatoptions = "jncroql",
  code_textwidth = 0,
  code_conceallevel = 0
}

local code_formats = {
  { "python", default_format_options:deepcopy() },
  { "lua", default_format_options:deepcopy():replace_value("code_shiftwidth", 2):replace_value("code_tabstop", 2) },
  { "html", default_format_options:deepcopy() },
  { "htmldjango", default_format_options:deepcopy():replace_value("code_shiftwidht", 2):replace_value("code_tabstop", 2) },
  { "javascript", default_format_options:deepcopy() },
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

for _, code_fval in pairs(code_formats) do
  vim.api.nvim_create_autocmd("FileType", {
    pattern = code_fval[1],
    callback = function()
      vim.bo.expandtab = code_fval[2].code_expandtab
      vim.bo.shiftwidth = code_fval[2].code_shiftwidth
      vim.bo.tabstop = code_fval[2].code_tabstop
      vim.bo.softtabstop = code_fval[2].code_softtabstop
      vim.bo.autoindent = code_fval[2].code_autoindent
      vim.bo.smartindent = code_fval[2].code_smartindent
      vim.o.smarttab = code_fval[2].code_smarttab
      vim.bo.formatoptions = code_fval[2].code_formatoptions
      vim.bo.textwidth = code_fval[2].code_textwidth
      vim.wo.conceallevel = code_fval[2].code_conceallevel
    end,
  })
end

-- Disable auto-format on save
-- I used this initially because the default behaviour of stylua was to use 2 spaces tabstops no matter the global settings, and since the use of stylua comes with LazyVim it was either (a) disable global autoformatting, or (b) fix it to inherit my setings; it took me a while to figure out the latter
vim.g.autoformat = false

-- Was used during testing of this functionality on windows... beware lua_ls defaults (or lsp's in general)
-- vim.g.root_spec = { "cwd " }

