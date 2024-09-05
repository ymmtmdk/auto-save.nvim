local M = {}

local cnf = require("auto-save.config")
local autosave_running
local AUTO_SAVE_COLOR = "MsgArea"
local queued = 0

local function clear_augroup()
  vim.api.nvim_create_augroup("AutoSave", {
    clear = true,
  })

  vim.api.nvim_create_augroup("AutoSaveB", {
    clear = true,
  })
end

clear_augroup()

local function echo(msg)
  vim.api.nvim_echo(
    { { (msg), AUTO_SAVE_COLOR, }, },
    true,
    {}
  )
end

local function debounce(lfn, delay)
  local buf = vim.api.nvim_get_current_buf()
  vim.defer_fn(function()
    if queued > 0 then
      queued = queued - 1
    end
    if queued == 0 then
      lfn(buf)
    end
  end, delay)
  queued = queued + 1
end

local function condition(buf)
  local utils = require("auto-save.utils.data")

  if vim.fn.getbufvar(buf, "&modifiable") == 1 and
      utils.not_in(vim.fn.getbufvar(buf, "&filetype"), {}) then
    return true
  end
  return false
end

local function save(buf)
  buf = buf or vim.api.nvim_get_current_buf()
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

local function save_handler(buf)
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

  save(buf)
end

local function debounce_save()
  debounce(save_handler, cnf.opts.debounce_delay)
end

local function immediate_save()
  save()
end

function M.on()
  vim.api.nvim_create_autocmd(cnf.opts.debounce_events, {
    callback = debounce_save,
    pattern = "*",
    group = "AutoSave",
  })

  vim.api.nvim_create_autocmd(cnf.opts.immediate_events, {
    callback = immediate_save,
    pattern = "*",
    group = "AutoSaveB",
  })

  autosave_running = true
end

function M.off()
  clear_augroup()
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
