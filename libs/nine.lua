local nine = {
	_VERSION     = 'nine.lua v1.0.0',
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

local add = function (state, x, y, w, h, sx, sy, j, k)
	state.areas[#state.areas + 1] = {}
	local a = state.areas[#state.areas]

	if w and w > 0 and h and h > 0 then
		a.quad = love.graphics.newQuad(x,y,w,h,state.dimensions.w, state.dimensions.h)
	end

	a.x, a.y, a.w, a.h, a.sx, a.sy, a.j, a.k = x, y, w, h, sx, sy, j, k
end

local vertical = function (state, x, w, sx, j, count)
	local ver = state.ver
	local prevyh = 0

	local k = 0

	for i=1, #ver do
		if ver[i].y > prevyh then
			k = k + 1

			add(state, x, prevyh, w, ver[i].y - prevyh, sx, false, j, k)

			if count then
				if k == 1 then
					state.dy = - ver[i].y - prevyh
					state.dh = - state.dy
				end

				state.static.y = state.static.y + ver[i].y - prevyh
			end

			prevyh = ver[i].y
		end

		if ver[i].y == prevyh then
			k = k + 1

			add(state, x, ver[i].y, w, ver[i].h, sx, true, j, k)

			prevyh = ver[i].y + ver[i].h
		else
			error("The start of the vertical line "..i.." comes before another line finishes", 2)
		end
	end

	if prevyh < state.dimensions.h then
		k = k + 1

		add(state, x, prevyh, w, state.dimensions.h - prevyh, sx, false, j, k)

		if count then
			state.dh = state.dh + state.dimensions.h - prevyh
			state.static.y = state.static.y + state.dimensions.h - prevyh
		end
	end
end

local horizontal = function (state)
	local hor = state.hor
	local prevxw = 0

	local j = 0
	for i=1, #hor do
		local count = (i == 1)

		if hor[i].x > prevxw then
			j = j + 1

			local c
			if count then count, c = false, true end

			if c then
				state.dx = - hor[i].x - prevxw
				state.dw = - state.dx
			end

			vertical(state, prevxw, hor[i].x - prevxw, false, j, c)
			state.static.x = state.static.x + hor[i].x - prevxw

			prevxw = hor[i].x
		end

		if hor[i].x == prevxw then
			j = j + 1

			local c
			if count then count, c = false, true end

			vertical(state, hor[i].x, hor[i].w, true, j, c)

			prevxw = hor[i].x + hor[i].w
		else
			error("The start of the horizontal line "..i.." comes before another line finishes", 2)
		end
	end

	if prevxw < state.dimensions.w then
		j = j + 1
		
		state.dw = state.dw + state.dimensions.w - prevxw
		
		vertical(state, prevxw, state.dimensions.w - prevxw, false, j)
		state.static.x = state.static.x + state.dimensions.w - prevxw
	end
end

nine.draw = function (p,x, y, w, h, pad, img)
	local img = img or p.default

	if not p.assets[img] then
		error (img.." is not a valid asset for this patch",2)
	end

	local d = love.graphics.draw
	local x,y,w,h = (x or 0) + p.dx, (y or 0) + p.dy , (w or 0) + p.dw, (h or 0) + p.dh

	if pad then
		x,y,w,h = x - p.pad[4], y - p.pad[1], w + p.pad[2] + p.pad[4], h + p.pad[1] + p.pad[3]
	end

	local ow, oh = w - p.static.x, h - p.static.y
	if ow < 0 then error ("The width (" ..w..") is less than the minimum width (" ..p.static.x..") of this patch", 2) end
	if oh < 0 then error ("The height ("..h..") is less than the minimum height ("..p.static.y..") of this patch", 2) end

	local pax, pay = x, y
	local sax, say = ow / p.dinamic.x, oh / p.dinamic.y

	local j, k = 1, 1
	for i=1, #p.areas do
		if p.areas[i].j > j then
			j = p.areas[i].j
			pax = pax + p.areas[i - 1].w * (p.areas[i - 1].sx and sax or 1)
		end

		if p.areas[i].k > k then
			k = p.areas[i].k
			pay = pay + p.areas[i - 1].h * (p.areas[i - 1].sy and say or 1)
		elseif p.areas[i].k == 1 then
			k = p.areas[i].k
			pay = y
		end

		if p.areas[i].quad then
			d(p.assets[img], p.areas[i].quad, pax, pay, 0, p.areas[i].sx and sax or 1, p.areas[i].sy and say or 1)
		end
	end
end

nine.process = function (patch, images)
	local assets, images, default = {}, images or {}

	if not type(patch.image)=="table" then
		error("All images should be inside a table", 2)
	end

	local i = 0
	for k,v in pairs(patch.image) do
		if k ~= "default" then
			i = i + 1
			assets[k] = images[k] or love.graphics.newImage(v)
		end
	end

	if i < 1 then error("No images for this patch", 2) end

	default = patch.image.default or 1

	if not assets[default] then
		error("The default image for this patch could not be found", 2)
	end

	local _w, _h = assets[default]:getDimensions()

	local state = {
		assets = assets,
		default = default,
		pad = patch.pad,
		hor = patch.hor,
		ver = patch.ver,
		areas = {},
		static = {x = 0, y = 0},
		dimensions = {w = _w, h = _h},
		draw = nine.draw,
	}

	horizontal(state)

	if #state.areas < 1 then
		error("There are no areas in this patch", 2)
	end

	state.dinamic = {
		x = state.dimensions.w - state.static.x,
		y = state.dimensions.h - state.static.y,
	}

	state.hor, state.ver = nil, nil

	return state
end

function nine.convert(img,name,encode)
	local name = name or "image"
	local encode = encode or false

	local idata = img:getData()

	local hor,ver = {{}},{{}}
	local por,per = {},{}

	local h,w = img:getHeight(),img:getWidth()

	for i=0, w - 1 do
		local r, g, b, a = idata:getPixel(i, 0)

		if hor[#hor].x then
			if not hor[#hor].w and (r ~= 0 or g ~=0 or b ~= 0 or a ~= 255) then
				hor[#hor].w = (i - 1) - hor[#hor].x
			end
		else
			if r == 0 and g == 0 and b == 0 and a == 255 then
				hor[#hor].x = i - 1
			end
		end

		local r, g, b, a = idata:getPixel(i, h - 1)

		if por.x then
			if not por.w and (r ~= 0 or g ~= 0 or b ~= 0 or a ~= 255) then
				por.w = (i - 1) - por.x
			end
		else
			if r == 0 and g == 0 and b == 0 and a == 255 then
				por.x = i - 1
			end
		end

		if hor[#hor].w then
			hor[#hor + 1] = {}
		end
	end

	if not hor[#hor].x then
		if #hor == 1 then
			error ("Inavalid 9-patch image, it doesnt contain an horizontal line",2)
		else
			hor[#hor] = nil
		end
	end

	if not hor[#hor].w then
		hor[#hor].w = (w - 1) - hor[#hor].x
	end

	for i=0, h - 1 do
		local r, g, b, a = idata:getPixel(0, i)

		if ver[#ver].y then
			if not ver.h and (r ~= 0 or g ~=0 or b ~= 0 or a ~= 255) then
				ver[#ver].h = (i - 1) - ver[#ver].y
			end
		else
			if r == 0 and g == 0 and b == 0 and a == 255 then
				ver[#ver].y = i - 1
			end
		end

		local r, g, b, a = idata:getPixel(w - 1, i)

		if per.y then
			if not per.h and (r ~= 0 or g ~= 0 or b ~= 0 or a ~= 255) then
				per.h = (i - 1) - per.y
			end
		else
			if r == 0 and g == 0 and b == 0 and a == 255 then
				per.y = i - 1
			end
		end

		if ver[#ver].h then
			ver[#ver + 1] = {}
		end
	end

	if not ver[#ver].y then
		if #ver == 1 then
			error("Inavalid 9-patch image, it doesnt contain a vertical line",2)
		else
			ver[#ver] = nil
		end
	end

	if not ver[#ver].h then
		ver[#ver].h = (h - 1) - ver[#ver].y
	end

	local horw = hor[#hor].x + hor[#hor].w - hor[1].x
	local verh = ver[#ver].y + ver[#ver].h - ver[1].y

	por.w = por.x and (por.w and por.w or (w - 1 - por.x)) or horw
	per.h = per.y and (per.h and per.h or (h - 1 - per.y)) or verh

	por.x = por.x and por.x or hor[1].x
	per.y = per.y and per.y or ver[1].y

	local pad = {
		per.y - ver[1].y,
		(hor[1].x + horw) - (por.x + por.w),
		(ver[1].y + verh) - (per.y + per.h),
		por.x - hor[1].x,
	}

	local p = ""

	for i = 1, 4 do
		p = p..pad[i]..", "
	end

	local w,h = img:getWidth()-2, img:getHeight()-2
	local asset = love.image.newImageData(w, h)

	asset:paste(idata, 0, 0, 1, 1, w, h)
	
	local hs, vs = "", ""
	
	for i=1, #hor do
		hs = hs.."\n\t\t\t{x = "..hor[i].x..", w = "..hor[i].w.."},"
	end
	for i=1, #ver do
		vs = vs.."\n\t\t\t{y = "..ver[i].y..", h = "..ver[i].h.."},"
	end

	local str = [[return function (a)
	local a = a or ""
	return {
		image = {
			a.."/]]..name..[[.png",
		},
		pad = {]]..p:sub  (1, -3)..[[},
		hor = {]]..hs:sub (1, -2)..[[
		},
		ver = {]]..vs:sub (1, -2)..[[
		},
	}
end]]

	if encode then
		if type(encode) ~= "string" then
			encode = ""
		else
			encode = encode.."/"
		end

		asset:encode(encode..name..".png")
		love.filesystem.write(encode..name..".lua", str)
	end

	return str,asset
end

return nine