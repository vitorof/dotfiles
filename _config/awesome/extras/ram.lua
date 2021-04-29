local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- Configuration
local update_interval = 30            -- in seconds

local mem_used = wibox.widget.textbox()
local mem_stat = wibox.container.background(wibox.widget.textbox('Mem '))

local memory = wibox.widget{
  mem_stat,
  mem_used,
  layout = wibox.layout.fixed.horizontal
}

local function update_widget(mem)
  mem_used.markup = mem
  if mem and tonumber(mem) >= 10000 then
    mem_stat.fg = beautiful.xcolor1 --red
  else
    mem_stat.fg = beautiful.xcolor8 --gray
  end
end

local mem_script = [[
    bash -c "
    free -m | awk '/^Mem/ {print $3}'
"]]

-- Update amount used
awful.widget.watch(mem_script, update_interval, function(widget, stdout)
    local mem = string.gsub(stdout, '^%s*(.-)%s*$', '%1')
    update_widget(mem)
end)

return memory
