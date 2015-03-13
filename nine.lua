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

local nine = {}

function nine.draw(p,x,y,w,h,center,pad,img)
	local img = img or p.default

	if not p.assets[img] then error (img.." is not a valid asset for this patch",2) end

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
		if not type(patch.image)=="table" then error("This patch specifies multi-image but doesnt hold a table",2) end
		
		local i = 0
		for k,v in pairs(patch.image) do
			i = i + 1

			if k ~= "default" then
				assets[k] = love.graphics.newImage(v)
			end
		end
		
		if i < 1 then error("No images for this patch",2) end
		
		default = patch.image.default
		if not assets[default] then error("The default image for this patch could not be found",2) end
	else
		if not type(patch.image)=="string" then error("The value for the image of this patch is not valid",2) end
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

function nine.convert(img)
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