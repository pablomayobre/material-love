local patchy = {
	_VERSION     = 'patchy.lua v2.0.0',
	_DESCRIPTION = 'Simple 9patch library for LÖVE',
	_URL         = 'https://github.com/excessive/patchy/tree/master/patchy.lua',
	_LICENSE     = [[
		The MIT License (MIT)

		Copyright (c) 2015 Pablo Mayobre, Colby Klein, Landon Manning

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

local function vertical(state, x, w, sx, row, first)
	local function add(state, x, y, w, h, sx, sy, row, col)
		state.areas[#state.areas + 1] = {
			x   = x,   -- start x
			y   = y,   -- start y
			w   = w,   -- end x
			h   = h,   -- end y
			sx  = sx,  -- scale on x (bool)
			sy  = sy,  -- scale on y (bool)
			row = row, -- row number
			col = col, -- col number
		}
	end

	local scale_y        = state.scale_y
	local current_pixel  = 0
	local col            = 0

	for i=1, #scale_y do
		if scale_y[i].y > current_pixel then
			col = col + 1

			add(state, x, current_pixel, w, scale_y[i].y - current_pixel, sx, false, row, col)

			if first then
				state.static.y = state.static.y + scale_y[i].y - current_pixel
			end

			current_pixel = scale_y[i].y
		end

		if scale_y[i].y == current_pixel then
			col = col + 1

			add(state, x, scale_y[i].y, w, scale_y[i].h, sx, true, row, col)

			current_pixel = scale_y[i].y + scale_y[i].h
		else
			error("The start of the vertical line "..i.." comes before another line finishes", 2)
		end
	end

	if current_pixel < state.dimensions.h then
		col = col + 1

		add(state, x, current_pixel, w, state.dimensions.h - current_pixel, sx, false, row, col)

		if first then
			state.static.y = state.static.y + state.dimensions.h - current_pixel
		end
	end
end

local function horizontal(state)
	local scale_x        = state.scale_x
	local current_pixel  = 0
	local row            = 0

	for i=1, #scale_x do
		-- If scale area is after current pixel
		if scale_x[i].x > current_pixel then
			row = row + 1

			-- If first scale area
			if i == 1 then
				vertical(state, current_pixel, scale_x[i].x - current_pixel, false, row, true)
			else
				vertical(state, current_pixel, scale_x[i].x - current_pixel, false, row)
			end

			-- calculate non-scaled area
			state.static.x = state.static.x + scale_x[i].x - current_pixel

			-- set current pixel to start of scale area
			current_pixel = scale_x[i].x
		end

		-- If current pixel is the beginning of scale area
		if scale_x[i].x == current_pixel then
			row = row + 1

			-- If first scale area and first scale area begins at 0 (no corner piece)
			if i == 1 and row == 1 then
				vertical(state, scale_x[i].x, scale_x[i].w, true, row, true)
			else
				vertical(state, scale_x[i].x, scale_x[i].w, true, row)
			end

			-- set current pixel to end of scale area
			current_pixel = scale_x[i].x + scale_x[i].w
		else
			error(string.format("The start of the horizontal line %d comes before another line finishes", i), 2)
		end
	end

	-- If current pixel is less than total size of image
	if current_pixel < state.dimensions.w then
		row = row + 1
		vertical(state, current_pixel, state.dimensions.w - current_pixel, false, row)
		state.static.x = state.static.x + state.dimensions.w - current_pixel
	end
end

-- Content Box (border - padding)
local function get_content_box(p, x, y, w, h, preprocessed)
	if not preprocessed then
		x, y = (x or 0), (y or 0)
		w = math.max((w or 0) - p.static.x, 0) + p.static.x
		h = math.max((h or 0) - p.static.y, 0) + p.static.y
	end

	return x + p.pad[4], y + p.pad[1], w - p.pad[2] - p.pad[4] + p.static.x, h - p.pad[1] - p.pad[3] + p.static.y
end
-- Border Box (content + padding)
local function get_border_box(p, x, y, w, h, preprocessed)
	if not preprocessed then
		x, y = (x or 0), (y or 0)
		w, h = (w or 0), (h or 0)
	end

	x, y, w, h = x - p.pad[4], y - p.pad[1], w + p.pad[2] + p.pad[4], h + p.pad[1] + p.pad[3]

	if not preprocessed then
		w = math.max(w - p.static.x, 0) + p.static.x
		h = math.max(h - p.static.y, 0) + p.static.x
	end
	return x, y, w, h
end

local function draw(p, x, y, w, h, content_box)
	local skip_update = false

	-- If all args match previous draw, no need to update the batch.
	if p.last_args then
		local ox, oy, ow, oh, ocontent_box = unpack(p.last_args)
		if x == ox and y == oy and w == ow and h == oh and content_box == ocontent_box then
			skip_update = true
		else
			p.last_args[1] = x
			p.last_args[2] = y
			p.last_args[3] = w
			p.last_args[4] = h
			p.last_args[5] = content_box
		end
	else
		p.last_args = { x, y, w, h, content_box }
	end

	-- Box Size
	x, y = (x or 0), (y or 0)
	w, h = (w or 0), (h or 0)

	if content_box then -- Content box model
		x, y, w, h = get_border_box(p, x, y, w, h, true)
	end

	w = math.max(w - p.static.x, 0)
	h = math.max(h - p.static.y, 0)

	-- Content Box
	local cx, cy, cw, ch = get_content_box(p, x, y, w, h, true)

	if not skip_update then
		-- Divide size by scale area
		local pax, pay = x, y
		local sax, say = w / p.dynamic.x, h / p.dynamic.y

		local row, col = 1, 1
		for i=1, #p.areas do
			if p.areas[i].row > row then
				row = p.areas[i].row
				pax = pax + p.areas[i - 1].w * (p.areas[i - 1].sx and sax or 1)
			end

			if p.areas[i].col > col then
				col = p.areas[i].col
				pay = pay + p.areas[i - 1].h * (p.areas[i - 1].sy and say or 1)
			elseif p.areas[i].col == 1 then
				col = p.areas[i].col
				pay = y
			end

			if p.areas[i].id then
				p.batch:set(p.areas[i].id, p.areas[i].quad, pax, pay, 0, p.areas[i].sx and sax or 1, p.areas[i].sy and say or 1)
			end
		end
	end

	love.graphics.draw(p.batch)

	if debug_draw then
		love.graphics.setColor(255, 0, 0, 255)
		love.graphics.rectangle("line", get_border_box(p, cx, cy, cw, ch)) --Fixes debug_draw drawing the box littler than how it was
		love.graphics.setColor(0, 255, 0, 255)
		love.graphics.rectangle("line", cx, cy, cw, ch)
		love.graphics.setColor(255, 255, 255, 255)
	end

	-- return content box for lazy people who don't want to call get_content_box again
	return cx, cy, cw, ch
end

local function dump (state, filename, save_image)
	--Dumb serialization
	local str = [[local metadata = function ()
	return {
		type = "9patch",
		areas = {]]

	for _, area in ipairs(state.areas) do
		str = str..[[

			{
				x   =	]]..tostring(area.x)..[[,
				y   =	]]..tostring(area.y)..[[,
				w   =	]]..tostring(area.w)..[[,
				h   =	]]..tostring(area.h)..[[,
				sx  =	]]..tostring(area.sx)..[[,
				sy  =	]]..tostring(area.sy)..[[,
				row =	]]..tostring(area.row)..[[,
				col =	]]..tostring(area.col)..[[,
			},]]
	end

	str = str:sub(1, -2) .. [[

		},
		dimensions = {w = ]] .. tostring(state.dimensions.w) .. ", h = ".. tostring(state.dimensions.h) .. [[},
		dynamic = {x = ]] .. tostring(state.dynamic.x) .. ", y = " .. tostring(state.dynamic.y) .. [[},
		static = {x = ]] .. tostring(state.static.x) .. ", y = ".. tostring(state.static.y) .. [[},
		pad = {]]

		for _, padding in ipairs(state.pad) do
			str = str .. tostring(padding) .. ","
		end

		str = str:sub(1, -2) .. [[}
	}
end

return metadata]]

	--Save the data in a file
	love.filesystem.write(filename or "", str or "")

	--Also save the image if required
	if save_image then
		local filename = (filename:match("(.-)%..-$") or "image")..".png" --Maybe this should be ".9.png" ?
		local data = state.image:getData()
		data:encode(filename)
	end

	return str
end

local function postprocess(state)
	if #state.areas < 1 then
		error("There are no areas in this patch", 2)
	else
		for _, area in ipairs(state.areas) do
			if area.w and area.w > 0 and area.h and area.h > 0 then
				area.quad = love.graphics.newQuad(area.x, area.y, area.w, area.h, state.dimensions.w, state.dimensions.h)
				area.id   = state.batch:add(area.quad)
			end
		end
	end

	state.draw				= draw
	state.get_border_box	= get_border_box
	state.get_content_box	= get_content_box
	state.dump				= dump

	return state
end

local function process(patch)
	local image = patch.image

	if not image then
		error("No images for this patch", 2)
	end

	local _w, _h = image:getDimensions()

	local state = {
		type       = "9patch",
		image      = image,
		batch      = patch.batch,
		pad        = patch.pad,
		scale_x    = patch.scale_x,
		scale_y    = patch.scale_y,
		areas      = {},
		static     = {x = 0, y = 0},
		dimensions = {w = _w, h = _h},
	}

	horizontal(state)

	state.dynamic = {
		x = state.dimensions.w - state.static.x,
		y = state.dimensions.h - state.static.y,
	}

	state.scale_x, state.scale_y = nil, nil

	return postprocess(state)
end

function patchy.load(img, metadata)
	-- *.9.png
	if type(img) == "string" then
		img  = love.graphics.newImage(img)
	end
	
	local data = img:getData()
	local w, h = img:getDimensions()

	local aw, ah  = img:getWidth()-2, img:getHeight()-2
	local asset = love.image.newImageData(aw, ah)

	asset:paste(data, 0, 0, 1, 1, aw, ah)

	local srgb = select(3, love.window.getMode()).srgb
	local image = love.graphics.newImage(asset, srgb and "srgb" or nil)

	if type(metadata) == "string" then
		metadata = love.filesystem.load(metadata)
		if not metadata then error("Invalid metadata file passed to 'import'",2) end
		metadata = metadata()
	end

	if type(metadata) == "function" then
		metadata = metadata()
	end

	if metadata and metadata.type == "9patch" then
		metadata.image = image
		return nine.import(image, metadata)
	end

	-- 9patch data
	local scale_x, scale_y = {{}}, {{}}
	local fill_x, fill_y   = {}, {}

	-- Scan horizontal rows for 9patch data
	for i=0, w - 1 do
		-- Top row, scale
		local r, g, b, a = data:getPixel(i, 0)

		-- If we are currently in a scale stream, check to see if we leave it (not black)
		if scale_x[#scale_x].x then
			if not scale_x[#scale_x].w and (r ~= 0 or g ~=0 or b ~= 0 or a ~= 255) then
				scale_x[#scale_x].w = (i - 1) - scale_x[#scale_x].x
			end
		else
			-- If we are not in a scale stream, check to see if we are starting one (black)
			if r == 0 and g == 0 and b == 0 and a == 255 then
				scale_x[#scale_x].x = i - 1
			end
		end

		-- Bottom row, fill
		local r, g, b, a = data:getPixel(i, h - 1)

		-- If we are in a fill stream, check to see if we leave it (not black)
		if fill_x.x then
			if not fill_x.w and (r ~= 0 or g ~= 0 or b ~= 0 or a ~= 255) then
				fill_x.w = (i - 1) - fill_x.x
			end
		else
			-- If we are not in a fill stream, check to see if we are starting one (black)
			if r == 0 and g == 0 and b == 0 and a == 255 then
				fill_x.x = i - 1
			end
		end

		-- stahp
		if scale_x[#scale_x].w then
			scale_x[#scale_x + 1] = {}
		end
	end

	-- if the last table is empty (stahp)
	if not scale_x[#scale_x].x then
		-- if there is only one table, no 9patch data
		if #scale_x == 1 then
			error("Invalid 9-patch image, it doesnt contain an horizontal line", 2)
		else
			scale_x[#scale_x] = nil
		end
	end

	-- staaaaahp
	if not scale_x[#scale_x].w then
		scale_x[#scale_x].w = (w - 1) - scale_x[#scale_x].x
	end

	--same as above, but for height!
	for i=0, h - 1 do
		local r, g, b, a = data:getPixel(0, i)

		if scale_y[#scale_y].y then
			if not scale_y.h and (r ~= 0 or g ~=0 or b ~= 0 or a ~= 255) then
				scale_y[#scale_y].h = (i - 1) - scale_y[#scale_y].y
			end
		else
			if r == 0 and g == 0 and b == 0 and a == 255 then
				scale_y[#scale_y].y = i - 1
			end
		end

		local r, g, b, a = data:getPixel(w - 1, i)

		if fill_y.y then
			if not fill_y.h and (r ~= 0 or g ~= 0 or b ~= 0 or a ~= 255) then
				fill_y.h = (i - 1) - fill_y.y
			end
		else
			if r == 0 and g == 0 and b == 0 and a == 255 then
				fill_y.y = i - 1
			end
		end

		if scale_y[#scale_y].h then
			scale_y[#scale_y + 1] = {}
		end
	end

	if not scale_y[#scale_y].y then
		if #scale_y == 1 then
			error("Invalid 9-patch image, it doesnt contain a vertical line",2)
		else
			scale_y[#scale_y] = nil
		end
	end

	if not scale_y[#scale_y].h then
		scale_y[#scale_y].h = (h - 1) - scale_y[#scale_y].y
	end

	-- maaaaath
	local scale_w = scale_x[#scale_x].x + scale_x[#scale_x].w - scale_x[1].x
	local scale_h = scale_y[#scale_y].y + scale_y[#scale_y].h - scale_y[1].y

	fill_x.w = fill_x.x and (fill_x.w and fill_x.w or (w - 1 - fill_x.x)) or scale_w
	fill_y.h = fill_y.y and (fill_y.h and fill_y.h or (h - 1 - fill_y.y)) or scale_h

	fill_x.x = fill_x.x and fill_x.x or scale_x[1].x
	fill_y.y = fill_y.y and fill_y.y or scale_y[1].y

	local pad = {
		- fill_y.y + scale_y[1].y,
		- (scale_x[1].x + scale_w) + (fill_x.x + fill_x.w),
		- (scale_y[1].y + scale_h) + (fill_y.y + fill_y.h),
		- fill_x.x + scale_x[1].x,
	}

	local patch = {
		image   = image,
		batch   = love.graphics.newSpriteBatch(image, (#scale_x * 2 + 1) * (#scale_y * 2 + 1)), 
		pad     = pad,
		scale_x = scale_x,
		scale_y = scale_y,
	}

	return process(patch)
end

function patchy.import (image, metadata)
	if type(metadata) == "string" then
		metadata = love.filesystem.load(metadata)
		if not metadata then error("Invalid metadata file passed to 'import'",2) end
		metadata = metadata()
	end

	if type(metadata) == "function" then
		metadata = metadata()
	end

	if type(metadata) ~= "table" then
		error("bad argument #2 to 'import' (table expected, got "..type(metadata)..")", 2)
	end
	-- *.9.png
	if type(image) == "string" then
		image  = love.graphics.newImage(image)
	end

	if not image or not image.type or image:type() ~= "Image" then
		error("bad argument #1 to 'import' (Image expected, got "..(image.type and image:type() or type(image))..")", 2)
	end

	metadata.image = image

	metadata.batch = love.graphics.newSpriteBatch(image, #metadata.areas)
	return postprocess(metadata)
end

return patchy