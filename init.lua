-- Enable line numbers and relative line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Set Neovim to use the system clipboard
vim.opt.clipboard = "unnamedplus"

-- Set file format to Unix
vim.opt.fileformat = "unix"

-- Set leader key to space
vim.g.mapleader = " "

-- Set up a Python virtual environment for Neovim on first boot
local function setup_venv()
  local venv_path = vim.fn.stdpath("config") .. "/neovim-venv"
  local python_executable = venv_path .. "/bin/python"

  -- Check if the venv exists, if not, create it
  if vim.fn.empty(vim.fn.glob(venv_path)) > 0 then
    vim.fn.system({"python3", "-m", "venv", venv_path})
  end

  -- Set Neovim to use this Python interpreter
  vim.g.python3_host_prog = python_executable

  -- Check if pynvim is installed, if not, install it
  local handle = io.popen(venv_path .. "/bin/pip show pynvim")
  local result = handle:read("*a")
  handle:close()

  if result == "" then
    vim.fn.system({python_executable, "-m", "pip", "install", "pynvim"})
  else
  end
end

-- Call the function to ensure the venv is set up
setup_venv()

-- Call the function to ensure the venv is set up
setup_venv()

-- LazyVim and plugin setup
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup with LazyVim
require("lazy").setup({
  -- Colorscheme
  {
    "EdenEast/nightfox.nvim",
    config = function()
      vim.cmd [[colorscheme duskfox]]
    end,
  },

  -- Mason for managing LSP servers, DAP servers, linters, and formatters
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()

      require("mason-lspconfig").setup({
        ensure_installed = { "pyright" }, -- Ensure pyright is installed by Mason
        automatic_installation = true,
      })

      -- Auto-install tools like black via Mason
      require("mason-null-ls").setup({
        ensure_installed = { "black", "isort", "flake8", "debugpy" },  -- Add more tools as needed
        automatic_installation = true,
      })
    end,
    dependencies = {
      "williamboman/mason-lspconfig.nvim",  -- Bridge Mason with LSPconfig
      "jay-babu/mason-null-ls.nvim",       -- Bridge Mason with null-ls
      "neovim/nvim-lspconfig",             -- LSP configuration
      "jose-elias-alvarez/null-ls.nvim",   -- Configure formatters/linters
    },
  },

  -- GitHub Copilot integration
  { "github/copilot.vim" },

  -- Treesitter for improved syntax highlighting
  { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },

  -- NvimTree for file management
  { "nvim-tree/nvim-tree.lua" },

  { "nvim-tree/nvim-web-devicons" },

  -- DAP (Debug Adapter Protocol) setup
  { "mfussenegger/nvim-dap" },

  -- Add Comment.nvim for commenting
  { 'numToStr/Comment.nvim' },

  -- DAP for Python
  { "mfussenegger/nvim-dap-python" },

  -- Plenary dependency for Lua utilities
  { "nvim-lua/plenary.nvim" },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup()
    end,
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Null-ls setup for code formatting with black
  {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        debug = true,  -- Enable debugging
        sources = {
          null_ls.builtins.formatting.black,
          null_ls.builtins.formatting.isort,
          null_ls.builtins.diagnostics.flake8,
        },
      })
    end,
    dependencies = { "nvim-lua/plenary.nvim" },  -- Ensure plenary is loaded
  },

  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  -- Indent-blankline setup for version 3
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",  -- Version 3 configuration
    opts = {},     -- Empty opts table to use default settings
  },

  -- toggleterm.nvim for Lazygit integration
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup{
        open_mapping = [[<c-\>]],
        direction = 'float',
        float_opts = {
          border = 'curved',
        },
      }

      -- Lazygit integration
      local Terminal  = require('toggleterm.terminal').Terminal
      local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

      function _LAZYGIT_TOGGLE()
        lazygit:toggle()
      end

      vim.api.nvim_set_keymap('n', '<leader>gg', ':lua _LAZYGIT_TOGGLE()<CR>', { noremap = true, silent = true })
    end,
  }
})

-- Auto-format Python files on save using black
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Tree-sitter configuration
require'nvim-treesitter.configs'.setup {
  ensure_installed = "python",  -- or other languages you want to support
  highlight = {
    enable = true,              -- Enable Tree-sitter based syntax highlighting
  },
  indent = {
    enable = true,              -- Enable Tree-sitter based indentation
  },
  fold = {
    enable = true,              -- Enable Tree-sitter based folding
  },
}

require('Comment').setup()

-- Set foldmethod to expr and use Treesitter's fold expression
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 99  -- Open all folds by default

-- Keybinding to manually trigger formatting
vim.api.nvim_set_keymap('n', '<leader>f', ':lua vim.lsp.buf.format({ async = true })<CR>', { noremap = true, silent = true })

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- NvimTree setup
require("nvim-tree").setup({
  disable_netrw = true,
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
})

vim.api.nvim_set_keymap('n', '<leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })