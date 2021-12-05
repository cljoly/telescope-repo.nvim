<!-- insert
---
title: "telescope-repo.nvim"
date: 2021-08-21T10:02:37
description: "🦘 Jump into the repositories of your filesystem, without any setup"
repo_url: "https://github.com/cljoly/telescope-repo.nvim"
aliases:
- /telescope-repo.nvim
tags:
- NeoVim
- Lua
- Plugin
---
{{< github_badge >}}

{{< rawhtml >}}
<div class="badges">
{{< /rawhtml >}}
end_insert -->
<!-- remove -->
# 🦘 telescope-repo.nvim: jump around the repositories in your filesystem, without any setup
<!-- end_remove -->

![Neovim version](https://img.shields.io/badge/Neovim-0.5-57A143?style=flat&logo=neovim) [![](https://img.shields.io/badge/powered%20by-riss-lightgrey)](https://cj.rs/riss) ![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/cljoly/telescope-repo.nvim?color=darkgreen&sort=semver)

<!-- insert
{{< rawhtml >}}
</div>
{{< /rawhtml >}}
end_insert -->

`telescope-repo` is an extension for [telescope.nvim][] that searches the filesystem for *git* (or other SCM[^1], like *Pijul*, *Mercurial*…) repositories. It does not require any setup: the list of repositories is built on the fly over your whole `$HOME`, you don’t need to manually add projects or open some folders to populate this list, as opposed to [telescope-project.nvim](https://github.com/nvim-telescope/telescope-project.nvim) or [project.nvim](https://github.com/ahmedkhalf/project.nvim).

<!-- remove -->
[![Finding the repositories with “telescope” in their name, with the README in the panel on the top](https://asciinema.org/a/431528.svg)](https://asciinema.org/a/431528)
<!-- end_remove -->
<!-- insert
Finding the repositories with “telescope” in their name, with the README in the panel on the top:

{{< asciicast src="/telescope-repo-nvim/telescope.json" preload=1 loop="true" start-at="1" >}}
end_insert -->

Use cases include:
* If you don’t start vim from the shell (from a GUI or as the start command of a terminal), you are most likely in your `$HOME` directory. You then want to jump into your code as quickly as possible and this plugin can help!
* Sometimes, you have the definition of a function and use of it in different repositories  (e.g. a library you wrote and a program using this library). This plugin helps to open the two, for instance in two splits.
* Use of less popular SCMs: some similar extensions rely on strong conventions to find repositories, like “directories containing a `.git` file that is also a directory, all inside directory `X`”. Less popular SCMs like [Pijul][] have a different folder name, and even [`git worktree`][worktree]s don’t fit neatly into these constraint, with their `.git` *files*.

[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
[Pijul]: https://pijul.org/
[worktree]: https://git-scm.com/docs/git-worktree
[^1]: SCM: Source-Control Management

`telescope-repo.nvim` is based on [telescope-ghq.nvim](https://github.com/nvim-telescope/telescope-ghq.nvim)

## Installation

You need to add these in your plugin management system:
```lua
'nvim-lua/plenary.nvim'
'nvim-telescope/telescope.nvim'
'cljoly/telescope-repo.nvim'
```
And optionally, to load the extension:
```lua
require'telescope'.load_extension'repo'
```

A handy companion plugin is [vim-rooter](https://github.com/airblade/vim-rooter), as it’ll change the current directory according to the current file’s detected project (often, the root of the git repository).

### Packer

For instance, with [Packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use 'cljoly/telescope-repo.nvim'
use {
  'nvim-telescope/telescope.nvim',
  requires = { {'nvim-lua/plenary.nvim'} }
}
```

## External Dependencies

### Required

* [`fd`][] to find the repositories on the filesystem

[`fd`]: https://github.com/sharkdp/fd

### Optional

* [`glow`][] to preview markdown files, will fall back to [`bat`][] if not present (and uses `cat` if neither are present)

[`glow`]: https://github.com/charmbracelet/glow
[`bat`]: https://github.com/sharkdp/bat

## Usage

### list

`:Telescope repo list` or `lua require'telescope'.extensions.repo.list{}`

Running `repo list` and list repositories' paths.

| key              | action               |
|------------------|----------------------|
| `<CR>` (edit)    | `builtin.git_files` for git, falls back to `builtin.find_files` for other SCMs |

#### Options

##### `bin`

Filepath for the binary `fd`.

```vim
" path can be expanded
:Telescope repo list bin=~/fd
```

##### `pattern`

Pattern of the SCM database folder.

Default value: `[[^\.git$]]`

##### `cwd`

Transform the result paths into relative ones with this value as the base dir.

Default value: `vim.fn.getcwd()`

##### `fd_opts`

**This is a relatively advanced option that you should use with caution. There is no guarantee that a particular set of options would work the same across multiple versions**

This passes additional options to the command `fd` that generates the repository list. It is inserted like so:

```
fd [set of default options] [fd_opts] --exec [some default command] [pattern] …
```

##### Example

Let’s say you have a git repository `S` inside another git repository `M` (for instance because of [#5](https://github.com/cljoly/telescope-repo.nvim/issues/5)), but `S` is in a directory that’s ignored in the `.gitignore` in `M`. `S` wouldn’t appear in the Telescope list of this extension by default, because it is ignored (`.gitignore` are taken into account by default).

To avoid taking into account the `.gitignore`, we need to pass `--no-ignore-vcs` to `fd`, like so (in NeoVim):

```
:lua require'telescope'.extensions.repo.list{fd_opts={'--no-ignore-vcs'}}
```

This will list `M` and `S` in the Telescope output! The downside is that listing repositories will be a little longer, as we don’t skip the git-ignored files anymore.

##### `tail_path`

Show only basename of the path.

Default value: `false`

##### `shorten_path`

Call `pathshorten()` for each path. This will for instance transform `/home/me/code/project` to `/h/m/c/project`.

Default value: `false`

#### Examples

Here is how you can use this plugin with various SCM:

| SCM    | Command                                                                    |
|--------|----------------------------------------------------------------------------|
| git    | `:Telescope repo list` or `lua require'telescope'.extensions.repo.list{}`  |
| pijul  | `lua require'telescope'.extensions.repo.list{pattern=[[^\.pijul$]]}`       |
| hg     | `lua require'telescope'.extensions.repo.list{pattern=[[^\.hg$]]}`          |
| fossil | `lua require'telescope'.extensions.repo.list{pattern=[[^\.fslckout$]]}`    |

Is your favorite SCM missing? It should be straightforward to support it by changing the pattern parameter. If you want it to be considered for addition here, open a PR!

## FAQ

### Getting the repository list is slow

You can use your `.fdignore` to exclude some folders from your filesystem. You can even use a custom ignore file with the `--ignore-file` option, like so:

```
lua require'telescope'.extensions.repo.list{fd_opts=[[--ignore-file=myignorefile]]}
```

## Contribute

Contributions are welcome, see this [document](https://cj.rs/docs/contribute/)!

The telescope [developers documentation](https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md) is very useful to understand how plugins work and you may find [these tips](https://cj.rs/blog/tips/nvim-plugin-development/) useful.
