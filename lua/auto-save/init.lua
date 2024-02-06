local M = {}

local cnf = require("auto-save.config")
local autosave_running
local api = vim.api
local AUTO_SAVE_COLOR = "MsgArea"
local queued = 0

api.nvim_create_augroup("AutoSave", {
    clear = true,
})

local function debounce(lfn)
    local buf = api.nvim_get_current_buf()
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
    api.nvim_echo(
        { { (msg), AUTO_SAVE_COLOR, }, },
        true,
        {}
    )
end

function M.save(buf)
    buf = buf or api.nvim_get_current_buf()

    if cnf.opts.condition(buf) == false then
        return
    end

    if not api.nvim_buf_get_option(buf, "modified") then
        return
    end

    local mode = vim.api.nvim_get_mode().mode
    if not (mode == 'n') then
        return
    end

    echo(
        type(cnf.opts.execution_message.message) == "function"
        and cnf.opts.execution_message.message()
        or cnf.opts.execution_message.message
    )
end

local function perform_save()
    if (cnf.opts.debounce_delay > 0) then
        debounce(M.save)
    else
        M.save()
    end
end

function M.on()
    api.nvim_create_autocmd(cnf.opts.trigger_events, {
        callback = perform_save,
        pattern = "*",
        group = "AutoSave",
    })

    autosave_running = true
end

function M.off()
    api.nvim_create_augroup("AutoSave", {
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
