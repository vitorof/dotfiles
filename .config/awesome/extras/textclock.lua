local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- Configuration

local textclock = wibox.widget{
  {
    wibox.widget.textclock("%a "),
    fg = beautiful.xcolor8,
    widget = wibox.container.background
  },
  wibox.widget.textclock("%d "),
  {
    wibox.widget.textclock("%b "),
    fg = beautiful.xcolor8,
    widget = wibox.container.background
  },
  wibox.widget.textclock("%H:%M"),
  layout = wibox.layout.fixed.horizontal
}

return textclock
