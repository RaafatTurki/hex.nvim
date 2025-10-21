# Hex.nvim

![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

Hex editing done right.

Shift address lines around, edit and delete bytes, it will all work itself out on `:w`.

![demo](https://user-images.githubusercontent.com/16624558/211962886-f5e67052-03d8-41c2-844f-720550c935b4.gif)

## Installation

```lua
{ "RaafatTurki/hex.nvim" }
```

This plugin makes use of the `xxd` utility by default, make sure it's on `$PATH`:
- `xxd-standalone` from aur
- compile from [source](https://github.com/vim/vim/tree/master/src/xxd)
- install vim (it comes with it)

> [!NOTE]
>
> No setup or require needed; simply place it in your runtimepath to use.

## Usage

```lua
require("hex").dump()      -- switch to hex view
require("hex").assemble()  -- go back to normal view
require("hex").toggle()    -- switch back and forth
```

Or their Vim cmds:

```
:Hex dump
:Hex assemble
:Hex toggle
```

Any file opens in hex view if opened with `-b`:

```bash
nvim -b file
nvim -b file1 file2
```

## Configuration

Hex.nvim uses a global table for configuration. User options are merged
with the default table prior to initialization unless `vim.g.hex.default`
is set to false. Below are the available options and their default values:

```lua
vim.g.hex = {
  default = true,
  cmd = {
    -- cli command used to dump hex data
    dump   = "xxd -g 1 -u",
    -- cli command used to assemble from hex data
    revert = "xxd -r",
  },
  -- function that runs on BufReadPre to determine if it's binary or not
  checkbin_pre = function()
    -- logic that determines if a buffer contains binary data or not
    -- must return a bool
    local binary_ext = {
      "bin",
      "dll",
      "exe",
      "jpg",
      "jpeg",
      "png",
      "out",
    }
    -- only work on normal buffers
    if vim.bo.ft ~= "" then return false end
    -- check -b flag
    if vim.bo.binary then return true end
    local ext = vim.fn.expand("%:e")
    if vim.tbl_contains(binary_ext, ext) then return true end
    return false
  end,
  -- function that runs on BufReadPost to determine if it's binary or not
  checkbin_post = function()
    -- logic that determines if a buffer contains binary data or not
    -- must return a bool
    local encoding = (vim.bo.fenc ~= "" and vim.bo.fenc) or vim.o.enc
    if encoding ~= "utf-8" then return true end
    return false
  end,
  keymaps = true,
  prettify = {
    enable = true,
    unicode = true,
    hl = {
      border = "Special",
      middle = "Special",
    }
  }
}
```

## Plans

- [ ] Implement pagination
- [x] Implement auto bin detection
- [ ] Transform cursor position across views
- [ ] Create an `xxd` TS parser

Feel free to PR
