local M = {}

local cnf = require("auto-save.config")
local autosave_running
local AUTO_SAVE_COLOR = "MsgArea"
local queued = 0

vim.api.nvim_create_augroup("AutoSave", {
  clear = true,
})

local function debounce(lfn)
  local buf = vim.api.nvim_get_current_buf()
  vim.defer_fn(function()
    if queued > 0 then
      queued = queued - 1
    end
    if queued == 0 then
      lfn(buf)
    end
  end, cnf.opts.debounce_delay)
  queued = queued + 1
end

local function echo(msg)
  vim.api.nvim_echo(
    { { (msg), AUTO_SAVE_COLOR, }, },
    true,
    {}
  )
end

local function condition(buf)
  local utils = require("auto-save.utils.data")

  if vim.fn.getbufvar(buf, "&modifiable") == 1 and
      utils.not_in(vim.fn.getbufvar(buf, "&filetype"), {}) then
    return true
  end
  return false
end

function M.save(buf)
  buf = buf or vim.api.nvim_get_current_buf()

  if condition(buf) == false then
    return
  end

  if not vim.api.nvim_buf_get_option(buf, "modified") then
    if not vim.g.vscode then
      return
    end
  end

  local mode = vim.api.nvim_get_mode().mode
  if not (mode == 'n') then
    return
  end
  if mode == 'i' or mode == 'ic' then
    return
  end

  vim.api.nvim_buf_call(buf, function()
    if vim.g.vscode then
      local vscode = require('vscode-neovim')
      local r = vscode.call('workbench.action.files.save')
      -- vim.print(r)
    else
      vim.cmd("write")
    end
  end)
end

local function perform_save()
  if (cnf.opts.debounce_delay > 0) then
    debounce(M.save)
  else
    M.save()
  end
end

function M.on()
  vim.api.nvim_create_autocmd(cnf.opts.trigger_events, {
    callback = perform_save,
    pattern = "*",
    group = "AutoSave",
  })

  autosave_running = true
end

function M.off()
  vim.api.nvim_create_augroup("AutoSave", {
    clear = true,
  })

  autosave_running = false
end

function M.toggle()
  if autosave_running then
    M.off()
    echo("off")
  else
    M.on()
    echo("on")
  end
end

function M.setup(custom_opts)
  cnf:set_options(custom_opts)
end

return M
