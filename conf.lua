-- LÖVE2D Configuration
function love.conf(t)
    t.title = "Get Rich or Die Trying"
    t.version = "11.4"
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = false
    t.window.vsync = 1

    -- Enable console on Windows for debugging
    t.console = true

    -- Identity for save files
    t.identity = "hk-roguelike-game"
end