-- This is an example Hyprland Lua config file.
-- Refer to the wiki for more information.
-- https://wiki.hypr.land/configuring/

-- Please note not all available settings / options are set here.
-- For a full list, see the wiki

-- You can (and should!!) split this configuration into multiple files
-- Create your files separately and then require them like this:
-- require("myColors")


------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/configuring/core/monitors/
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1.25,
})

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})


---------------------
---- MY PROGRAMS ----
---------------------

-- Set programs that you use
local terminal    = "kitty"
local fileManager = "thunar"
local menu        = "serpantinum-launcher"


-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/configuring/core/autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
-- hl.on("hyprland.start", function () 
--   hl.exec_cmd(terminal)
--   hl.exec_cmd("nm-applet")
--   hl.exec_cmd("waybar & hyprpaper & firefox")
-- end)


hl.on("hyprland.start", function ()
  hl.exec_cmd("xrdb -merge ~/.Xresources")
  hl.exec_cmd("ironbar")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/configuring/core/environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- HiDPI & Wayland nativo para todas las ventanas
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_ENABLE_HIGHDPI_SCALING", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")


-----------------------
----- PERMISSIONS -----
-----------------------

-- See https://wiki.hypr.land/configuring/core/advanced-configuration/permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/configuring/core/config-options/
hl.config({
    general = {
        gaps_in  = 1,
        gaps_out = 0,

        border_size = 0,

        col = {
            active_border   = "rgba(00000000)",
            inactive_border = "rgba(00000000)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true,
        extend_border_grab_area = 15,
        hover_icon_on_border = true,

        -- Please see https://wiki.hypr.land/configuring/extra/tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 0,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 0.94,
        inactive_opacity = 0.88,

        shadow = {
            enabled      = false,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled           = true,
            size              = 8,
            passes            = 2,
            new_optimizations = true,
            xray              = false,
            brightness        = 0.78,
            contrast          = 1.08,
            vibrancy          = 0.22,
        },
    },

    animations = {
        enabled = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

-- Default curves and animations, see https://wiki.hypr.land/configuring/core/animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

-- Default springs
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- Ref https://wiki.hypr.land/configuring/core/rules/workspace-rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/configuring/layouts/dwindle-layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/configuring/layouts/master-layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

-- See https://wiki.hypr.land/configuring/layouts/scrolling-layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
    },
})


----------------
---- LAYERS ----
----------------

hl.config({
    layers = {
        allow_new_top_layers_over_existing_fullscreen = true, -- Set to false to make newly mapped top layers render below existing covering fullscreen window
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout  = "latam",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/configuring/core/devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/configuring/core/binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("python3 /home/cian/scripts/smart_float_toggle.py"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind("Print", hl.dsp.exec_cmd("captura-recorte"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("captura-recorte"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("ironbar bar top toggle-visible"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Resize windows with mainMod + ALT + arrow keys
hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }),  { repeating = true })
hl.bind(mainMod .. " + ALT + up",    hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
hl.bind(mainMod .. " + ALT + down",  hl.dsp.window.resize({ x = 0, y = 30, relative = true }),  { repeating = true })

-- Wallpaper switcher & Wallpaper Engine capturer (MP4/GIF)
hl.bind(mainMod .. " + W",         hl.dsp.exec_cmd("python3 /home/cian/scripts/wallpaper_switcher.py"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("python3 /home/cian/scripts/capture_wallpaper.py"))

-- Individual window shrink / grow without limits (auto-floats if tiled)
hl.bind(mainMod .. " + minus",       hl.dsp.exec_cmd("python3 /home/cian/scripts/window_scale.py shrink"), { repeating = true })
hl.bind(mainMod .. " + KP_Subtract", hl.dsp.exec_cmd("python3 /home/cian/scripts/window_scale.py shrink"), { repeating = true })
hl.bind(mainMod .. " + plus",        hl.dsp.exec_cmd("python3 /home/cian/scripts/window_scale.py grow"),   { repeating = true })
hl.bind(mainMod .. " + KP_Add",      hl.dsp.exec_cmd("python3 /home/cian/scripts/window_scale.py grow"),   { repeating = true })
hl.bind(mainMod .. " + BackSpace",   hl.dsp.exec_cmd("python3 /home/cian/scripts/window_scale.py reset"))

-- Global monitor HiDPI scaling
hl.bind(mainMod .. " + CTRL + minus",       hl.dsp.exec_cmd("python3 /home/cian/scripts/hidpi_scale.py down"))
hl.bind(mainMod .. " + CTRL + KP_Subtract", hl.dsp.exec_cmd("python3 /home/cian/scripts/hidpi_scale.py down"))
hl.bind(mainMod .. " + CTRL + plus",        hl.dsp.exec_cmd("python3 /home/cian/scripts/hidpi_scale.py up"))
hl.bind(mainMod .. " + CTRL + KP_Add",      hl.dsp.exec_cmd("python3 /home/cian/scripts/hidpi_scale.py up"))
hl.bind(mainMod .. " + ALT + 0",            hl.dsp.exec_cmd("python3 /home/cian/scripts/hidpi_scale.py reset"))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/configuring/core/rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Evitar que videos (YouTube, etc.) en navegadores tomen todo el monitor al poner pantalla completa
    name           = "suppress-browser-fullscreen",
    match          = { class = "^(firefox|google-chrome|chromium|brave-browser|zen)$" },
    suppress_event = "fullscreen",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})



-- Keep kitty text 100% opaque while its background stays transparent via kitty.conf
hl.window_rule({
    name    = "kitty-opacity",
    match   = { class = "kitty" },
    opacity = "1.0 0.92",
})

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

-- Ironbar Liquid Glass layer rule
hl.layer_rule({
    name         = "ironbar-glass",
    match        = { namespace = "^ironbar$" },
    blur         = true,
    ignore_alpha = 0.1,
})

-- >>> hyprland-infinite-desktop-v2 (auto-installed) START
-- mainMod detected/used: "SUPER"
    hl.on("hyprland.start", function()
        hl.exec_cmd("python3 /home/cian/scripts/infinite_desktop_core.py 1.6 > /tmp/infinite-desktop.log 2>&1")
        hl.exec_cmd("serpantinum-launcher --daemon")
    end)

-- Infinite desktop keybinds
hl.bind("SUPER" .. " + Z", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER" .. " + X", hl.dsp.focus({ workspace = "+1" }))
hl.bind("SUPER" .. " + SHIFT + Z", hl.dsp.window.move({ workspace = "-1" }))
hl.bind("SUPER" .. " + SHIFT + X", hl.dsp.window.move({ workspace = "+1" }))
hl.bind("SUPER" .. " + D", hl.dsp.exec_cmd("python3 /home/cian/scripts/floating_tile_toggle.py"))
hl.bind("SUPER" .. " + left", hl.dsp.exec_cmd("python3 /home/cian/scripts/navigate_windows.py left"))
hl.bind("SUPER" .. " + ALT + left", hl.dsp.exec_cmd("python3 /home/cian/scripts/move_window_tiled.py left"))
hl.bind("SUPER" .. " + SHIFT + left", hl.dsp.exec_cmd("python3 /home/cian/scripts/move_window.py left"), { repeating = true })
hl.bind("SUPER" .. " + CTRL + left", hl.dsp.exec_cmd("python3 /home/cian/scripts/resize_window.py left"), { repeating = true })
hl.bind("SUPER" .. " + right", hl.dsp.exec_cmd("python3 /home/cian/scripts/navigate_windows.py right"))
hl.bind("SUPER" .. " + ALT + right", hl.dsp.exec_cmd("python3 /home/cian/scripts/move_window_tiled.py right"))
hl.bind("SUPER" .. " + SHIFT + right", hl.dsp.exec_cmd("python3 /home/cian/scripts/move_window.py right"), { repeating = true })
hl.bind("SUPER" .. " + CTRL + right", hl.dsp.exec_cmd("python3 /home/cian/scripts/resize_window.py right"), { repeating = true })
hl.bind("SUPER" .. " + up", hl.dsp.exec_cmd("python3 /home/cian/scripts/navigate_windows.py up"))
hl.bind("SUPER" .. " + ALT + up", hl.dsp.exec_cmd("python3 /home/cian/scripts/move_window_tiled.py up"))
hl.bind("SUPER" .. " + SHIFT + up", hl.dsp.exec_cmd("python3 /home/cian/scripts/move_window.py up"), { repeating = true })
hl.bind("SUPER" .. " + CTRL + up", hl.dsp.exec_cmd("python3 /home/cian/scripts/resize_window.py up"), { repeating = true })
hl.bind("SUPER" .. " + down", hl.dsp.exec_cmd("python3 /home/cian/scripts/navigate_windows.py down"))
hl.bind("SUPER" .. " + ALT + down", hl.dsp.exec_cmd("python3 /home/cian/scripts/move_window_tiled.py down"))
hl.bind("SUPER" .. " + SHIFT + down", hl.dsp.exec_cmd("python3 /home/cian/scripts/move_window.py down"), { repeating = true })
hl.bind("SUPER" .. " + CTRL + down", hl.dsp.exec_cmd("python3 /home/cian/scripts/resize_window.py down"), { repeating = true })
-- <<< hyprland-infinite-desktop-v2 (auto-installed) END

