# Hex.nvim
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

Hex editing done right

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

  -- file extensions treated as binary files (passed to is_binary_file())
  binary_ext = { 'out', 'bin', 'png', 'jpg', 'jpeg' },
  
  -- function that runs on every buffer to determine if it's binary or not
  is_binary_file = function(binary_ext)
    local filename = vim.fn.expand('%:t')
    local ext = string.match(filename, "%.([^%.]+)$")
    -- file has no ext and no upper case letters
    if ext == nil and not string.match(filename, '%u') then return true end
    -- ext is in binary_ext
    if vim.tbl_contains(binary_ext, ext) then return true end
    return false
  end,
}
```

## Plans
- [ ] Implement pagination
- [ ] Implement auto bin detection
- [ ] Transform cursor position across views
- [ ] Create an `xxd` TS parser

Feel free to PR
