Config = {
    opts = {
        enabled = true,          -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
        execution_message = {
            message = function() -- message to print on save
                return ("AutoSave: saved at " .. vim.fn.strftime("%H:%M:%S"))
            end,
            dim = 0.18,                                    -- dim the color of `message`
            cleaning_interval = 1250,                      -- (milliseconds) automatically clean MsgArea after displaying `message`. See :h MsgArea
        },
        trigger_events = { "InsertLeave", "TextChanged" }, -- vim events that trigger auto-save. See :h events
        -- function that determines whether to save the current buffer or not
        -- return true: if buffer is ok to be saved
        -- return false: if it's not ok to be saved
        debounce_delay = 135, -- saves the file at most every `debounce_delay` milliseconds
    },
}

function Config:set_options(opts)
    opts = opts or {}
    self.opts = vim.tbl_deep_extend("keep", opts, self.opts)
end

function Config:get_options()
    return self.opts
end

return Config
