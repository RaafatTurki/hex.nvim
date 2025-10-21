if vim.g.loaded_hex == 1 then return end
vim.g.loaded_hex = 1

if vim.fn.executable("xxd") == 0 then
  vim.notify(
    "Required executable `xxd` not found.",
    vim.log.levels.ERROR,
    { title = "hex" })
  return
end

vim.api.nvim_create_user_command("Hex", function(opts)
  if opts.fargs[2] ~= nil then
    vim.notify(
      "Too many arguments.",
      vim.log.levels.ERROR,
      { title = "hex" }
    )
    return
  end
  local arg = opts.fargs[1]
  if arg == "dump" then
    require("hex").dump()
  elseif arg == "revert" then
    require("hex").revert()
  elseif arg == "toggle" then
    require("hex").toggle()
  else
    vim.notify(
      "Hex accepts the following arguments:\n" ..
      "  - dump\n" ..
      "  - revert\n" ..
      "  - toggle",
      vim.log.levels.ERROR,
      { title = "hex" }
    )
  end
end, {
  nargs = "+",
  complete = function()
    -- TODO: needs to complete properly
    return {
      "dump",
      "revert",
      "toggle",
    }
  end
})

-- Configuration {{{
local DEFAULTS = {
  default = true,
  cmd = {
    dump   = "xxd -g 1 -u",
    revert = "xxd -r",
  },
  checkbin_pre = function()
    local binary_ext = {
      "bin",
      "dll",
      "exe",
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
  checkbin_post = function()
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

if vim.g.hex == nil or vim.g.hex.default ~= false then
  vim.g.hex = vim.tbl_deep_extend(
    "force",
    DEFAULTS,
    vim.g.hex or {}
  )
end
-- }}}

local config = vim.g.hex

-- Keymaps {{{
vim.keymap.set("n", "<Plug>(HexUndo)", function()
  if vim.b.hex then
    vim.b.hex_did_undoredo = true
  end
  vim.cmd.undo()
end, { silent = true })
vim.keymap.set("n", "<Plug>(HexRedo)", function()
  if vim.b.hex then
    vim.b.hex_did_undoredo = true
  end
  vim.cmd.redo()
end, { silent = true })

if config.keymaps == true then
  vim.keymap.set("n", "u", "<Plug>(HexUndo)", { desc = "Undo one change" })
  vim.keymap.set("n", "<C-r>", "<Plug>(HexRedo)", { desc = "Redo one change which was undone" })
end
-- }}}

-- Autocommands {{{
local group = vim.api.nvim_create_augroup("Hex", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPre" }, {
  group = group,
  callback = function()
    if config.checkbin_pre() then
      vim.b.hex = true
    end
  end
})

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  group = group,
  callback = function()
    if vim.b.hex or config.checkbin_post() then
      vim.b.hex = true
      require("hex").hex_dump()
      require("hex.render").prettify()
    end
  end
})

vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = group,
  callback = function()
    if vim.b.hex then
      require("hex").patch_start()
    end
  end
})

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  group = group,
  callback = function()
    if vim.b.hex then
      require("hex").patch_finish()
      require("hex").save_undo()
    end
  end
})

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
  group = group,
  callback = function()
    if vim.b.hex then
      local EDIT_LIMIT_LEFT = vim.b.hex_offset + 1
      local EDIT_LIMIT_RIGHT = vim.b.hex_offset + vim.b.hex_limit
      local row, col = unpack(vim.api.nvim_win_get_cursor(0))
      if col < EDIT_LIMIT_LEFT then
        vim.api.nvim_win_set_cursor(0, { row, EDIT_LIMIT_LEFT })
      elseif col > EDIT_LIMIT_RIGHT then
        vim.api.nvim_win_set_cursor(0, { row, EDIT_LIMIT_RIGHT })
      end
    end
  end
})

vim.api.nvim_create_autocmd("ModeChanged", {
  group = group,
  pattern = "*V",
  callback = function()
    if vim.b.hex then
      vim.notify(
        "Linewise Visual mode is not allowed in `xxd` files.",
        vim.log.levels.ERROR,
        { title = "hex" })
      local keys = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
      vim.api.nvim_feedkeys(keys, "n", false)
    end
  end
})

vim.api.nvim_create_autocmd({ "InsertCharPre" }, {
  callback = function()
    if vim.b.hex then
      if vim.tbl_contains({
            "G", "H", "I", "J",
            "K", "L", "M", "N",
            "O", "P", "Q", "R",
            "S", "T", "U", "V",
            "W", "X", "Y", "Z",
            "g", "h", "i", "j",
            "k", "l", "m", "n",
            "o", "p", "q", "r",
            "s", "t", "u", "v",
            "w", "x", "y", "z",
            "~", "`", "!", "@",
            "#", "$", "%", "^",
            "&", "*", "(", ")",
            "-", "_", "=", '+',
            "[", "{", "]", "}",
            ";", ":", "'", '"',
            "\\", "|", ",", "<",
            ".", ">", "/", "?",
          }, vim.v.char) then
        vim.v.char = ""
      end
    end
  end
})
-- }}}
