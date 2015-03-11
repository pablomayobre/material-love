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

function nine.process (patch)	
	local asset
	if patch.cut then --Super Heavy Load (Better not use cut)
		local d = love.graphics.newImageData(patch.image)
		local w,h = _dumm:getWidth()-2, _dumm:getHeight()-2
		asset = love.graphics.newImage(love.graphics.newImageData(w,h):paste(d,1,1,w,h))
	else
		asset = love.graphics.newImage(patch.image)
	end

	local _w, _h = asset:getDimensions()
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

	return {image = asset, bor = bor, cor = cor, pad = patch.pad, center = center, w = patch.hor.w, h = patch.ver.h}
end

function nine.draw(x,y,w,h,p,center,pad)
	local d = love.graphics.draw

	local x,y,w,h = x,y,w,h

	if pad then
		x,y,w,h = x - p.pad[4], y - p.pad[1], w + p.pad[2] + p.pad[4], h + p.pad[1] + p.pad[3]
	end

	for i = 1, 4 do
		if p.cor[i].quad then
			local dx,dy = calc.cor(p.cor[i],x,y,w,h,i)			
			d(p.image, p.cor[i].quad, x + dx, y + dy)
		end

		if p.bor[i].quad then
			local dx,dy,sx,sy = calc.bor(p.bor[i],x,y,w,h,i)			
			d(p.image, p.bor[i].quad, x + dx, y + dy, 0, sx, sy)
		end
	end

	if center and p.center then
		d(p.image, p.center, x, y, 0, w/p.w, h/p.h)
	end
end

function nine.convert(img)
end

return nine