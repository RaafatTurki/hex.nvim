local config = vim.g.hex

local M = {}

local ns = vim.api.nvim_create_namespace("hex_renderer")

function M.prettify()
  if config.prettify.enable == false then return end
  local groupsize = tonumber(config.cmd.dump:match("%-g(%d)%s") or config.cmd.dump:match("%-g%s(%d)%s"))
  if not groupsize then return end

  vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
  local char
  if config.prettify.unicode == true then
    char = "│"
  else
    char = "|"
  end

  local last_line = vim.api.nvim_buf_line_count(0) - 1
  for lnum = 0, last_line do
    vim.api.nvim_buf_set_extmark(0, ns, lnum, vim.b.hex_offset, {
      virt_text = { { char, config.prettify.hl.border } },
      virt_text_pos = "inline",
    })
  end
  for lnum = 0, last_line do
    vim.api.nvim_buf_set_extmark(0, ns, lnum, vim.b.hex_byte_separator, {
      virt_text = { { char .. " ", config.prettify.hl.middle } },
      virt_text_pos = "inline",
    })
  end
  for lnum = 0, last_line do
    vim.api.nvim_buf_set_extmark(0, ns, lnum, vim.b.hex_offset + vim.b.hex_limit + 2, {
      virt_text = { { char, config.prettify.hl.border } },
      virt_text_pos = "overlay",
    })
  end
end

return M
