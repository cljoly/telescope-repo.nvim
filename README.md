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
images:
- /telescope-repo-nvim/opengraph.png
- /telescope-repo-nvim/opengraph.webp
---
{{< github_badge >}}

{{< rawhtml >}}
<div class="badges">
{{< /rawhtml >}}
end_insert -->
<!-- remove -->
# 🦘 telescope-repo.nvim: jump around the repositories in your filesystem, without any setup
<!-- end_remove -->

![Neovim version](https://img.shields.io/badge/Neovim-0.7+-57A143?style=flat&logo=neovim) [![](https://img.shields.io/badge/powered%20by-riss-lightgrey)](https://cj.rs/riss) ![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/cljoly/telescope-repo.nvim?color=darkgreen&sort=semver)

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

{{< asciicast src="/telescope-repo-nvim/telescope.json" preload=1 loop=true start-at="1" autoPlay=true >}}
end_insert -->

Use cases include:
* If you don’t start vim from the shell (from a GUI or as the start command of a terminal), you are most likely in your `$HOME` directory. You then want to jump into your code as quickly as possible and this plugin can help!
* Sometimes, you have the definition of a function and use of it in different repositories  (e.g. a library you wrote and a program using this library). This plugin helps to open the two, for instance in two splits.
* Use of less popular SCMs: some similar extensions rely on strong conventions to find repositories, like “directories containing a `.git` file that is also a directory, all inside directory `X`”. Less popular SCMs like [Pijul][] have a different folder name, and even [`git worktree`][worktree]s don’t fit neatly into these constraint, with their `.git` *files*.

[plenary]: https://github.com/nvim-lua/plenary.nvim
[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
[Pijul]: https://pijul.org/
[worktree]: https://git-scm.com/docs/git-worktree
[^1]: SCM: Source-Control Management

`telescope-repo.nvim` is based on [telescope-ghq.nvim](https://github.com/nvim-telescope/telescope-ghq.nvim)

## Installation

You need to add these in your plugin management system[^2]:
```lua
'nvim-lua/plenary.nvim'
'nvim-telescope/telescope.nvim'
'cljoly/telescope-repo.nvim'
```
And optionally, to load the extension:
```lua
require'telescope'.load_extension'repo'
```

A handy companion plugin is [vim-rooter](https://github.com/airblade/vim-rooter), as it’ll change the current directory according to the current file’s detected project (often, the root of the git repository). To get it to change each *buffer’s* directory, instead of the whole editor by default, add the following Lua to your configuration:
```lua
g['rooter_cd_cmd'] = 'lcd'
```

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

* [`fd`][] to find the repositories on the filesystem with `list`
* [`plocate`][], [`lolcate-rs`][] or [`locate`][] to find the repositories on the filesystem with `cached_list`

[`fd`]: https://github.com/sharkdp/fd
[`locate`]: https://man.archlinux.org/man/locate.1
[`plocate`]: https://man.archlinux.org/man/plocate.1
[`lolcate-rs`]: https://github.com/ngirard/lolcate-rs

### Optional

* [`glow`][] to preview markdown files, will fall back to [`bat`][] if not present (and uses `cat` if neither are present)

[`glow`]: https://github.com/charmbracelet/glow
[`bat`]: https://github.com/sharkdp/bat

## Usage

### Global Configuration

You can change the default argument given to subcommands (like [`list`](#list) or [`cached_list`](#cached_list)) using the telescope `setup` function with a table like this:

```lua
{
  extensions = {
    repo = {
      <subcommand> = {
        <argument> = {
          "new",
          "default",
          "value",
        },
      },
      settings = {
        auto_lcd = true,
      }
    },
  },
}
```

for instance, you could do:

```lua
require("telescope").setup {
  extensions = {
    repo = {
      list = {
        fd_opts = {
          "--no-ignore-vcs",
        },
        search_dirs = {
          "~/my_projects",
        },
      },
    },
  },
}

require("telescope").load_extension "repo"
```

**Note**: make sure to have `require("telescope").load_extension "repo"` *after* the call to `require("telescope").setup {…}`, otherwise the global configuration won’t be taken into account.

### `list`

`:Telescope repo list` or `lua require'telescope'.extensions.repo.list{}`

Running `repo list` and list repositories' paths.

| key              | action               |
|------------------|----------------------|
| `<CR>` (edit)    | `builtin.git_files` for git, falls back to `builtin.find_files` for other SCMs |
| `<C-v>` (vertical)    | `builtin.live_grep` in the selected project |
| `<C-t>` (tab) | Same as `<CR>` but opens a new tab. Also, does a `cd` into the project’s directory for this tab only |

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

##### `search_dirs`

This limits the search to a particular directory or set of directories.

##### Example
```
:lua require'telescope'.extensions.repo.list{search_dirs = {"~/ghq/github.com", "~/ghq/git.sr.ht"}}
:lua require'telescope'.extensions.repo.list{search_dirs = {"~/.local/share/nvim/site/pack"}}
```

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

### `cached_list`

`:Telescope repo cached_list`

This relies on a `locate` command to find repositories. This should be much faster than the `list` command, as it relies on a pre-built index but results may be stalled.

*Note*: at this point, the plugin does not manage index update. Updating the index often requires to run a command like `updatedb` as root.

#### Notes for MacOS

`glocate` command used for caching on MacOS comes with gnu `findutils` which can be installed with
```bash
brew install findutils
```
With `glocate` installed use, add the following to your `.bashrc`/`.zshrc`

``` bash
# https://egeek.me/2020/04/18/enabling-locate-on-osx/
if which glocate > /dev/null; then
  alias locate="glocate -d $HOME/locatedb"

  # Using cache_list requires `LOCATE_PATH` environment var to exist in session.
  # trouble shoot: `echo $LOCATE_PATH` needs to return db path.
  [[ -f "$HOME/locatedb" ]] && export LOCATE_PATH="$HOME/locatedb"
fi

alias loaddb="gupdatedb --localpaths=$HOME --prunepaths=/Volumes --output=$HOME/locatedb"

```

After you have run `loaddb` the first time you need to reload the shell to make sure that it
exports the `LOCATE_PATH` variable. Then the following command should work:

```
lua require'telescope'.extensions.repo.cached_list()
```

If nothing is shown, even after a little while, try this:
```
lua require'telescope'.extensions.repo.cached_list{locate_opts={"-d", vim.env.HOME .. "/locatedb"}}
```

> *Note*: Installation and use of the plugin on systems other than GNU/Linux is community-maintained. Don't hesitate to open [a discussion][discuss-qa] or [a pull-request][pr] if something is not working!

[discuss-qa]: https://github.com/cljoly/telescope-repo.nvim/discussions/categories/q-a
[pr]: https://github.com/cljoly/telescope-repo.nvim/pulls

#### Troubleshooting

You should try to run:
```
sudo updatedb
```
if you encounter any problems. If it’s not the case by default, you should automate such index update with for instance `cron` or `systemd-timers`. See https://wiki.archlinux.org/title/Locate and [this discussion](https://github.com/cljoly/telescope-repo.nvim/discussions/64) for various ways to automate this.

#### Options

Options are the similar to `repo list`, bearing in mind that we use `locate` instead of `fd`. Note that the following `list` options are not supported in `cached_list`:

* `fd_opts`, as we don’t use `fd` with `cached_list`,
* `search_dirs`, as `locate` does not accept a directory to search in.

#### Examples

##### Exclude Irrelevant Results

Chances are you will get results from folders you don’t care about like `.cache` or `.cargo`. In that case, you can use the `file_ignore_patterns` option of Telescope, like so (these are [Lua regexes](https://www.lua.org/manual/5.1/manual.html#5.4.1)).

Hide all git repositories that may be in `.cache` or `.cargo`:
```lua
:lua require'telescope'.extensions.repo.cached_list{file_ignore_patterns={"/%.cache/", "/%.cargo/"}}
```
###### Notes

* These patterns are used to filter the output of the `locate` command, so they don’t speed up the search in any way. You should use them mainly to exclude git repositories you won’t want to jump into, not in the hope to enhance performance.
* The `%.` in Lua regex is an escaped `.` as `.` matches any characters.
* These patterns are applied against whole paths like `/home/myuser/.cache/some/dir`, so if you want to exclude only `/home/myuser/.cache`, you need a more complicated pattern like so:
```lua
:lua require'telescope'.extensions.repo.cached_list{file_ignore_patterns={"^".. vim.env.HOME .. "/%.cache/", "^".. vim.env.HOME .. "/%.cargo/"}}
```

##### Use With Other SCMs

Here is how you can use this plugin with various SCM (we match on the whole path with `locate`, so patterns differ slightly from `repo list`: notice the `^` that becomes a `/`):

| SCM    | Command                                                                    |
|--------|----------------------------------------------------------------------------|
| git    | `:Telescope repo list` or `lua require'telescope'.extensions.repo.list{}`  |
| pijul  | `lua require'telescope'.extensions.repo.list{pattern=[[/\.pijul$]]}`       |
| hg     | `lua require'telescope'.extensions.repo.list{pattern=[[/\.hg$]]}`          |
| fossil | `lua require'telescope'.extensions.repo.list{pattern=[[/\.fslckout$]]}`    |

## FAQ

### No repositories are found

Make sure that `:checkhealth telescope` shows something like:
```markdown
## Telescope Extension: `repo`
  - OK: Will use `glow` to preview markdown READMEs
  - OK: Will use `bat` to preview non-markdown READMEs
  - OK: locate: found `plocate`
    plocate 1.1.13
    Copyright 2020 Steinar H. Gunderson
    License GPLv2+: GNU GPL version 2 or later <https://gnu.org/licenses/gpl.html>.
    This is free software: you are free to change and redistribute it.
    There is NO WARRANTY, to the extent permitted by law.
  - INFO: Repos found for `:Telescope repo cached_list`:
    /home/cj/.cache/yay/android-sdk/.git, /home/cj/.cache/yay/android-sdk-platform-tools/.git...
  - OK: fd: found `fd`
    fd 8.3.0
  - INFO: Repos found for `:Telescope repo list`:
    /home/cj/tmp/git_rst, /home/cj/qmk_firmware...
```
**This may take a few seconds to run**

The output of this command may point to missing dependencies.

### Getting the repository list is slow

If `:Telescope repo list` is slow, you can use your `.fdignore` to exclude some folders from your filesystem. You can even use a custom ignore file with the `--ignore-file` option, like so:
```
lua require'telescope'.extensions.repo.list{fd_opts=[[--ignore-file=myignorefile]]}
```

## Contribute

Contributions are welcome, see this [document](https://cj.rs/docs/contribute/)!

The telescope [developers documentation](https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md) is very useful to understand how plugins work and you may find [these tips](https://cj.rs/blog/tips/nvim-plugin-development/) useful as well.

### Running tests

[Plenary.nvim][plenary] integration tests are executed as a part of the CI checks. However, they are very basic for now and you might be better off just testing the two commands locally.

### Code Formatting & Linting

[StyLua](https://github.com/johnnymorganz/stylua) is used for code formatting. It is run like so:

```bash
make fmt
```

To run the linter:
```bash
make lint
```

## Acknowledgement

I would like to thank all the contributors to this plugin, as well as the developers of neovim and Telescope. Without them, none of this would be possible.

Thanks to *Code Smell* for demoing the plugin in [5 Terrific Neovim Telescope Extensions for 2022 🔭](https://youtu.be/indguFY7wJ0?t=267).

Furthermore, thanks to [Migadu](https://www.migadu.com/) for offering a discounted service to support this project. It is not an endorsement by Migadu though.

## Stability

We understand that you need a reliable plugin that never breaks. To this end, code changes are first tested on our machines in a separate `dev` branch and once we are reasonably confident that changes don’t have unintended side-effects, they get merged to the `master` branch, where a wider user-base will get the changes. We also often tag releases, holding a more mature, coherent set of changes. If you are especially sensitive to changes, instruct your package manager to install the version pointed by a particular tag and watch for new releases [on GitHub](https://github.blog/changelog/2018-11-27-watch-releases/) or [via RSS](https://ronaldsvilcins.com/2020/03/26/rss-feeds-for-your-github-releases-tags-and-activity/). Conversely, if you wish to live on the bleeding-edge, instruct your package manager to use the `dev` branch.

[^2]: See also [Stability](#stability)

## Changelog

### 0.3.0

* Add support for `lolcate-rs` as a `cached_list` provider
* Add an option to restrict the search to some directories
* Add fallback command so that `:Telescope repo` does not error
* Fixes:
    * keep Telescope prompt in insert mode (nvim 0.7+)
    * the `search_dirs` argument is not mandatory
* Dev: add tests, CI, formatting with stylua
* Documentation: update with new features, installation instructions, code formatting reference and other fixes

### 0.2.0

* Add support for `checkhealth`
* Add picker that builds the list of repositories from `locate`, thus taking profit of a system-wide index.
* Add mappings leading to various actions
* Preview non-markdown Readme file

### 0.1.0

* Basic feature, generate a dynamic project list with `fd`
* Falls back to file listing if we are not in a `git` repository
