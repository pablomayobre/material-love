local calc = {}

calc.cor = function (cor,x,y,w,h,i) --Corner
	--Calculate position
	local x = (i == 1 or i == 4) and -cor.w or w
	local y = i < 3 and -cor.h or h
	return x,y
end

calc.bor = function (bor,x,y,w,h,i) --Border
	--Calculate scale
	local sx = ((i % 2) == 0) and 1 or w/bor.w
	local sy = ((i % 2) == 1) and 1 or h/bor.h
	--Calculate position
	local x = (i % 2) == 1 and 0 or (i == 2 and w or -bor.w)
	local y = (i % 2) == 0 and 0 or (i == 3 and h or -bor.h)

	return x,y,sx,sy
end

local nine = {}

function nine.draw(p,x,y,w,h,center,pad,img)
	--p = Patch pattern already processed with nine.process
	--x,y = The x and y position where the patch will be drawn
	--w,h = The width and height of the content
	--center = a boolean to know if the center should be drawn or not
	--pad = Whether padding should be taken into account
	--img = The asset that will be used for rendering, should be a valid asset for the patch

	local img = img or p.default --Use the default image if non is specified

	if not p.assets[img] then --The image doesnt exist in this patch, error
		error (img.." is not a valid asset for this patch",2)
	end

	--Shortcuts
	local d = love.graphics.draw
	local x,y,w,h,_ox,_oy,_ow,_oh = x,y,w,h,x,y,w,h

	if pad then --Apply paddings
		x,y,w,h = x - p.pad[4], y - p.pad[1], w + p.pad[2] + p.pad[4], h + p.pad[1] + p.pad[3]
	end

	for i = 1, 4 do --Four corners, four borders
		if p.cor[i].quad then --If there is a quad for this corner
			local dx,dy = calc.cor(p.cor[i],x,y,w,h,i) --Calculate the position
			d(p.assets[img], p.cor[i].quad, x + dx, y + dy) --Draw the corner
		end

		if p.bor[i].quad then --If there is a quad for this border
			local dx,dy,sx,sy = calc.bor(p.bor[i],x,y,w,h,i) --Calculate the position and scale		
			d(p.assets[img], p.bor[i].quad, x + dx, y + dy, 0, sx, sy) --Draw the border
		end
	end

	if center and p.center then --If the center must be drawn and there is a center
		d(p.assets[img], p.center, _ox, _oy, 0, _ow/p.w, _oh/p.h) --Draw it
	end
end

function nine.process (patch)
	--patch is a valid patch table (described in the example shadow.lua)

	local assets, default = {}
	if patch.multiimage then --More than one asset for this patch
		if not type(patch.image)=="table" then --They need to be in a table
			error("This patch specifies multi-image but doesnt hold a table",2)
		end

		local i = 0
		for k,v in pairs(patch.image) do --Look through the table
			i = i + 1

			if k ~= "default" then --Except for the default value turn them into images
				assets[k] = love.graphics.newImage(v)
			end
		end
		--There should be the default value and an image at least
		if i < 2 then error("No images for this patch",2) end
		
		default = patch.image.default --Save the default
		if not assets[default] then --Check that the default exists
			error("The default image for this patch could not be found",2)
		end
	else
		if not type(patch.image)=="string" then --Not multi-image so there should be a single string
			error("The value for the image of this patch is not valid",2)
		end
		assets[1] = love.graphics.newImage(patch.image)
		default = 1
	end

	local _w, _h = assets[default]:getDimensions() --Save the dimensions
	local _xw, _yh = patch.hor.x + patch.hor.w, patch.ver.y + patch.ver.h --Save the other point in the rectangle
	local _wc, _hc = _w - _xw, _h - _yh --corner bottom and right width and height

	local cor = { --This are the x,y,w and h for each corner
		{ x = 0,	y = 0,		w = patch.hor.x,	h = patch.ver.y	},
		{ x = _xw,	y = 0,		w = _wc,			h = patch.ver.y	},
		{ x = _xw,	y = _yh,	w = _wc,			h = _hc			},
		{ x = 0,	y = _yh,	w = patch.hor.x,	h = _hc			}
	}

	local bor = { --The x,y,w and h for each border
		{ x = patch.hor.x,	y = 0,				w = patch.hor.w,	h = patch.ver.y	},
		{ x = _xw,			y = patch.ver.y,	w = _wc,			h = patch.ver.h	},
		{ x = patch.hor.x,	y = _yh,			w = patch.hor.w,	h = _hc			},
		{ x = 0,			y = patch.ver.y,	w = patch.hor.x,	h = patch.ver.h	}
	}

	for i=1, 4 do --Four corners, four borders
		if cor[i].w > 0 and cor[i].h > 0 then --If width or height is less than cero lg.newQuad errors
			--Save the quad
			cor[i].quad = love.graphics.newQuad(cor[i].x, cor[i].y, cor[i].w, cor[i].h, _w, _h)
		end
		--Same for borders
		if bor[i].w > 0 and bor[i].h > 0 then
			bor[i].quad = love.graphics.newQuad(bor[i].x, bor[i].y, bor[i].w, bor[i].h, _w, _h)
		end
	end

	local center
	if patch.ver.h > 0 and patch.hor.w > 0 then --Saving the center as a quad
		center = love.graphics.newQuad(patch.hor.x, patch.ver.y, patch.hor.w, patch.ver.h, _w, _h)
	end
	
	return { --Put everything in a table and return it
		assets = assets, --The images generated
		default = default, --The default image to use
		bor = bor, --The borders (quads and data)
		cor = cor, --The corners (quads and data)
		pad = patch.pad, --The paddings as specified in the patch
		center = center, --The center quad
		w = patch.hor.w, --The center width
		h = patch.ver.h, --The center height
		draw = nine.draw, --The Draw method
	}
end

function nine.convert(img) -- WORK IN PROGRESS
	local idata = img:getData()
	
	local hor,ver = {},{}

	for i=0, img:getWidth() - 1 do
		local r,g,b,a = idata:getPixel(i,0)
		
		if hor.x then
			if r ~= 0 or g ~=0 or b ~= 0 or a ~= 255 then
				hor.w = (i - 1) - hor.x
				break
			end
		else
			if r == 0 and g == 0 and b == 0 and a == 255 then
				hor.x = i - 1
			end
		end
	end
	
	for i=0, img:getHeight() - 1 do
		local r,g,b,a = idata:getPixel(0,i)

		if ver.y then
			if r ~= 0 or g ~=0 or b ~= 0 or a ~= 255 then
				ver.h = (i - 1) - ver.y
				break
			end
		else
			if r == 0 and g == 0 and b == 0 and a == 255 then
				ver.y = i - 1
			end
		end
	end

	local w,h = img:getWidth()-2, img:getHeight()-2
	local asset = love.graphics.newImageData(w,h):paste(idata,1,1,w,h)

	local str = [[local a = ...

return {
	image = a:gsub("%.","%/")..".png",
	hor = {x = ]]..hor.x..",w = "..hor.w..[[},
	ver = {y = ]]..ver.y..",h = "..ver.h..[[},
	pad = {0,0,0,0}, --Top, Right, Bottom, Left
}]]

	return str,asset
end

return nine