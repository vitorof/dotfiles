pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
-- local lain  = require("lain")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Enable hotkeys help widget for VIM and other apps when client with a matching name is opened
require("awful.hotkeys_popup.keys")

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

local theme = "archlabs"
beautiful.init(gears.filesystem.get_configuration_dir() .. "themes/" .. theme .. "/theme.lua")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

terminal = "exo-open --launch TerminalEmulator"
web_browser = "exo-open --launch WebBrowser"
file_manager = "exo-open --launch FileManager"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = "exo-open "
web_search_cmd = "exo-open https://duckduckgo.com/?q="

modkey = "Mod4"

awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
}

-- Helpers functions
function add_clickable_effect(w)
    local original_cursor = "left_ptr"
    local hover_cursor = "hand1"

    w:connect_signal("mouse::enter", function ()
        local w = _G.mouse.current_wibox
        if w then
            w.cursor = hover_cursor
        end
    end)

    w:connect_signal("mouse::leave", function ()
        local w = _G.mouse.current_wibox
        if w then
            w.cursor = original_cursor
        end
    end)
end

function move_to_edge(c, direction)
    local workarea = awful.screen.focused().workarea
    if direction == "up" then
        c:geometry({ nil, y = workarea.y + beautiful.useless_gap * 2, nil, nil })
    elseif direction == "down" then
        c:geometry({ nil, y = workarea.height + workarea.y - c:geometry().height - beautiful.useless_gap * 2 - beautiful.border_width * 2, nil, nil })
    elseif direction == "left" then
        c:geometry({ x = workarea.x + beautiful.useless_gap * 2, nil, nil, nil })
    elseif direction == "right" then
        c:geometry({ x = workarea.width + workarea.x - c:geometry().width - beautiful.useless_gap * 2 - beautiful.border_width * 2, nil, nil, nil })
    end
end

-- Constants --
local floating_resize_amount = dpi(20)
local tiling_resize_factor= 0.05
---------------
function resize(c, direction)
    if awful.layout.get(mouse.screen) == awful.layout.suit.floating or c.floating then
        if direction == "up" then
            c:relative_move(  0,  0, 0, -floating_resize_amount)
        elseif direction == "down" then
            c:relative_move(  0,  0, 0,  floating_resize_amount)
        elseif direction == "left" then
            c:relative_move(  0,  0, -floating_resize_amount, 0)
        elseif direction == "right" then
            c:relative_move(  0,  0,  floating_resize_amount, 0)
        end
    else
        if direction == "up" then
            awful.client.incwfact(-tiling_resize_factor)
        elseif direction == "down" then
            awful.client.incwfact( tiling_resize_factor)
        elseif direction == "left" then
            awful.tag.incmwfact(-tiling_resize_factor)
        elseif direction == "right" then
            awful.tag.incmwfact( tiling_resize_factor)
        end
    end
end

-- Extras
local icons = require("icons.icons")
require("extras.exit_screen")
require("extras.sidebar")

-- Icon size
naughty.config.defaults['icon_size'] = beautiful.notification_icon_size

-- Timeouts (set 0 for permanent)
naughty.config.defaults.timeout = 5
naughty.config.presets.low.timeout = 2
naughty.config.presets.critical.timeout = 0

-- Apply theme variables
naughty.config.defaults.padding = beautiful.notification_padding
naughty.config.defaults.spacing = beautiful.notification_spacing
naughty.config.defaults.margin = beautiful.notification_margin
naughty.config.defaults.border_width = beautiful.notification_border_width

-- Apply rounded rectangle shape
beautiful.notification_shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, beautiful.notification_border_radius)
end

naughty.config.presets.normal = {
    font         = beautiful.notification_font,
    fg           = beautiful.notification_fg,
    bg           = beautiful.notification_bg,
    border_width = beautiful.notification_border_width,
    margin       = beautiful.notification_margin,
    position     = beautiful.notification_position
}

