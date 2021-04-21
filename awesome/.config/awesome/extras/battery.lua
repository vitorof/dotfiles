local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- Configuration
local update_interval = 30            -- in seconds

local battery_text = wibox.widget.textbox()
local battery_stat = wibox.container.background(wibox.widget.textbox('Bat '))

local battery = wibox.widget{
  battery_stat,
  battery_text,
  layout = wibox.layout.fixed.horizontal
}

local function update_widget(bat)
  stat, perc = string.match(bat, "(%S+)\n(%S+)")
  battery_text.markup = perc .. "%"
  if stat:sub(1,1) == "C" then
    battery_stat.fg = beautiful.xcolor2 --green
  elseif perc and tonumber(perc) <= 20 then
    battery_stat.fg = beautiful.xcolor1 --red
  else
    battery_stat.fg = beautiful.xcolor8 --gray
  end
end

local bat_script = [[
    bash -c "
    cat /sys/class/power_supply/BAT0/{status,capacity}
"]]

-- Update percentage
awful.widget.watch(bat_script, update_interval, function(widget, stdout)
    local bat = string.gsub(stdout, '^%s*(.-)%s*$', '%1')
    update_widget(bat)
end)

battery:buttons(
  gears.table.join(
    awful.button({ }, 1, function ()
        local matcher = function (c)
          return awful.rules.match(c, {class = 'Xfce4-power-manager-settings'})
        end
        awful.client.run_or_raise("xfce4-power-manager-settings", matcher)
    end)
))

return battery
