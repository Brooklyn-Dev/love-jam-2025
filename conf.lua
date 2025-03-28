package.path = "src/?.lua;" .. package.path

function love.conf(t)
    t.window.title = "LÖVE Jam 2025"
    t.window.width = 640
    t.window.height = 640
    t.window.resizable = false
    t.window.vsync = true
    t.modules.audio = true
    t.modules.physics = false
    t.identity = "love_jam_2025"
    t.version = "11.5"
    t.console = false
end