naughty.config.presets.low = {
    font         = beautiful.notification_font,
    fg           = beautiful.notification_fg,
    bg           = beautiful.notification_bg,
    border_width = beautiful.notification_border_width,
    margin       = beautiful.notification_margin,
    position     = beautiful.notification_position
}

naughty.config.presets.ok = naughty.config.presets.low
naughty.config.presets.info = naughty.config.presets.low
naughty.config.presets.warn = naughty.config.presets.normal

naughty.config.presets.critical = {
    font         = beautiful.notification_font,
    fg           = beautiful.notification_crit_fg,
    bg           = beautiful.notification_crit_bg,
    border_width = beautiful.notification_border_width,
    margin       = beautiful.notification_margin,
    position     = beautiful.notification_position
}

myawesomemenu = {
   { "Edit config", editor_cmd .. " " .. awesome.conffile },
   { "Restart", awesome.restart },
   { "Quit", function() exit_screen_show() end },
}

mymainmenu = awful.menu({ items = { { "Awesome", myawesomemenu, icons.archlabs },
                                    { "Hotkeys", function() return false, hotkeys_popup.show_help end },
                                    { "Web Browser", web_browser },
                                    { "File Manager", file_manager },
                                    { "Settings", "xfce4-settings-manager" },
                                    { "Run", "rofi_run -r" },
                                    { "Terminal", terminal }
                                  }
                        })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

-- Widgets
myclockwidget   = require("extras.textclock")
myweatherwidget = require("extras.weather")
myramwidget     = require("extras.ram")
mybatterywidget = require("extras.battery")
mytraywidget    = require("extras.systray")

add_clickable_effect(mytraywidget)
add_clickable_effect(mybatterywidget)

local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t)
                                              if t == t.screen.selected_tag then
                                                  awful.tag.history.restore()
                                              else
                                                  t:view_only()
                                              end
                                          end),
                    awful.button({ modkey }, 1, awful.tag.viewtoggle),
                    awful.button({ }, 3, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 2, function (c)
                                              c:kill()
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(-1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(1)
                                          end))
-- Set wallpaper function
local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        -- gears.wallpaper.maximized(wallpaper, s, true)
        awful.spawn.with_shell("feh --no-fehbg --bg-fill " .. beautiful.wallpaper)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)
awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)
end)

