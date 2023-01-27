# Hex.nvim
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

Hex editing done right.

Shift address lines around, edit and delete bytes, it will all work itself out on `:w`.

![demo](https://user-images.githubusercontent.com/16624558/211962886-f5e67052-03d8-41c2-844f-720550c935b4.gif)

## Install
```lua
{ 'RaafatTurki/hex.nvim' }
```
This plugin makes use of the `xxd` utility by default, make sure it's on `$PATH`:
- `xxd-standalone` from aur
- compile from [source](https://github.com/vim/vim/tree/master/src/xxd)
- install vim (it comes with it)


## Setup
```lua
require 'hex'.setup()
```

## Use
```lua
require 'hex'.dump()      -- switch to hex view
require 'hex'.assemble()  -- go back to normal view
require 'hex'.toggle()    -- switch back and forth
```
or their vim cmds
```
:HexDump
:HexAssemble
:HexToggle
```
any file opens in hex view if opened with `-b`:
```bash
nvim -b file
nvim -b file1 file2
```

## Config
```lua
-- defaults
require 'hex'.setup {

  -- cli command used to dump hex data
  dump_cmd = 'xxd -g 1 -u',

  -- cli command used to assemble from hex data
  assemble_cmd = 'xxd -r',
  
  -- function that runs on BufReadPre to determine if it's binary or not
  is_buf_binary_pre_read = function()
    -- logic that determines if a buffer contains binary data or not
    -- must return a bool
  end,

  -- function that runs on BufReadPost to determine if it's binary or not
  is_buf_binary_post_read = function()
    -- logic that determines if a buffer contains binary data or not
    -- must return a bool
  end,
}
```

## Plans
- [ ] Implement pagination
- [x] Implement auto bin detection
- [ ] Transform cursor position across views
- [ ] Create an `xxd` TS parser

Feel free to PR
