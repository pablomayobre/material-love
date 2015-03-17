# How to Contribute

I would seriously love your help on this project, we would like to hear how this library performs in your project, your sugerences and issues.
Also we would really appreciate your contributions, so that this project can keep growing better. That is why this guide is to help you and me so that contributing to this project is easier.

Please follow this guideline in your Issues and Pull Request, otherwise I would not pay as much attention as it deserves.

## Bugs

Well this library is pretty new so it may contain bugs in it, so in order for me or someone else to fix them you will need to provide some info.

1. First make sure that the issue was not posted before, look through the open issues and if you find someone having the same issue then comment on it saying you also have the same issue (if you can, post your system info and the error returned by LÖVE).
2. Look though closed issues, if the issue was reported before, try the proposed fixes, if the error persist, add "Similar to issue #n" in your issue description.
3. Mark your issue as a bug by appending `[Bug]` to your issue name
4. Make a descriptive title, but make it shor, "Please help me" is not a good example.
5. State the library you are having problems with, if you have problems with `nine.lua` then append `[nine]` to your issue name
6. Please provide info about your system, like Operating System and the version of LÖVE you are using
7. If you can, provide the error log that LÖVE outputs in the blue screen.
8. Help us recreate the bug, through a code snippet or uploading a `.love` file
9. Write a good description... Though if you provided everything I wrote above, it will be descriptive enough.

This pretty much applies to everything from here onwards.

## Feature Requests

The same as above, but instead of bug, add `[Feature]` to your issue tittle.
Your system info, the error, and info on how to recreate it of course is not required

But you have to state which library you want to expand, in the title, for example if the feature is for the colors library add `[colors]` to your title.

Also provide a good description of the feature and an example of the API you expect it to use.

If it is related to the Material-Design spec, provide a link to where the spec talks about it.

## Problems with the docs

Add `[Doc]` to the title, and a link to the page, the one with the error, in your description.

## Patches

If you can fix an issue and want to make a Pull Request that would be really amazing!

Just be sure to provide info on what it fixes and in which file, similar than with issues (Adding the name to the title).

If the issue was reported please add "Fixes #n" to your description.

## New Functionalities!

Awesome! You have some new functionalities to add to this library and you want me to merge your idea into Material-Love.

Well that is amazing! This library intends to keep growing in order to fullfill the Material-Design Guidelines so make sure that your new functionality fits this rules:

1. It adds a feature, that is part of the Material-Design spec
2. It was not previously there. Or it does the same thing as other lib, but in other way, and may be more efficient or provides more features.

Examples of this would be:

>Spinners: Loading spinners are not currently implemented into this lib, but are part of the spec.

|

>Shadows-Shader: Currently we use nine-patch which is kinda static, shaders would add the feature to make shadows more dynamic.

## Coding style

If you think my coding style sucks (which is true) and want to propose a better way to write something, dont make a Pull Request, instead make an Issue.

## Credits

* People that help fixing issues by providing good info or by commenting on possible fixes.

* People that make Pull Requests with patches or new features.

* People that serve of inspiration or which serve as base for my code.

All of them get credited in the [README.md](https://www.github.com/Positive07/material-love/tree/master/README.md).

So if you are not sure if you want to submit your issue please DO SO! even if you dont provide all the info I asked for, here, your issue will be taken into account, so don't hesitate!

## License

Remember this code is Licensed under **[MIT License](https://www.github.com/Positive07/material-love/tree/master/LICENSE)**, and so must be your patches and new features.

This also means that you can do whatever you want with this lib, so if you have issues and I wont fix them for some reason, just fork it and do whatever you like with my code! I'll be glad to take a pick whenever you make changes.
