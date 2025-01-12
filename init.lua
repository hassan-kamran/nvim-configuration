-- Add the path for Lua modules
-- Add LuaRocks paths to Neovim for a specific Lua version
local lua_version = _VERSION:match("%d+%.%d+")
local home = os.getenv("HOME")
local package_path = home
	.. "/.luarocks/share/lua/"
	.. lua_version
	.. "/?.lua;"
	.. home
	.. "/.luarocks/share/lua/"
	.. lua_version
	.. "/?/init.lua;"
	.. "/opt/homebrew/share/lua/"
	.. lua_version
	.. "/?.lua;"
	.. "/opt/homebrew/share/lua/"
	.. lua_version
	.. "/?/init.lua"
local install_cpath = home
	.. "/.luarocks/lib/lua/"
	.. lua_version
	.. "/?.so;"
	.. "/opt/homebrew/lib/lua/"
	.. lua_version
	.. "/?.so"

if not package.path:match(package_path) then
	package.path = package_path .. ";" .. package.path
end

if not package.cpath:match(install_cpath) then
	package.cpath = install_cpath .. ";" .. package.cpath
end

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
		vim.fn.system({ "python3", "-m", "venv", venv_path })
	end

	-- Set Neovim to use this Python interpreter
	vim.g.python3_host_prog = python_executable

	-- Check if pynvim is installed, if not, install it
	local handle = io.popen(venv_path .. "/bin/pip show pynvim")
	local result = handle:read("*a")
	handle:close()

	if result == "" then
		vim.fn.system({ python_executable, "-m", "pip", "install", "pynvim" })
	end
end

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
	-- Catppuccin theme setup
	{
		"catppuccin/nvim",
		name = "catppuccin",
		config = function()
			require("catppuccin").setup({
				flavour = "mocha", -- Set the flavor to mocha
			})
			vim.cmd([[colorscheme catppuccin]])
		end,
	},

	-- Mason for managing LSP servers, DAP servers, linters, and formatters
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()

			require("mason-lspconfig").setup({
				ensure_installed = {
					"ruff",
					"html",
					"cssls",
					"ts_ls",
					"emmet_ls",
				},
				automatic_installation = true,
			})

			require("mason-null-ls").setup({
				ensure_installed = {
					"ruff",
					"prettier",
					"stylua",
				},
				automatic_installation = true,
			})
		end,
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"jay-babu/mason-null-ls.nvim",
			"neovim/nvim-lspconfig",
			"jose-elias-alvarez/null-ls.nvim",
		},
	},

	-- GitHub Copilot integration
	{
		"github/copilot.vim",
		config = function()
			vim.cmd("Copilot enable")
		end,
	},

	-- Treesitter for improved syntax highlighting
	{ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" },

	-- NvimTree for file management
	{ "nvim-tree/nvim-tree.lua" },
	{ "nvim-tree/nvim-web-devicons" },

	-- DAP (Debug Adapter Protocol) setup
	{ "mfussenegger/nvim-dap" },

	-- Add Comment.nvim for commenting
	{ "numToStr/Comment.nvim" },

	-- DAP for Python
	{ "mfussenegger/nvim-dap-python" },

	-- Plenary dependency for Lua utilities
	{ "nvim-lua/plenary.nvim" },

	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Null-ls setup
	{
		"jose-elias-alvarez/null-ls.nvim",
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				debug = true,
				sources = {
					-- Ruff for Python
					null_ls.builtins.formatting.ruff,
					null_ls.builtins.diagnostics.ruff,

					-- Web development formatting
					null_ls.builtins.formatting.prettier.with({
						filetypes = {
							"html",
							"css",
							"javascript",
							"typescript",
							"json",
						},
					}),

					-- Lua formatting
					null_ls.builtins.formatting.stylua,
				},
			})
		end,
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	-- Indent-blankline setup for version 3
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {},
	},

	-- Autocompletion and snippets setup
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
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
				mapping = {
					["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
					["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
					["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
					["<C-y>"] = cmp.config.disable,
					["<C-e>"] = cmp.mapping({
						i = cmp.mapping.abort(),
						c = cmp.mapping.close(),
					}),
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
				},
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				}, {
					{ name = "buffer" },
				}),
			})

			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},

	-- toggleterm.nvim for Lazygit integration
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				open_mapping = [[<c-\>]],
				direction = "float",
				float_opts = {
					border = "curved",
				},
			})

			local Terminal = require("toggleterm.terminal").Terminal
			local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

			function _LAZYGIT_TOGGLE()
				lazygit:toggle()
			end

			vim.api.nvim_set_keymap("n", "<leader>gg", ":lua _LAZYGIT_TOGGLE()<CR>", { noremap = true, silent = true })
		end,
	},
})

-- Auto-format on save
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.py", "*.lua", "*.html", "*.css", "*.js", "*.ts", "*.jsx", "*.tsx" },
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

-- Tree-sitter configuration
require("nvim-treesitter.configs").setup({
	ensure_installed = {
		"python",
		"html",
		"css",
		"javascript",
		"typescript",
		"lua",
	},
	highlight = { enable = true },
	indent = { enable = true },
	fold = { enable = true },
})

require("Comment").setup()

-- Folding settings
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99

