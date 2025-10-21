local config = vim.g.hex
local render = require("hex.render")

local M = {}

function M.toggle()
  if not vim.b.hex then
    M.dump()
  else
    M.revert()
  end
end

function M.dump()
  if vim.b.hex then
    vim.notify("Already dumped.", vim.log.levels.WARN)
    return
  end
  M.hex_dump()
end

function M.revert()
  if not vim.b.hex then
    vim.notify("Already reverted.", vim.log.levels.WARN)
    return
  end
  M.hex_revert()
end

local function get_undo_path()
  local buf = vim.api.nvim_buf_get_name(0)
  local resolved_fname = vim.fs.basename(vim.fn.undofile(buf))
  local undofile = vim.fs.joinpath(vim.fn.stdpath("state"), "hex", resolved_fname)
  return undofile
end

local function load_undo()
  local undofile = get_undo_path()
  if vim.fn.filereadable(undofile) == 1 then
    vim.cmd("rundo " .. vim.fn.fnameescape(undofile))
  end
end

function M.save_undo()
  local undofile = get_undo_path()
  local undodir = vim.fs.dirname(undofile)
  if not vim.uv.fs_stat(undodir) then
    vim.fn.mkdir(undodir, "p")
  end
  vim.cmd("wundo! " .. vim.fn.fnameescape(undofile))
end

local function xxd_common(cmd, patch)
  local xxd = {}
  for i in string.gmatch(cmd, "%S+") do
    table.insert(xxd, i)
  end
  local text
  local obj
  if cmd == config.cmd.dump then
    table.insert(xxd, vim.api.nvim_buf_get_name(0))
    obj = vim.system(xxd, { text = true }):wait()
  elseif cmd == config.cmd.revert then
    text = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    obj = vim.system(xxd, { stdin = text }):wait()
  end
  local lines = vim.split(obj.stdout, "\n", { trimempty = true })
  local ul = vim.o.undolevels
  if not patch then
    vim.o.undolevels = -1
  end
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.o.undolevels = ul
  vim.bo.modified = false
end

function M.hex_dump()
  vim.bo.binary = true
  xxd_common(config.cmd.dump, false)
  vim.b.hex_ft = vim.bo.filetype
  vim.bo.filetype = "xxd"
  vim.b.hex = true
  M.detach_lsp()
  load_undo()
  local str = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
  vim.b.hex_offset = string.find(str, ":", 1, true)
  local groupsize = tonumber(config.cmd.dump:match("%-g(%d)%s") or
    config.cmd.dump:match("%-g%s(%d)%s"))
  if groupsize == 1 then
    vim.b.hex_byte_separator = vim.b.hex_offset + 25
    vim.b.hex_limit = 47
  elseif groupsize == 2 then
    vim.b.hex_byte_separator = vim.b.hex_offset + 21
    vim.b.hex_limit = 39
  elseif groupsize == 4 then
    vim.b.hex_byte_separator = vim.b.hex_offset + 19
    vim.b.hex_limit = 35
  elseif groupsize == 8 then
    vim.b.hex_byte_separator = vim.b.hex_offset + 18
    vim.b.hex_limit = 33
  end
end

function M.hex_revert()
  xxd_common(config.cmd.revert, false)
  vim.bo.filetype = vim.b.hex_ft
  vim.b.hex = false
end

local undofile = vim.o.undofile

function M.patch_start()
  vim.b.hex_curpos = vim.api.nvim_win_get_cursor(0)
  vim.o.undofile = false
  if not vim.b.hex_did_undoredo then
    vim.cmd.undojoin()
  else
    vim.b.hex_did_undoredo = false
  end
  xxd_common(config.cmd.revert, true)
end

function M.patch_finish()
  xxd_common(config.cmd.dump, true)
  vim.api.nvim_win_set_cursor(0, vim.b.hex_curpos)
  vim.o.undofile = undofile
  render.prettify()
end

function M.detach_lsp()
  local attached_servers = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
  for _, server in ipairs(attached_servers) do
    server:stop()
  end
end

return M
