-- Opciones generales
vim.o.relativenumber = true
vim.o.number = true
vim.opt.expandtab = true      -- Usa espacios en lugar de tabs
vim.opt.shiftwidth = 2        -- Tamaño de la indentación (2 espacios)
vim.opt.tabstop = 2           -- Tamaño del tabulador en 2 espacios
vim.opt.softtabstop = 2       -- Tamaño del tabulador en modo edición
vim.keymap.set("n", "<C-t>", ":split | terminal<CR>", { noremap = true, silent = true })


-- Configuración para cargar Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- Versión estable
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Inicializa Lazy.nvim con plugins
require("lazy").setup({
    -- Tema Tokyonight
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme tokyonight]])
        end,
    },

    -- Alpha-nvim para el dashboard
    {
        "goolord/alpha-nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local alpha = require("alpha")
            local dashboard = require("alpha.themes.dashboard")

            dashboard.section.header.val = {
                [[ ███╗   ██╗██╗   ██╗██╗███╗   ███╗ ]],
                [[ ████╗  ██║██║   ██║██║████╗ ████║ ]],
                [[ ██╔██╗ ██║██║   ██║██║██╔████╔██║ ]],
                [[ ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
                [[ ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
                [[ ╚═╝  ╚═══╝  ╚═╝╚═╝  ╚═╝     ╚═╝ ]],
            }

            dashboard.section.buttons.val = {
                dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
                dashboard.button("f", "  Find file", ":Telescope find_files<CR>"),
                dashboard.button("r", "  Recent files", ":Telescope oldfiles<CR>"),
                dashboard.button("s", "  Sync plugins", ":Lazy sync<CR>"),
                dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
            }

            dashboard.section.footer.val = "Neovim configurado con amor 💙"
            alpha.setup(dashboard.opts)
        end,
    },

    -- Telescope
    {
        "nvim-telescope/telescope.nvim",
        version = "0.1.0",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons"
        },
        config = function()
            require("telescope").setup({
                defaults = {
                    mappings = {
                        i = {
                            ["<C-n>"] = require("telescope.actions").cycle_history_next,
                            ["<C-p>"] = require("telescope.actions").cycle_history_prev,
                        },
                    },
                    file_icon = true,
                    prompt_prefix = "🔍 ",
                    selection_caret = " ",
                    path_display = { "absolute" },
                },
            })
        end,
    },

    -- NvimTree para el árbol de archivos
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                view = {
                    width = 30,
                    side = "left",
                },
                renderer = {
                    icons = {
                        show = {
                            file = true,
                            folder = true,
                            folder_arrow = true,
                            git = true,
                        },
                    },
                },
            })
            -- configurar atajo de ctrl n
            vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
        end,
    },

    -- Notificaciones elegantes
    {
        "rcarriga/nvim-notify",
        config = function()
            require("notify").setup({
                stages = "fade_in_slide_out",
                timeout = 3000,
                background_colour = "#000000",
            })
            vim.notify = require("notify")
        end,
    },

    -- lualine
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "tokyonight",
                    component_separators = { left = "", right = "" },
                    section_separators = { left = "", right = "" },
                },
            })
        end,
    },

    -- Mason para gestionar LSPs
    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({
                ui = {
                    border = "rounded",
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗"
                    }
                }
            })
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "pyright", "lua_ls", "html", "cssls" },
                automatic_installation = true,
            })

            local lspconfig = require("lspconfig")
            local util = require("lspconfig.util")

            -- Agregar soporte de snippets
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true

            -- Configuración para cssls
            lspconfig.cssls.setup({
                root_dir = util.root_pattern(".git", "package.json", "."),
                capabilities = capabilities,
                settings = {
                    css = { validate = true },
                    less = { validate = true },
                    scss = { validate = true },
                },
            })

            -- Configuración para html
            lspconfig.html.setup({
                root_dir = util.root_pattern(".git", "package.json", "."),
                settings = {
                    html = {
                        format = {
                            enable = true,
                        },
                        hover = {
                            documentation = true,
                            references = true,
                        },
                    },
                },
            })

            -- Configuración genérica para otros servidores LSP
            require("mason-lspconfig").setup_handlers({
                function(server_name)
                    if server_name ~= "cssls" and server_name ~= "html" then
                        lspconfig[server_name].setup({})
                    end
                end,
            })
        end,
    },

    -- Autocompletado
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "rafamadriz/friendly-snippets", -- Colección de snippets
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            require("luasnip.loaders.from_vscode").lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                }, {
                    { name = "buffer" },
                    { name = "path" },
                }),
            })
        end,
    },

    -- Autopairs
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local npairs = require("nvim-autopairs")
            npairs.setup({
                check_ts = true, -- Usa árboles de sintaxis si están disponibles
            })

            -- Integración con nvim-cmp
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            local cmp = require("cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
    },

    -- nvim-treesitter para resaltar sintaxis avanzada
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "html", "css", "javascript" },
                highlight = { enable = true },
                rainbow = { enable = true, extended_mode = true },
            })
        end,
    },
{
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
        require("toggleterm").setup({
            size = 20, -- Altura/anchura del terminal (en modo horizontal/vertical)
            open_mapping = [[<C-t>]], -- Mapeo para abrir/cerrar el terminal
            hide_numbers = true,
            shade_filetypes = {},
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            insert_mappings = true, -- Permitir mapeos en modo Insert
            persist_size = true,
            direction = "horizontal", -- Cambiar a "vertical" o "float" según prefieras
            close_on_exit = true, -- Cierra el terminal al salir del shell
            shell = vim.o.shell, -- Usa el shell por defecto del sistema
            float_opts = {
                border = "curved",
                winblend = 3,
                highlights = {
                    border = "Normal",
                    background = "Normal",
                },
            },
        })
    end,
}
})