-- Keybindings
vim.api.nvim_set_keymap(
	"n",
	"<leader>f",
	":lua vim.lsp.buf.format({ async = true })<CR>",
	{ noremap = true, silent = true }
)

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

-- Disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Enable termguicolors
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

-- LSP Setups
local on_attach = function(client, bufnr)
	local opts = { noremap = true, silent = true }
	vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
	vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<Cmd>lua vim.lsp.buf.code_action()<CR>", opts)
end

-- Ruff LSP setup
require("lspconfig").ruff.setup({
	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
		on_attach(client, bufnr)
	end,
})

-- Web development LSP setups
local web_capabilities = require("cmp_nvim_lsp").default_capabilities()

require("lspconfig").html.setup({
	capabilities = web_capabilities,
	on_attach = on_attach,
})

require("lspconfig").cssls.setup({
	capabilities = web_capabilities,
	on_attach = on_attach,
})

require("lspconfig").ts_ls.setup({
	capabilities = web_capabilities,
	on_attach = on_attach,
})

require("lspconfig").emmet_ls.setup({
	capabilities = web_capabilities,
	filetypes = {
		"html",
		"css",
		"javascript",
		"typescript",
		"javascriptreact",
		"typescriptreact",
	},
})

-- NvimTree toggle
vim.api.nvim_set_keymap("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Copilot keybinding
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

-- Additional LSP diagnostic settings
vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

-- Diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Python DAP configuration
local dap = require("dap")
local dap_python = require("dap-python")
dap_python.setup("python")

-- Configure Python test methods
dap_python.test_runner = "pytest"

-- DAP keymappings
vim.keymap.set("n", "<leader>db", function()
	require("dap").toggle_breakpoint()
end)
vim.keymap.set("n", "<leader>dc", function()
	require("dap").continue()
end)
vim.keymap.set("n", "<leader>di", function()
	require("dap").step_into()
end)
vim.keymap.set("n", "<leader>do", function()
	require("dap").step_over()
end)
vim.keymap.set("n", "<leader>dO", function()
	require("dap").step_out()
end)
vim.keymap.set("n", "<leader>dr", function()
	require("dap").repl.toggle()
end)
vim.keymap.set("n", "<leader>dl", function()
	require("dap").run_last()
end)
vim.keymap.set("n", "<leader>dt", function()
	require("dap-python").test_method()
end)
vim.keymap.set("n", "<leader>dT", function()
	require("dap-python").test_class()
end)

-- Additional general settings
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.shiftwidth = 4 -- Size of an indent
vim.opt.tabstop = 4 -- Number of spaces tabs count for
vim.opt.smartindent = true -- Insert indents automatically
vim.opt.wrap = false -- Don't wrap lines
vim.opt.ignorecase = true -- Ignore case in search patterns
vim.opt.smartcase = true -- Override ignorecase if search pattern contains upper case characters
vim.opt.cursorline = true -- Highlight the current line
vim.opt.mouse = "a" -- Enable mouse support
vim.opt.updatetime = 250 -- Decrease update time
vim.opt.signcolumn = "yes" -- Always show the signcolumn
vim.opt.scrolloff = 8 -- Lines of context
vim.opt.sidescrolloff = 8 -- Columns of context
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current
vim.opt.timeoutlen = 300 -- Time in milliseconds to wait for a mapped sequence to complete

-- Additional key mappings for better navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Better window resizing
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>")
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>")
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>")

-- Better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Move selected line / block of text in visual mode
vim.keymap.set("x", "K", ":move '<-2<CR>gv-gv")
vim.keymap.set("x", "J", ":move '>+1<CR>gv-gv")

-- Better terminal navigation
vim.keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k")
vim.keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l")

-- Additional LSP keybindings
vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition)
vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder)
vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder)
vim.keymap.set("n", "<leader>wl", function()
	print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end)

-- Format on save for specific file types (in addition to existing ones)
vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.json", "*.md", "*.yaml", "*.yml" },
	callback = function()
		vim.lsp.buf.format({ async = false })
	end,
})

-- Auto commands for better user experience
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "qf", "help", "man", "lspinfo", "spectre_panel" },
	callback = function()
		vim.cmd([[
            nnoremap <silent> <buffer> q :close<CR>
            set nobuflisted
        ]])
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Remember cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	callback = function()
		local mark = vim.api.nvim_buf_get_mark(0, '"')
		local lcount = vim.api.nvim_buf_line_count(0)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- Auto reload files when changed on disk
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
	pattern = "*",
	callback = function()
		if vim.fn.mode() ~= "c" then
			vim.cmd("checktime")
		end
	end,
})

-- Use relative line numbers in normal mode and absolute line numbers in insert mode
vim.api.nvim_create_autocmd({ "InsertEnter" }, {
	callback = function()
		vim.opt.relativenumber = false
	end,
})

vim.api.nvim_create_autocmd({ "InsertLeave" }, {
	callback = function()
		vim.opt.relativenumber = true
	end,
})

-- Setup global status line
vim.opt.laststatus = 3

-- Initialize workspace diagnostics
vim.diagnostic.config({
	virtual_text = {
		source = "always",
		prefix = "●",
	},
	float = {
		source = "always",
	},
})