awful.screen.connect_for_each_screen(function(s)
    -- Each screen has its own tag table.
    awful.tag({" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "}, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    s.mypromptbox.fg = beautiful.xcolor7
    s.mypromptbox.font = "sans 10"

    -- Create a searchbar widget
    search_icon = wibox.widget.textbox("")
    search_icon.font = "Font Awesome 5 Free 9"
    search_icon.align = "center"
    search_icon.valign = "center"
    s.mysearchwidget = wibox.widget{
        {
	    search_icon,
            {
                s.mypromptbox,
                -- top = dpi(3),
                -- bottom = dpi(3),
                right = dpi(5),
                left = dpi(5),
                widget = wibox.container.margin
            },
            spacing = dpi(10),
            layout = wibox.layout.align.horizontal
        },
        forced_width = dpi(300),
        widget = wibox.container.background
    }

    s.mysearchwidget:buttons(gears.table.join(
                        awful.button({ }, 1, function ()
                            awful.prompt.run {
                                prompt       = "<b>Run: </b>",
                                textbox      = s.mypromptbox.widget,
                                exe_callback = awful.spawn,
                                completion_callback = awful.completion.shell,
                                history_path = awful.util.get_cache_dir() .. "/history"
                            }
                        end),
                        awful.button({ }, 3, function ()
                            awful.prompt.run {
                              prompt       = '<b>Web search: </b>',
                              textbox      = s.mypromptbox.widget,
                              history_path = awful.util.get_cache_dir() .. "/history_web",
                              exe_callback = function(input)
                                  if not input or #input == 0 then return end
                                  awful.spawn(web_search_cmd.."\""..input.."\"")
                                  naughty.notify { title = "Searching the web for", text = input, icon = icons.web_browser }
                              end
                            }
                        end)
    ))

    -- Add tooltip to search bar
    local mysearchwidget_tooltip = awful.tooltip {
        objects        = { s.mysearchwidget },
        timer_function = function()
            return "Left Click or Mod+R: <b>Run</b>\nRight click or Mod+S: <b>Web Search</b>\nEscape: <b>Cancel</b>"
        end,
    }

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
        layout   = {
            spacing = dpi(0),
            layout  = wibox.layout.fixed.horizontal
        },
    }

    s.mytaglist:buttons(gears.table.join(
                    awful.button({ }, 4, function() awful.tag.viewprev() end),
                    awful.button({ }, 5, function() awful.tag.viewnext() end)
    ))

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen   = s,
        filter   = awful.widget.tasklist.filter.currenttags,
        buttons  = tasklist_buttons,
        style    = {
            shape_border_width = 0,
            shape_border_color = beautiful.fg_normal,
            shape  = gears.shape.rounded_bar,
        },
        layout   = {
            spacing = dpi(10),
            spacing_widget = {
                {
                    forced_width = dpi(5),
                    shape        = gears.shape.circle,
                    color        = beautiful.xcolor8,
                    widget       = wibox.widget.separator
                },
                valign = 'center',
                halign = 'center',
                widget = wibox.container.place,
            },
            layout  = wibox.layout.flex.horizontal
        },
        -- Notice that there is *NO* wibox.wibox prefix, it is a template,
        -- not a widget instance.
        widget_template = {
            {
                {
                    nil,
                    {
                        id     = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    expand = "none", -- Center text
                    layout = wibox.layout.align.horizontal,
                },
                left  = dpi(10),
                right = dpi(10),
                widget = wibox.container.margin
            },
            id     = 'background_role',
            widget = wibox.container.background,
        },
    }

    -- Create the top bar
    s.mytopwibox = awful.wibar({ position = "top", bg = beautiful.xbackground, height = dpi(25), screen = s })

    -- Add widgets to the top bar
    s.mytopwibox:setup {
        {
            layout = wibox.layout.align.horizontal,
            expand = "none",
            { -- Left widgets
                s.mysearchwidget,
                spacing = dpi(5),
                layout = wibox.layout.fixed.horizontal
            },
            { -- Middle widgets
		s.mytaglist,
                widget = wibox.container.background
            },
            { -- Right widgets
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(8),
                tray,
                mytraywidget,
                mybatterywidget,
		myramwidget,
		myweatherwidget,
                myclockwidget
            },
        },
        margins = dpi(5),
        widget = wibox.container.margin,
    }

    -- Create the bottom bar
    s.mybottomwibox = awful.wibar({ position = "bottom", bg = beautiful.xbackground, height = dpi(25), screen = s })

    -- Add widgets to the bottom bar
    s.mybottomwibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
        },
        { -- Middle widget
            s.mytasklist,
            top = dpi(2),
            bottom = dpi(2),
            widget = wibox.container.margin,
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
        },
    }

end)

root.buttons(gears.table.join(
    awful.button({ }, 1, function () mymainmenu:hide() end),
    awful.button({ }, 2, function () awful.spawn.with_shell("rofi_run -w") end),
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewprev),
    awful.button({ }, 5, awful.tag.viewnext)
))

