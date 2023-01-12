local u = require 'hex.utils'
local augroup_hex_editor = vim.api.nvim_create_augroup('hex_editor', { clear = true })

local M = {}

M.cfg = {
  dump_cmd = 'xxd -g 1 -u',
  assemble_cmd = 'xxd -r',
  binary_ext = { 'out', 'bin', 'png', 'jpg', 'jpeg' },
  is_binary_file = function(binary_ext)
    local filename = vim.fn.expand('%:t')
    -- local basename = vim.fs.basename(filename)
    local ext = string.match(filename, "%.([^%.]+)$")
    if ext == nil and not string.match(filename, '%u') then return true end
    if vim.tbl_contains(binary_ext, ext) then return true end
    return false
  end,
}

M.dump = function()
  if not vim.bo.bin then
    u.dump_to_hex(M.cfg.dump_cmd)
  else
    vim.notify('already dumped!', vim.log.levels.WARN)
  end
end

M.assemble = function()
  if vim.bo.bin then
    u.assemble_from_hex(M.cfg.assemble_cmd)
  else
    vim.notify('already assembled!', vim.log.levels.WARN)
  end
end

M.toggle = function()
  if not vim.bo.bin then
    M.dump()
  else
    M.assemble()
  end
end

local setup_cmds = function()
  vim.api.nvim_create_autocmd({ 'BufReadPre' }, { group = augroup_hex_editor, callback = function()
    if M.cfg.is_binary_file(M.cfg.binary_ext) then
      vim.bo.bin = true
    end
  end })

  vim.api.nvim_create_autocmd({ 'BufReadPost' }, { group = augroup_hex_editor, callback = function()
    if vim.bo.bin then
      u.dump_to_hex(M.cfg.dump_cmd)
    end
  end })

  vim.api.nvim_create_autocmd({ 'BufWritePre' }, { group = augroup_hex_editor, callback = function()
    if vim.bo.bin then
      u.begin_patch_from_hex(M.cfg.assemble_cmd)
    end
  end })

  vim.api.nvim_create_autocmd({ 'BufWritePost' }, { group = augroup_hex_editor, callback = function()
    if vim.bo.bin then
      u.finish_patch_from_hex(M.cfg.dump_cmd)
    end
  end })

  vim.api.nvim_create_user_command('HexDump', M.dump, {})
  vim.api.nvim_create_user_command('HexAssemble', M.assemble, {})
  vim.api.nvim_create_user_command('HexToggle', M.toggle, {})
end

M.setup = function(args)
  M.cfg = vim.tbl_deep_extend("force", M.cfg, args or {})

  dump_program = vim.fn.split(M.cfg.dump_cmd)[1]
  assemble_program = vim.fn.split(M.cfg.assemble_cmd)[1]

  if not u.is_program_on_path(dump_program) then return end
  if not u.is_program_on_path(assemble_program) then return end

  setup_cmds()
end

return M