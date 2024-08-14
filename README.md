# Neovim Configuration - `init.lua`

This `init.lua` file is a configuration setup for Neovim with several features to enhance the development experience, particularly for Python development. The configuration includes plugins for code formatting, debugging, syntax highlighting, Git integration, and more.

## Features

- **Line Numbers**: Displays absolute and relative line numbers.
- **Clipboard Integration**: Uses the system clipboard for copying and pasting.
- **Unix File Format**: Ensures that files are saved with Unix line endings.
- **Leader Key**: Sets the leader key to `Space`.
- **Python Virtual Environment Setup**: Automatically sets up a Python virtual environment for Neovim on first boot, ensuring the correct Python interpreter and `pynvim` package are used.
- **LazyVim Plugin Management**: Integrates the LazyVim plugin manager for easy plugin management.
- **Git Integration**: Includes GitHub Copilot and Gitsigns for Git integration and code suggestions.
- **Tree-sitter**: Provides improved syntax highlighting and code folding based on Tree-sitter.
- **NvimTree**: File explorer for easy navigation within projects.
- **Auto Formatting**: Automatically formats Python files using `black` on save.
- **DAP**: Configures Debug Adapter Protocol (DAP) for Python debugging.
- **Telescope**: Adds fuzzy finder capabilities for files, buffers, and more.
- **Commenting**: Simplifies commenting code blocks with `Comment.nvim`.
- **Terminal Integration**: Uses `toggleterm.nvim` for terminal management, including Lazygit integration.

## Installation

### 1. Clone the Configuration

Place the `init.lua` file in your Neovim configuration directory, typically located at `~/.config/nvim/`.

### 2. Install Plugins

Upon first startup, the configuration will automatically clone and set up the required plugins using LazyVim. Simply open Neovim and LazyVim will handle the rest.

### 3. Python Virtual Environment

The configuration includes an automatic setup of a Python virtual environment for Neovim. On the first run, it will:

- Create a virtual environment in `~/.config/nvim/neovim-venv`.
- Install the `pynvim` package if it is not already installed.

This ensures that Neovim has access to a proper Python interpreter.

## Key Bindings

- **Toggle NvimTree**: `<leader>e` to toggle the file explorer.
- **Toggle Lazygit**: `<leader>gg` to open Lazygit in a floating terminal.
- **Format Code**: `<leader>f` to format the current buffer using LSP.
- **Telescope**:
  - `<leader>ff` to find files.
  - `<leader>fg` to perform live grep.
  - `<leader>fb` to list open buffers.
  - `<leader>fh` to find help tags.

## Customization

You can further customize this setup by modifying the `init.lua` file. Some customization options include:

- **Changing the Colorscheme**: The colorscheme is set to `duskfox` from the `nightfox.nvim` plugin. You can change this by modifying the relevant section in the plugin setup.
- **Adding or Removing Plugins**: Modify the `require("lazy").setup({})` block to include or exclude plugins as per your needs.
- **Configuring Auto-formatting**: The configuration auto-formats Python files on save using `black`. You can adjust this to include other file types or disable it altogether.

## Dependencies

- **Neovim**: Ensure you have Neovim installed. This configuration is optimized for the latest version.
- **Python 3**: Required for setting up the Python virtual environment.
- **Git**: Used for cloning plugins.
- **Node.js**: Required for some plugins like GitHub Copilot.

## License

This configuration is open-source and free to use under the MIT License.

## Contributions

Feel free to fork this configuration and customize it to your liking. Pull requests are welcome if you'd like to contribute improvements or new features.

---

Enjoy a powerful and customizable Neovim setup with this `init.lua` configuration!
```

This Markdown text includes the complete response with all the instructions, explanations, and details formatted properly for a `README.md` file.
