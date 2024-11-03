-- Add the path for Lua modules
-- Add LuaRocks paths to Neovim for a specific Lua version
local lua_version = _VERSION:match("%d+%.%d+")
local home = os.getenv("HOME")
local package_path = home .. "/.luarocks/share/lua/" .. lua_version .. "/?.lua;" ..
                     home .. "/.luarocks/share/lua/" .. lua_version .. "/?/init.lua;" ..
                     "/opt/homebrew/share/lua/" .. lua_version .. "/?.lua;" ..
                     "/opt/homebrew/share/lua/" .. lua_version .. "/?/init.lua"
local install_cpath = home .. "/.luarocks/lib/lua/" .. lua_version .. "/?.so;" ..
                      "/opt/homebrew/lib/lua/" .. lua_version .. "/?.so"

if not package.path:match(package_path) then
    package.path = package_path .. ";" .. package.path
end
if not package.cpath:match(install_cpath) then
    package.cpath = install_cpath .. ";" .. package.cpath
end

-- Basic configurations
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus"
vim.opt.fileformat = "unix"
vim.g.mapleader = " "

-- Python virtual environment setup for Neovim
local function setup_venv()
    local venv_path = vim.fn.stdpath("config") .. "/neovim-venv"
    local python_executable = venv_path .. "/bin/python"

    if vim.fn.empty(vim.fn.glob(venv_path)) > 0 then
        vim.fn.system({ "python3", "-m", "venv", venv_path })
    end

    vim.g.python3_host_prog = python_executable

    local handle = io.popen(venv_path .. "/bin/pip show pynvim")
    local result = handle:read("*a")
    handle:close()
    if result == "" then
        vim.fn.system({ python_executable, "-m", "pip", "install", "pynvim" })
    end
end
setup_venv()

-- Lazy.nvim setup and plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none",
                    "https://github.com/folke/lazy.nvim.git",
                    "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    -- Catppuccin theme
    { "catppuccin/nvim", name = "catppuccin", config = function()
        require("catppuccin").setup({ flavour = "mocha" })
        vim.cmd([[colorscheme catppuccin]])
    end },

    -- Mason for managing tools and LSP servers
    { "williamboman/mason.nvim", config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = { "pyright" },
            automatic_installation = true,
        })
        require("mason-null-ls").setup({
            ensure_installed = { "black", "isort", "flake8", "debugpy", "stylua" },
            automatic_installation = true,
        })
    end, dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "jay-babu/mason-null-ls.nvim",
        "neovim/nvim-lspconfig",
        "jose-elias-alvarez/null-ls.nvim",
    }},

    -- GitHub Copilot auto-start configuration
    { "github/copilot.vim", config = function()
        vim.cmd("Copilot enable")  -- This enables GitHub Copilot to start automatically
    end },

    -- Treesitter for enhanced syntax highlighting
    { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },

    -- Other plugins (e.g., NvimTree, DAP, Comment, etc.)
    { "nvim-tree/nvim-tree.lua" },
    { "nvim-tree/nvim-web-devicons" },
    { "mfussenegger/nvim-dap" },
    { "numToStr/Comment.nvim" },
    { "mfussenegger/nvim-dap-python" },
    { "nvim-lua/plenary.nvim" },

    -- Gitsigns configuration
    { "lewis6991/gitsigns.nvim", config = function()
        require("gitsigns").setup()
    end, dependencies = { "nvim-lua/plenary.nvim" } },

    -- Telescope setup
    { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

    -- Additional plugins and configurations
})

-- Auto-format Python and Lua files on save
vim.api.nvim_create_autocmd("BufWritePre", { pattern = "*.py", callback = function()
    vim.lsp.buf.format({ async = false })
end })
vim.api.nvim_create_autocmd("BufWritePre", { pattern = "*.lua", callback = function()
    vim.lsp.buf.format({ async = false })
end })

-- Treesitter configurations
require("nvim-treesitter.configs").setup({
    ensure_installed = "python",
    highlight = { enable = true },
    indent = { enable = true },
    fold = { enable = true },
})
require("Comment").setup()

-- Set up fold expression with Treesitter
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99

-- Keybinding for formatting
vim.api.nvim_set_keymap("n", "<leader>f", ":lua vim.lsp.buf.format({ async = true })<CR>", { noremap = true, silent = true })

-- NvimTree setup
require("nvim-tree").setup({
    disable_netrw = true,
    sort_by = "case_sensitive",
    view = { width = 30 },
    renderer = { group_empty = true },
    filters = { dotfiles = true },
})

-- Keybindings for Telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

-- Keybinding to toggle NvimTree
vim.api.nvim_set_keymap("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Copilot keybinding for accepting suggestions
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

