local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- Configuration

tray = wibox.widget.systray()
tray_icon = wibox.widget.textbox("<b>&lt;</b>")
tray_container = wibox.container.background()

mytraywidget = wibox.widget{
    tray_icon,
    fg = beautiful.xcolor4,
    widget = tray_container
}

local function toggle_tray()
    tray.visible = not tray.visible
    if tray.visible then
        tray_container.fg = beautiful.xcolor4
    else
        tray_container.fg = beautiful.xcolor8
    end
end

mytraywidget:buttons(
  gears.table.join(
    awful.button({ }, 1, function () toggle_tray() end)
))

local mytraywidget_tooltip = awful.tooltip {
    objects        = { mytraywidget },
    timer_function = function()
        return "Toggle tray"
    end,
}

return mytraywidget
