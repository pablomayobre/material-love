local material = {
	_VERSION     = 'material-love v0.1.0',
	_DESCRIPTION = 'Implementation of parts of the Material-Design spec, for LOVE',
	_URL         = 'https://www.github.com/Positive07/material-love',
	_LICENSE     = [[
		The MIT License (MIT)

		Copyright (c) 2015 Pablo Mayobre

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
	]]
}

local a = (...)..".libs."
local b = (...):gsub("%.","%/").."/assets"

material.nine = require (a.."nine")
material.icons = require (a.."icons")
material.ripple = require (a.."ripple")
material.color = require (a.."colors")
material.roundrect = require (a.."roundrect")
material.fab = require (a.."fab")(b)
material.roboto = require (a.."roboto")(b)
material.image = require (a.."image")
material.spinner = require (a.."spinner")

material.shadow = {}
material.shadow.patch = material.nine.process(require (a.."shadow")(b))

material.shadow.draw = function (...)
	return material.shadow.patch:draw(...)
end

local drawicons = require (a.."drawicons")(b,material.icons,material.color)
material.icons.draw = drawicons

return material