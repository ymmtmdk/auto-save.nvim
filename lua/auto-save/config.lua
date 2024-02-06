Config = {
    opts = {
        enabled = true,                                    -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
        trigger_events = { "InsertLeave", "TextChanged" }, -- vim events that trigger auto-save. See :h events
        debounce_delay = 135,                              -- saves the file at most every `debounce_delay` milliseconds
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
