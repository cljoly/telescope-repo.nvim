# telescope-ghq.nvim

`telescope-ghq` is an extension for [telescope.nvim][] that provides its users with operating [x-motemen/ghq][].

[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
[x-motemen/ghq]: https://github.com/x-motemen/ghq

## Installation

```lua
use{
  'nvim-telescope/telescope.nvim',
  requires = {
    'delphinus/telescope-ghq.nvim',
  },
  config = function()
    require'telescope'.load_extension'ghq'
  end,
}
```

## Usage

Now supports `ghq list` only.

TODO: others

### list

`:Telescope ghq_list`

Running `ghq list` and list repositories' paths. When you input `<CR>`, it runs `builtin.git_files` on the repo.
