function love.conf(t)
    t.title   = "Material-Love"
    t.author  = "Pablo A. Mayobre - Positive07"
    t.url     = "https://www.github.com/Positive07/material-love"
    t.license = "MIT License - Copyright (c) 2015-2016 Pablo A. Mayobre (Positive07)"

    t.identity       = "Material-Love"                   -- The name of the save directory (string)
    t.window.title   = "Material-Love"                   -- The window title (string)
    t.window.icon    = "material-love/images/icon32.png" -- Filepath to an image to use as the window's icon (string)
    t.window.width   = 400                               -- The window width (number)
    t.window.height  = 400                               -- The window height (number)
    t.window.highdpi = true                              -- Enable high-dpi mode for the window on a Retina display (boolean)

    t.modules.video    = false                           -- Enable the video module (boolean)
    t.modules.audio    = false                           -- Enable the audio module (boolean)
    t.modules.joystick = false                           -- Enable the joystick module (boolean)
    t.modules.physics  = false                           -- Enable the physics module (boolean)
    t.modules.sound    = false                           -- Enable the sound module (boolean)
    t.modules.thread   = false                           -- Enable the thread module (boolean)
end
