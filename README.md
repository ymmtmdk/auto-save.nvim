### 📋 Features

- automatically save your changes so the world doesn't collapse
- debounce the save with a delay

### 📦 Installation

lazy.nvim

```lua
{
  "ymmtmdk/auto-save.nvim",
  lazy = false,
  config = function()
    require("auto-save").setup {
      debounce_delay = 1000,
    }
  end
}
```

### ⚙️ Configuration

**auto-save** comes with the following defaults:

```lua
{
    enabled = true, -- start auto-save when the plugin is loaded (i.e. when your package manager loads it)
    trigger_events = {"InsertLeave", "TextChanged"}, -- vim events that trigger auto-save. See :h events
	-- function that determines whether to save the current buffer or not
	-- return true: if buffer is ok to be saved
	-- return false: if it's not ok to be saved
    debounce_delay = 135, -- saves the file at most every `debounce_delay` milliseconds
}
```

Additionally you may want to set up a key mapping to toggle auto-save:

```lua
vim.api.nvim_set_keymap("n", "<leader>n", ":ASToggle<CR>", {})
```

### 🪴 Usage

Besides running auto-save at startup (if you have `enabled = true` in your config), you may as well:

- `ASToggle`: toggle auto-save