globalkeys = gears.table.join(
    awful.key({ modkey,           }, "F1",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ "Mod4", "Mod1" }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ "Mod4", "Mod1" }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey, "Shift" }, "b", awful.tag.history.restore,
              {description = "go back", group = "tag"}),
    awful.key({ modkey,         }, "b",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}
    ),

    -- Focus by index
    awful.key({ modkey, }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey, }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- Toggle sidebar
    awful.key({ modkey }, "grave", function() sidebar.visible = not sidebar.visible end,
              {description = "show or hide sidebar", group = "awesome"}),

    -- Main menu
    awful.key({ modkey, "Shift"  }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),

    -- Toggle tray
    awful.key({ modkey, }, "=", function () toggle_tray() end,
              {description = "toggle tray visibility", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey,           }, "f", function () awful.spawn(file_manager) end,
              {description = "open file manager", group = "launcher"}),
    awful.key({ modkey,           }, "w", function () awful.spawn(web_browser) end,
              {description = "open web browser", group = "launcher"}),
    awful.key({ "Control",           }, "space", function () naughty.destroy_all_notifications() end,
              {description = "dismiss notifications", group = "awesome"}),
    awful.key({  }, "Print", function ()
        awful.spawn("scrot '%S.png' -e 'mv $f $$(xdg-user-dir PICTURES)/Screenshots/ArchLabs-%S-$wx$h.png'")
        naughty.notify({ text = "Screenshot taken", icon = icons.camera })
    end,
              {description = "take screenshot", group = "launcher"}),
    awful.key({  }, "XF86AudioPlay", function () awful.spawn.with_shell("playerctl play-pause") end,
              {description = "audio player toggle", group = "audio"}),
    awful.key({  }, "XF86AudioNext", function () awful.spawn.with_shell("playerctl next") end,
              {description = "audio player next", group = "audio"}),
    awful.key({  }, "XF86AudioPrev", function () awful.spawn.with_shell("playerctl previous") end,
              {description = "audio player previous", group = "audio"}),
    awful.key({  }, "XF86AudioStop", function () awful.spawn.with_shell("playerctl stop") end,
              {description = "audio player stop", group = "audio"}),
    awful.key({  }, "XF86AudioMute", function () awful.spawn.with_shell("pamixer -t") end,
              {description = "audio (un)mute", group = "audio"}),
    awful.key({  }, "XF86AudioRaiseVolume", function () awful.spawn.with_shell("pamixer -i 2") end,
              {description = "audio raise", group = "audio"}),
    awful.key({  }, "XF86AudioLowerVolume", function () awful.spawn.with_shell("pamixer -d 2") end,
              {description = "audio lower", group = "audio"}),
    awful.key({  }, "XF86MonBrightnessUp", function () awful.spawn.with_shell("xbacklight -inc 10") end,
              {description = "increase brightness", group = "brightness"}),
    awful.key({  }, "XF86MonBrightnessDown", function () awful.spawn.with_shell("xbacklight -dec 10") end,
              {description = "decrease brightness", group = "brightness"}),
    -- Awesome
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    -- Exit screen
    awful.key({ modkey, "Shift" }, "x", function() exit_screen_show() end,
              {description = "show exit screen", group = "awesome"}),
    awful.key({ modkey,           }, "Escape", function () exit_screen_show() end,
              {description = "show exit screen", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next layout", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous layout", group = "layout"}),

    awful.key({ modkey, "Shift" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompts
    awful.key({ modkey },            "r",     function ()
        awful.prompt.run {
            prompt       = "<b>Run: </b>",
            textbox      = awful.screen.focused().mypromptbox.widget,
            exe_callback = awful.spawn,
            completion_callback = awful.completion.shell,
            history_path = awful.util.get_cache_dir() .. "/history"
        }
    end,
    {description = "run prompt", group = "prompts"}),

    -- Lua execute prompt
    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "<b>Run Lua code: </b>",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "prompts"}),

    -- Web search prompt
    awful.key({ modkey }, "s",
              function ()
                  awful.prompt.run {
                    prompt       = '<b>Web search: </b>',
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = function(input)
                        if not input or #input == 0 then return end
                        awful.spawn(web_search_cmd.."\""..input.."\"")
                        naughty.notify { title = "Searching the web for", text = input, icon = icons.web_browser }
                    end
                  }
              end,
              {description = "web search prompt", group = "prompts"}),

    -- Rofi
    awful.key({ modkey }, "d", function () awful.spawn("rofi_run -r") end,
              {description = "rofi launcher", group = "launcher"}),

    -- Needed for super to launch rofi through ksuperkey, see ~/.xprofile
    awful.key({ "Mod1" }, "F1", function () awful.spawn("rofi_run -r") end,
              {description = "rofi launcher", group = "launcher"})
)

