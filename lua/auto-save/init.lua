local M = {}

local cnf = require("auto-save.config")
local autosave_running
local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local AUTO_SAVE_COLOR = "MsgArea"

api.nvim_create_augroup("AutoSave", {
    clear = true,
})

local global_vars = {}
local queued = 0

local function set_buf_var(buf, name, value)
    global_vars[name] = value
end

local function get_buf_var(buf, name)
    return global_vars[name]
end

local function debounce(lfn, duration)
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

    if cnf.opts.write_all_buffers then
        cmd("silent! wall")
    else
        api.nvim_buf_call(buf, function()
            cmd("silent! write")
        end)
    end

    echo(
        type(cnf.opts.execution_message.message) == "function"
        and cnf.opts.execution_message.message()
        or cnf.opts.execution_message.message
    )
    if cnf.opts.execution_message.cleaning_interval > 0 then
        fn.timer_start(cnf.opts.execution_message.cleaning_interval, function()
            cmd([[echon '']])
        end)
    end
end

local function perform_save()
    local current_time = os.date("%Y-%m-%d %H:%M:%S")
    echo(current_time)

    if (cnf.opts.debounce_delay > 0) then
        debounce(M.save, cnf.opts.debounce_delay)
    else
        M.save()
    end
end

function M.on()
    api.nvim_create_autocmd(cnf.opts.trigger_events, {
        callback = function()
            perform_save()
        end,
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
