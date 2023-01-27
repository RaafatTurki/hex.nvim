local M = {}

function M.drop_undo_history()
  local undolevels = vim.o.undolevels
  vim.o.undolevels = -1
  vim.cmd [[exe "normal a \<BS>\<Esc>"]]
  vim.o.undolevels = undolevels
end

function M.dump_to_hex(hex_dump_cmd)
  vim.b.hex = true
  vim.cmd([[%! ]] .. hex_dump_cmd)
  vim.b.hex_ft = vim.bo.ft
  vim.bo.ft = 'xxd'
  M.drop_undo_history()
  -- FIXME: this can be problematic
  vim.cmd [[LspStop]]
  vim.bo.mod = false
end

function M.assemble_from_hex(hex_assemble_cmd)
  vim.cmd([[%! ]] .. hex_assemble_cmd)
  vim.bo.ft = vim.b.hex_ft
  M.drop_undo_history()
  vim.bo.mod = false
  vim.b.hex = false
end

function M.begin_patch_from_hex(hex_assemble_cmd)
  vim.b.hex_cur_pos = vim.fn.getcurpos()
  vim.cmd([[%! ]] .. hex_assemble_cmd)
end

function M.finish_patch_from_hex(hex_dump_cmd)
  vim.cmd([[%! ]] .. hex_dump_cmd)
  vim.fn.setpos('.', vim.b.hex_cur_pos)
  vim.bo.mod = true
end

function M.is_program_executable(program)
  if vim.fn.executable(program) == 1 then
    return true
  else
    vim.notify(program .. " is not installed on this system, aborting!", vim.log.levels.WARN)
    return false
  end
end

return M