clientkeys = gears.table.join(
    -- Focus client by direction (arrow keys)
    awful.key({ modkey }, "Down",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus down", group = "client"}),
    awful.key({ modkey }, "Up",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus up", group = "client"}),
    awful.key({ modkey }, "Left",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus left", group = "client"}),
    awful.key({ modkey }, "Right",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end,
        {description = "focus right", group = "client"}),

    -- Relative move floating client (vim keys)
    awful.key({ modkey, "Control", "Shift"   }, "j",  function (c) c:relative_move(  0,  dpi(40),   0,   0) end,
        {description =  "relative move", group = "client"}),
    awful.key({ modkey, "Control", "Shift"   }, "k",  function (c) c:relative_move(  0, -dpi(40),   0,   0) end,
        {description =  "relative move", group = "client"}),
    awful.key({ modkey, "Control", "Shift"   }, "h",  function (c) c:relative_move(-dpi(40),   0,   0,   0) end,
        {description =  "relative move", group = "client"}),
    awful.key({ modkey, "Control", "Shift"   }, "l",  function (c) c:relative_move( dpi(40),   0,   0,   0) end,
        {description = "relative move", group = "client"}),

    -- Resize client (arrow keys)
    -- Check helper function "resize" if you need to tweak the resize amount
    awful.key({ modkey, "Control"  }, "Down",
        function (c)
            resize(c, "down")
        end,
        {description = "resize downwards", group = "client"}),
    awful.key({ modkey, "Control"  }, "Up",
        function (c)
            resize(c, "up")
        end,
        {description = "resize upwards", group = "client"}),
    awful.key({ modkey, "Control"  }, "Left",
        function (c)
            resize(c, "left")
        end,
        {description = "resize to the left", group = "client"}),
    awful.key({ modkey, "Control"  }, "Right",
        function (c)
            resize(c, "right")
        end,
        {description = "resize to the right", group = "client"}),

    -- Move FLOATING client to edge or swap TILED client by direction (arrow keys)
    awful.key({ modkey, "Shift"  }, "Down",
        function (c)
            if awful.layout.get(mouse.screen) == awful.layout.suit.floating or c.floating then
                -- Floating: move client to edge
                move_to_edge(c, "down")
            else
                -- Tiled: Swap client by direction
                awful.client.swap.bydirection("down", c, nil)
            end
        end,
        {description = "(floating) move to edge, (tiled) swap by direction", group = "client"}),
    awful.key({ modkey, "Shift"  }, "Up",
        function (c)
            if awful.layout.get(mouse.screen) == awful.layout.suit.floating or c.floating then
                -- Floating: move client to edge
                move_to_edge(c, "up")
            else
                -- Tiled: Swap client by direction
                awful.client.swap.bydirection("up", c, nil)
            end
        end,
        {description = "(floating) move to edge, (tiled) swap by direction", group = "client"}),
    awful.key({ modkey, "Shift"  }, "Left",
        function (c)
            if awful.layout.get(mouse.screen) == awful.layout.suit.floating or c.floating then
                -- Floating: move client to edge
                move_to_edge(c, "left")
            else
                -- Tiled: Swap client by direction
                awful.client.swap.bydirection("left", c, nil)
            end
        end,
        {description = "(floating) move to edge, (tiled) swap by direction", group = "client"}),
    awful.key({ modkey, "Shift"  }, "Right",
        function (c)
            if awful.layout.get(mouse.screen) == awful.layout.suit.floating or c.floating then
                -- Floating: move client to edge
                move_to_edge(c, "right")
            else
                -- Tiled: Swap client by direction
                awful.client.swap.bydirection("right", c, nil)
            end
        end,
        {description = "(floating) move to edge, (tiled) swap by direction", group = "client"}),

    -- Toggle fullscreen
    awful.key({ modkey, "Shift"  }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),

    -- Close client
    awful.key({ modkey, "Shift"   }, "q",      function (c) c:kill() end,
              {description = "close", group = "client"}),

    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey }, "c",  function (c) awful.placement.centered(c,{honor_workarea=true})
             end,
              {description = "center", group = "client"}),

    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag or go back to last tag if it is already selected
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           if tag == screen.selected_tag then
                               awful.tag.history.restore()
                           else
                               tag:view_only()
                           end
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     size_hints_honor = false,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Xfce4-power-manager-settings",
          "Arandr",
          "Blueman-manager",
          "Lxappearance",
          "Pavucontrol",
          "Nm-connection-editor",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
          "GtkFileChooserDialog",
          "conversation",
        }
      }, properties = { floating = true }},

    -- Dialogs are always centered, floating and ontop
    { rule_any = {type = { "dialog" }
      }, properties = { placement = awful.placement.centered, floating = true, ontop = true }
    },
}

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

