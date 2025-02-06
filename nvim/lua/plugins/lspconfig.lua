local function valueExists(list, value)
    for index, val in ipairs(list) do
        if val == value then
            return true
        end
    end
    return false
end

-- This was an attempt to disable auto-formatting (on save) based on some reddit advice, however I think it is outdated.  The current LazyVim docs say to use the vim.g.autoformat or vim.b.autoformat settings instead.
return {

    {
        "neovim/nvim-lspconfig",
        opts = {
            format = {
                formatting_options = nil,
                timeout_ms = nil,
            },
            servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            diagnostics = {
                                disable = { "lowercase-global" },
                            },
                        },
                    },
                },
            },
        },
    },

    {
        "stevearc/conform.nvim",
        opts = function(_, opts)
            if valueExists(code_types, "lua") then
                -- print("MEMBER CHECK SUCCESS")
                stylua = {
                    prepend_args = {
                        "--indent-type",
                        code_expandtab and "Spaces" or "Tabs",
                        "--indent-width",
                        tostring(code_tabstop),
                    },
                }
                opts.formatters = {
                    stylua = stylua,
                }
            end
        end,
    },
}
