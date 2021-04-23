local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- Configuration
local update_interval = 120

local weather_city = wibox.widget.textbox("Matsue ")
local weather_temp = wibox.widget.textbox()

local weather = wibox.widget{
  {
    weather_city,
    fg = beautiful.xcolor8, --gray
    widget = wibox.container.background
  },
  weather_temp,
  layout = wibox.layout.fixed.horizontal
}

local function update_widget(temp)
  weather_temp.markup = temp
end

local weather_script = [[
    bash -c "
    curl wttr.in/Matsue?format="%c+%t"
"]]

-- Update amount used
awful.widget.watch(weather_script, update_interval, function(widget, stdout, stderr, exitreason, exitcode)
  local temp = exitcode == 0 and string.gsub(stdout, '^%s*(.-)%s*$', '%1') or "Loading..."
  temp = string.gsub(temp, '  ', ' ')
  update_widget(temp)
end)

return weather