-- Change border colors on focus/unfocus
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- Make rofi able to unminimize minimized clients
client.connect_signal("request::activate", function(c, context, hints)
    if not awesome.startup then
        if c.minimized then
            c.minimized = false
        end
        awful.ewmh.activate(c, context, hints)
    end
end)

-- Center floating client if it is the only visible one or the layout is not floating
client.connect_signal("manage", function (c)
    if not awesome.startup then
        if awful.layout.get(mouse.screen) ~= awful.layout.suit.floating then
            awful.placement.centered(c,{honor_workarea=true})
        else if #mouse.screen.clients == 1 then
                awful.placement.centered(c,{honor_workarea=true})
            end
        end
    end
end)

-- Remember and restore floating client geometry
tag.connect_signal("property::layout", function(t)
    for k, c in ipairs(t:clients()) do
        if awful.layout.get(mouse.screen) == awful.layout.suit.floating then
            c:geometry(awful.client.property.get(c, 'floating_geometry'))
        end
    end
end)
client.connect_signal("manage", function(c)
    if awful.layout.get(mouse.screen) == awful.layout.suit.floating then
        awful.client.property.set(c, 'floating_geometry', c:geometry())
    end
end)
client.connect_signal("property::geometry", function(c)
    if awful.layout.get(mouse.screen) == awful.layout.suit.floating then
        awful.client.property.set(c, 'floating_geometry', c:geometry())
    end
end)

-- Rounded corners
if beautiful.border_radius or beautiful.border_radius ~= 0 then
    client.connect_signal("manage", function (c, startup)
        if not c.fullscreen then
            c.shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
            end
        end
    end)

    -- Fullscreen clients should not have rounded corners
    client.connect_signal("property::fullscreen", function (c)
        if c.fullscreen then
            c.shape = function(cr, width, height)
                gears.shape.rectangle(cr, width, height)
            end
        else
            c.shape = function(cr, width, height)
                gears.shape.rounded_rect(cr, width, height, beautiful.border_radius)
            end
        end
    end)
end

-- Subscribe to power supply status changes - Requires inotify-tools
local charger_script = [[
   bash -c "
   while (inotifywait /sys/class/power_supply/*/online -qq) do cat /sys/class/power_supply/*/online; done
"]]

-- Kill old inotifywait process
awful.spawn.easy_async_with_shell("ps x | grep \"inotifywait /sys/class/power_supply\" | grep -v grep | awk '{print $1}' | xargs kill", function ()
    -- Update charger status with each line printed
    awful.spawn.with_line_callback(charger_script, {
        stdout = function(line)
            -- All we need is the first character (remove trailing whitespace)
            status = line:sub(1,1)
            if status == "1" then
                awesome.emit_signal("charger_plugged")
            else
                awesome.emit_signal("charger_unplugged")
            end
        end
    })
end)

awful.spawn.with_shell("numlockx on")

-----------------------------------------------------
----------  Aggresive Garbage Collection  -----------
-----------------------------------------------------
collectgarbage("setpause", 160)
collectgarbage("setstepmul", 400)
