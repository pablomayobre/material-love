local nine = {
	_VERSION     = 'nine.lua v0.1.0',
	_DESCRIPTION = 'Nine Patch implementation for LOVE (Part of Material-Love)',
	_URL         = 'https://www.github.com/Positive07/material-love/tree/master/libs/nine.lua',
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

local calc = {}

calc.cor = function (cor,x,y,w,h,i)
	local x = (i == 1 or i == 4) and -cor.w or w
	local y = i < 3 and -cor.h or h
	return x,y
end

calc.bor = function (bor,x,y,w,h,i)
	local sx = ((i % 2) == 0) and 1 or w/bor.w
	local sy = ((i % 2) == 1) and 1 or h/bor.h

	local x = (i % 2) == 1 and 0 or (i == 2 and w or -bor.w)
	local y = (i % 2) == 0 and 0 or (i == 3 and h or -bor.h)

	return x,y,sx,sy
end

function nine.draw(p,x,y,w,h,center,pad,img)
	local img = img or p.default

	if not p.assets[img] then
		error (img.." is not a valid asset for this patch",2)
	end

	local d = love.graphics.draw
	local x,y,w,h,_ox,_oy,_ow,_oh = x,y,w,h,x,y,w,h

	if pad then
		x,y,w,h = x - p.pad[4], y - p.pad[1], w + p.pad[2] + p.pad[4], h + p.pad[1] + p.pad[3]
	end

	for i = 1, 4 do
		if p.cor[i].quad then
			local dx,dy = calc.cor(p.cor[i],x,y,w,h,i)
			d(p.assets[img], p.cor[i].quad, x + dx, y + dy)
		end
		if p.bor[i].quad then
			local dx,dy,sx,sy = calc.bor(p.bor[i],x,y,w,h,i)
			d(p.assets[img], p.bor[i].quad, x + dx, y + dy, 0, sx, sy)
		end
	end

	if center and p.center then
		d(p.assets[img], p.center, _ox, _oy, 0, _ow/p.w, _oh/p.h)
	end
end

function nine.process (patch)
	local assets, default = {}
	if patch.multiimage then
		if not type(patch.image)=="table" then
			error("This patch specifies multi-image but doesnt hold a table",2)
		end
		local i = 0
		for k,v in pairs(patch.image) do
			i = i + 1
			if k ~= "default" then
				assets[k] = love.graphics.newImage(v)
			end
		end
		if i < 2 then error("No images for this patch",2) end
		default = patch.image.default
		if not assets[default] then
			error("The default image for this patch could not be found",2)
		end
	else
		if not type(patch.image)=="string" then
			error("The value for the image of this patch is not valid",2)
		end
		assets[1] = love.graphics.newImage(patch.image)
		default = 1
	end

	local _w, _h = assets[default]:getDimensions()
	local _xw, _yh = patch.hor.x + patch.hor.w, patch.ver.y + patch.ver.h
	local _wc, _hc = _w - _xw, _h - _yh

	local cor = {
		{ x = 0,	y = 0,		w = patch.hor.x,	h = patch.ver.y	},
		{ x = _xw,	y = 0,		w = _wc,			h = patch.ver.y	},
		{ x = _xw,	y = _yh,	w = _wc,			h = _hc			},
		{ x = 0,	y = _yh,	w = patch.hor.x,	h = _hc			}
	}
	local bor = {
		{ x = patch.hor.x,	y = 0,				w = patch.hor.w,	h = patch.ver.y	},
		{ x = _xw,			y = patch.ver.y,	w = _wc,			h = patch.ver.h	},
		{ x = patch.hor.x,	y = _yh,			w = patch.hor.w,	h = _hc			},
		{ x = 0,			y = patch.ver.y,	w = patch.hor.x,	h = patch.ver.h	}
	}

	for i=1, 4 do
		if cor[i].w > 0 and cor[i].h > 0 then
			cor[i].quad = love.graphics.newQuad(cor[i].x, cor[i].y, cor[i].w, cor[i].h, _w, _h)
		end
		if bor[i].w > 0 and bor[i].h > 0 then
			bor[i].quad = love.graphics.newQuad(bor[i].x, bor[i].y, bor[i].w, bor[i].h, _w, _h)
		end
	end

	local center
	if patch.ver.h > 0 and patch.hor.w > 0 then
		center = love.graphics.newQuad(patch.hor.x, patch.ver.y, patch.hor.w, patch.ver.h, _w, _h)
	end

	return {
		assets = assets,
		default = default,
		bor = bor,
		cor = cor,
		pad = patch.pad,
		center = center,
		w = patch.hor.w,
		h = patch.ver.h,
		draw = nine.draw,
	}
end

function nine.convert(img,name,encode)
	local name = name or "image"
	local encode = encode or false
	local idata = img:getData()
	local hor,ver = {},{}
	local por,per = {},{}
	local h,w = img:getHeight(),img:getWidth()

	for i=0, w - 1 do
		local r,g,b,a = idata:getPixel(i,0)

		if hor.x then
			if not hor.w and (r ~= 0 or g ~=0 or b ~= 0 or a ~= 255) then
				hor.w = (i - 1) - hor.x
			end
		else
			if r == 0 and g == 0 and b == 0 and a == 255 then
				hor.x = i - 1
			end
		end

		local r,g,b,a = idata:getPixel(i,h - 1)

		if por.x then
			if not por.w and (r ~= 0 or g ~= 0 or b ~= 0 or a ~= 255) then
				por.w = (i - 1) - por.x
			end
		else
			if r == 0 and g == 0 and b == 0 and a == 255 then
				por.x = i - 1
			end
		end

		if hor.w and por.w then
			break
		end
	end

	if not hor.x then
		error ("Inavalid 9-patch image, it doesnt contain an horizontal line",2)
	end
	if not hor.w then
		hor.w = (w - 1) - hor.x
	end

	for i=0, h - 1 do
		local r,g,b,a = idata:getPixel(0,i)

		if ver.y then
			if not ver.h and (r ~= 0 or g ~=0 or b ~= 0 or a ~= 255) then
				ver.h = (i - 1) - ver.y
			end
		else
			if r == 0 and g == 0 and b == 0 and a == 255 then
				ver.y = i - 1
			end
		end

		local r,g,b,a = idata:getPixel(w - 1,i)

		if per.y then
			if not per.h and (r ~= 0 or g ~= 0 or b ~= 0 or a ~= 255) then
				per.h = (i - 1) - per.y
			end
		else
			if r == 0 and g == 0 and b == 0 and a == 255 then
				per.y = i - 1
			end
		end

		if ver.h and per.h then
			break
		end
	end
	
	if not ver.y then
		error("Inavalid 9-patch image, it doesnt contain a vertical line",2)
	end
	if not ver.h then
		ver.h = (h - 1) - ver.y
	end

	por.w = por.x and (por.w and por.w or (w - 1 - por.x))or hor.w
	per.h = per.y and (per.h and per.h or (h - 1 - per.y))or ver.h

	por.x = por.x and por.x or hor.x
	per.y = per.y and per.y or ver.y

	print(per.y,per.h,ver.y,ver.h)
	
	local pad = {
		per.y - ver.y,
		(hor.x + hor.w) - (por.x + por.w),
		(ver.y + ver.h) - (per.y + per.h),
		por.x - hor.x,
	}

	local p = ""
	
	for i = 1, 4 do
		p = p..pad[i]..","
	end

	local w,h = img:getWidth()-2, img:getHeight()-2
	local asset = love.image.newImageData(w,h)
	asset:paste(idata, 0, 0, 1, 1, w, h)

	local str = [[return function (a)
	return {
		multiimage = false,
		image = a.."/]]..name..[[.png",
		hor = {x = ]]..hor.x..[[,w = ]]..hor.w..[[},
		ver = {y = ]]..ver.y..[[,h = ]]..ver.h..[[},
		pad = {]]..p:sub(1,-2)..[[},
	}
end]]

	if encode then
		if type(encode) ~= "string" then
			encode = ""
		else
			encode = encode.."/"
		end

		asset:encode(encode..name..".png")
		love.filesystem.write(encode..name..".lua",str)
	end

	return str,asset
end

return nine