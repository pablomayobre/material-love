# Material-Love
![Logo Material - Love](https://github.com/Positive07/material-love/blob/master/images/logo.png)

Material-Love is a set of libraries to use some of the features described in the Google [Material-Design spec][1], in your [LÖVE][2] projects.

![Animation of Material - Love working](https://github.com/Positive07/material-love/blob/master/images/master.gif)

Material-Love takes the overhead of generating some of the fancy effects described in those docs, like shadows, paper and ripples. It also facilitates the access to some other stuff like the Roboto Fonts, the color palettes, and even provides an icon font with 1008 icons you can use in your project!

***

It is **NOT** a UI library nor is it intended to be, if you want you can use it with any other GUI library like [Thranduil][3], [DOMinatrix][4], [Quickie][5] or, with some serious effort, [Love Frames][6].

> **Note:** None of them are really supported by this library. And as such it is not guaranteed to work.

***

## Demo

Download a demo of this library from the releases [here](https://github.com/Positive07/material-love/releases/tag/1.0.0-demo)

Check the demo source code in the [`test` branch](https://github.com/Positive07/material-love/tree/test)

## Download

You can `git clone` this repo (I recommend you go to the [`source` branch](https://github.com/Positive07/material-love/tree/source), since it doesnt have the bothersome image folder nor the README.md or CONTRIBUTING.md)

```shell
git clone https://github.com/Positive07/material-love.git
git checkout source
```

Alternatively you can download a `.zip` or `.tar.gz` from the [Releases](https://github.com/Positive07/material-love/releases/tag/1.0.0)

## Documentation

Check the [Wiki][10] page here at GitHub.

It has description on each library and how to use them in your project.

## Contributing

Check the [CONTRIBUTING.md][14] file for a Guide on how to contribute to this project.

It tells you how to format your Issues and Pull Request so that is easier for me to help you.

You may also ask simple questions in the [LÖVE forums][15]!

## Credits

I must give credit to Robin ([gvx][8]) for the [`roundrect.lua`][13] library which I used as a base for my own `roundrect.lua`

Also thanks to [Mrmaxmeier][11] for [fixing some issues][12] in the `nine.convert` function and the [`image.lua` file][16].

## License

This set of libraries is Licensed under **[MIT License][9]**

Copyright(c) 2015 Pablo Ariel Mayobre (Positive07)

The Material Design Icon font is Licensed under **[SIL Open Font License 1.1][17]** (The License file can be found [here][19])

Some of the icons are designed by Google and are under Copyright **[CC-BY][18]**

[1]:https://www.google.com/design/spec/
[2]:https://www.love2d.org
[3]:https://www.github.com/adonaac/thranduil
[4]:https://www.github.com/excessive/DOMinatrix
[5]:https://www.github.com/vrld/Quickie
[6]:https://www.github.com/KennyShields/LoveFrames
[7]:http://www.lua.org/pil
[8]:https://www.github.com/gvx
[9]:https://www.github.com/Positive07/material-love/tree/master/LICENSE
[10]:https://www.github.com/Positive07/material-love/wiki
[11]:https://www.github.com/Mrmaxmeier
[12]:https://www.github.com/Positive07/material-love/pull/3
[13]:https://gist.github.com/gvx/9072860
[14]:https://www.github.com/Positive07/material-love/tree/master/CONTRIBUTING.md
[15]:https://love2d.org/forums/viewtopic.php?f=5&t=79918
[16]:https://github.com/Positive07/material-love/blob/d119314500b36b9d965199f065d64008b38884da/libs/image.lua
[17]:https://github.com/Templarian/MaterialDesign/blob/master/license.txt
[18]:https://github.com/google/material-design-icons/blob/master/LICENSE
[19]:https://github.com/Positive07/material-love/blob/master/assets/icons.license.txt
