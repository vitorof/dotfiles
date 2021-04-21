local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- Configuration
local update_interval = 600            -- in seconds

local weather_city = wibox.widget.textbox("Matsue ")
local weather_text = wibox.widget.textbox()

local weather = wibox.widget{
  {
    weather_city,
    fg = beautiful.xcolor8, --gray
    widget = wibox.container.background
  },
  weather_text,
  layout = wibox.layout.fixed.horizontal
}

local function update_widget(temp)
  weather_text.markup = temp
end

local weather_script = [[
    bash -c "
    curl wttr.in/Matsue?format="%c+%t"
"]]

-- Update amount used
awful.widget.watch(weather_script, update_interval, function(widget, stdout)
    local temp = string.gsub(stdout, '^%s*(.-)%s*$', '%1')
    temp = string.gsub(temp, '  ', ' ')
    update_widget(temp)
end)

return weather
