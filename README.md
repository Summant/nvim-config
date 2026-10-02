# nvim-config

My Neovim configuration. Works unchanged on **Arch Linux** and **macOS** (both with kitty).

Originally a [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) fork; since
restructured into modules and updated for the Neovim 0.11+ native LSP and the
nvim-treesitter `main` rewrite.

## Layout

```
init.lua                  leader keys, loads the modules below
lua/config/
  options.lua             editor options
  keymaps.lua             non-plugin keymaps
  autocmds.lua            autocommands
  platform.lua            Linux/macOS differences live here, nowhere else
  lazy.lua                plugin-manager bootstrap
lua/plugins/              one file per concern, auto-loaded
  ui.lua                  colourscheme, lualine, bufferline, file tree, which-key
  editor.lua              gitsigns, indent guides, colorizer, trouble, snacks
  telescope.lua           fuzzy finding
  lsp.lua                 language servers via mason + vim.lsp.config
  completion.lua          blink.cmp
  format.lua              conform.nvim (format on save)
  treesitter.lua          parsers, sticky context, rainbow brackets
  dap.lua                 C/C++ debugging
  notebook.lua            Jupyter notebooks
lua/custom/plugins/       drop extra plugin specs here
```

## Install

```sh
git clone <this repo> ~/.config/nvim
nvim                      # lazy.nvim bootstraps itself and installs everything
```

Plugin versions are pinned in `lazy-lock.json` — commit it after `:Lazy update`
to keep both machines identical.

### System dependencies

Everything below is optional; Neovim starts fine without it and tells you what's
missing when you use the relevant feature.

| for | Arch | macOS |
|---|---|---|
| base | `git base-devel ripgrep fd unzip` | `brew install git ripgrep fd` + Xcode CLT |
| C/C++ LSP | `clang` | ships with Xcode CLT |
| C/C++ debugging | `lldb` | ships with Xcode CLT |
| font | `ttf-jetbrains-mono-nerd` | `brew install --cask font-jetbrains-mono-nerd-font` |
| clipboard | `wl-clipboard` (Wayland) | built in |
| notebooks | see below | see below |

Language servers, formatters and linters install themselves through
[mason](https://github.com/mason-org/mason.nvim) on first launch — `clangd` is
only installed if it isn't already on `PATH`.

### Jupyter notebooks

```sh
# Arch
sudo pacman -S --needed python-pynvim jupyter-nbformat python-jupyter-client \
                        python-ipykernel python-pillow python-cairosvg \
                        python-pyperclip imagemagick
yay -S python-jupytext

# macOS
brew install imagemagick
pip install pynvim jupytext jupyter_client ipykernel nbformat pillow cairosvg pyperclip
```

Then in Neovim once: `:UpdateRemotePlugins`, and restart.

Opening a `.ipynb` shows it as markdown with `python` code fences. `<leader>ji`
starts a kernel, `<leader>jc` runs the cell under the cursor. Plots render inline
through kitty's graphics protocol. Saving writes valid `.ipynb` back out.

## Keys

Leader is `<Space>`.

### Finding

| key | does |
|---|---|
| `<C-p>` | files (git-aware: tracked files in a repo, all files otherwise) |
| `<leader>sf` / `<leader>sg` | search [f]iles / by [g]rep |
| `<leader>sw` / `<leader>sd` | search current [w]ord / [d]iagnostics |
| `<leader>sh` / `<leader>sk` | [h]elp tags / [k]eymaps |
| `<leader>s.` / `<leader><leader>` | recent files / open buffers |
| `<leader>/` | fuzzy-find in the current buffer |
| `<leader>sn` | edit this config |

### Moving

| key | does |
|---|---|
| `<leader>e` | file explorer |
| `<S-h>` / `<S-l>` | previous / next buffer |
| `<C-h/j/k/l>` | move between splits |
| `gd` / `gD` | go to definition / declaration |
| `grr` / `gri` / `grt` | references / implementations / type definition |
| `gO` / `gW` | document / workspace symbols |
| `K` | hover docs |

### Editing

| key | does |
|---|---|
| `<Tab>` | accept completion (popup appears as you type) |
| `<C-space>` | force the completion popup / toggle its docs |
| `grn` / `gra` | rename / code action |
| `<leader>f` | format buffer (also on save, except C/C++) |
| `<leader>th` | toggle inlay hints |

### Git

| key | does |
|---|---|
| `]c` / `[c` | next / previous hunk |
| `<leader>hs` / `<leader>hr` | stage / reset hunk |
| `<leader>hp` / `<leader>hb` / `<leader>hd` | preview / blame / diff |
| `<leader>gg` | lazygit |

### Diagnostics

| key | does |
|---|---|
| `<leader>xx` / `<leader>xb` | diagnostics: workspace / buffer |
| `<leader>xs` / `<leader>xq` | symbols outline / quickfix |
| `<leader>q` | diagnostics to the location list |

### Debugging (C/C++)

| key | does |
|---|---|
| `F5` / `F10` / `F11` / `F12` | continue / step over / into / out |
| `<leader>b` / `<leader>B` | breakpoint / conditional breakpoint |
| `<leader>du` / `<leader>dr` | toggle DAP UI / open REPL |

### Notebooks

| key | does |
|---|---|
| `<leader>ji` / `<leader>jR` | start / restart kernel |
| `<leader>jc` / `<leader>jl` | run cell under cursor / current line |
| `<leader>jv` | run visual selection |
| `<leader>jo` / `<leader>jh` | show / hide output |
| `<leader>jx` | interrupt |

## Notes

- **Transparent background** on purpose, so the terminal's own opacity and
  wallpaper show through. Set `transparent = false` in `lua/plugins/ui.lua` if
  you want a solid background.
- **Format on save** is on everywhere except C and C++ — use `<leader>f` there.
- **Platform differences** are confined to `lua/config/platform.lua`. If something
  needs to differ between Linux and macOS, it belongs in that file.
