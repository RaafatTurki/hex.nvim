local health = {}

function health.check()
  vim.health.start("Dependencies ~")
  if vim.fn.executable("xxd") == 0 then
    vim.health.error("'xxd'" .. " is not installed")
  else
    vim.health.ok("'xxd'" .. " is installed")
  end
end

return health
