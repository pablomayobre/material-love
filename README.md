# Material-Love
![Logo Material - Love](https://github.com/Positive07/material-love/blob/master/images/logo.png)

Material-Love is a set of libraries to use some of the features described in the Google [Material-Design spec][1], in your [LÖVE][2] projects.

![Animation of Material - Love working](https://github.com/Positive07/material-love/blob/master/images/master.gif)

Material-Love takes the overhead of generating some of the fancy effects described in those docs, like shadows, paper and ripples. It also facilitates the access to some other stuff like the Roboto Fonts, the color palettes, and even provides an icon font with 670 icons you can use in your project!

***

It is **NOT** a UI library nor is it intended to be, if you want you can use it with any other GUI library like [Thranduil][3], [DOMinatrix][4], [Quickie][5] or, with some serious effort, [Love Frames][6].

> **Note:** that none of them are really supported by this library. And as such it is not guaranteed to work.

***

## What is required?

If you want to use this libs be sure that you have some knowledge on [LÖVE][2] and [Lua][7].

You need to have LÖVE installed and a basic project set up with the **`material-love`** folder in it and the `main.lua` file with this basic code:

```lua
love.load = function ()
end

love.update = function (dt)
end

love.draw = function ()
end
```

You can delete the `images` folder since those images are just for documentation or Demos.

> **Note:** You can rename the folder to whatever you like, but be consistent through all your project

|

> **Note:** This is the base requirement. If you have an already working game, made with LOVE, then you can also use that. If you use some library, that gives you some other functions, you can adapt material-love to work with it.

## What should I read first?

You can begin almost everywhere, each page tells you if you need to know something else before you continue, so start wherever you like.

Check the features you may want to use in your project. Sometimes you don't need all of them, so you may prefer not to include all the libraries in this repository.

You can go to any page using the links of the tables of content at the right, which lists all the pages in this wiki.

## License

This set of libraries is Licensed under **[MIT License][9]**

Copyright(c) 2015 Pablo Ariel Mayobre (@Positive07)

I must give credit to @Robin ([gvx][8]) for the `roundrect.lua` library which I used as a base for my own `roundrect.lua`

[1]:https://www.google.com/design/spec/
[2]:https://www.love2d.org
[3]:https://www.github.com/adonaac/thranduil
[4]:https://www.github.com/excessive/DOMinatrix
[5]:https://www.github.com/vrld/Quickie
[6]:https://www.github.com/KennyShields/LoveFrames
[7]:http://www.lua.org/pil
[8]:https://www.github.com/gvx
[9]:https://www.github.com/Positive07/material-love/tree/master/LICENSE
