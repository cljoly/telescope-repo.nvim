# telescope-repo.nvim: jump around the repositories in your filesystem

`telescope-repo` is an extension for [telescope.nvim][] that searches the filesystem for git (or other scm) repositories. One can then select a repository and open files in it.

[![Finding the repositories with “telescope” in their name, with the README in the panel on the right](https://asciinema.org/a/427156.svg)](https://asciinema.org/a/427156)

[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim

**`telescope-repo.nvim` is based on [telescope-repo.nvim](https://github.com/nvim-telescope/telescope-ghq.nvim)**

## Installation

You need to add these in your plugin management system:
```lua
'nvim-telescope/telescope.nvim'
'cljoly/telescope-repo.nvim'
```
And optionally, to load the extension:
```lua
require'telescope'.load_extension'repo'
```

## External dependancies

### Required

- [`fd`][] to find the repositories on the filesystem

[`fd`]: https://github.com/sharkdp/fd

### Optional

- [`glow`][] to preview markdown files, will fallback to [`bat`][] if not present (and uses `cat` if neither are present)

[`glow`]: https://github.com/charmbracelet/glow
[`bat`]: https://github.com/sharkdp/bat

## Usage

Run:
```
:Telescope repo list
```

### list

`:Telescope repo list`

Running `repo list` and list repositories' paths. In default, it does actions below when you input keys.

| key              | action               |
|------------------|----------------------|
| `<CR>` (edit)    | `builtin.git_files`  |
| `<C-x>` (split)  | `:chdir` to the dir  |
| `<C-v>` (vsplit) | `:lchdir` to the dir |
| `<C-t>` (tabnew) | `:tchdir` to the dir |

#### options

#### `bin`

Filepath for the binary `fd`.

```vim
" path can be expanded
:Telescope repo list bin=~/fd
```

#### `pattern`

Pattern of the scm database folder.

Default value: `[[^\.git$]]`

#### `cwd`

Transform the result paths into relative ones with this value as the base dir.

Default value: `vim.fn.getcwd()`

#### `tail_path`

Show only basename of the path.

Default value: `false`

#### `shorten_path`

Call `pathshorten()` for each path.

Default value: `false`

## FAQ

### Getting the repository list is slow

You can use your `.fdignore` to exclude some folders from your filesystem. If there is enough interest, [#1](https://github.com/cljoly/telescope-repo.nvim/issues/1) could further enhance this.

### How to use this plugin with Mercurial (hg), Pijul, Fossil…

Set the `pattern` option to `[[^\.hg$]]`, `[[^\.pijul$]]`…

```
lua require'telescope'.extensions.repo.list{pattern=[[^\.hg$]]}
```

See also [#2](https://github.com/cljoly/telescope-repo.nvim/issues/2), in particular for Fossil.
