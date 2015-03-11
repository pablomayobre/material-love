local ripple = {}

ripple.update = function (self, dt)
	if self.t > self.ft and not self.hide then 
		self.hide = true
	end
	
	if not self.hide then
		self.t = self.t + dt
		local p = self.t/self.ft
		local e = -p * (p - 2)

		self.r = e * self.fr
		self.color[4] = self.scolor[4] - self.scolor[4] * e
	end
end

local ri = function (x1,y1,w1,h1, x2,y2,w2,h2)
	local rect = {
		{x1,y1,x1+w1,y1+h1},
		{x2,y2,x2+w2,y2+h2}
	}

	xL, yT = math.max(rect[1][1],rect[2][1]),math.max(rect[1][2],rect[2][2])
	xR, yB = math.min(rect[1][3],rect[2][3]),math.min(rect[1][4],rect[2][4])

	if xL >= xR or yT >= yB then return else
		return xL, yB, xR-xL, yB-yT
	end
end

ripple.draw = function (self)
	if not self.hide then
		if self.box then
			local x1,y1,w1,h1 = self.box.x,self.box.y,self.box.w,self.box.h
			local x2,y2,w2,h2 = love.graphics.getScissor()
			if (w2 and w2 < love.graphics.getWidth()) or (h2 and h2 < love.graphics.getHeight()) then
				x1,y1,w1,h1 = ri(x1,y1,w1,h1, x2,y2,w2,h2)
			end
			love.graphics.setScissor(x1,y1,w1,h1)
		elseif self.circle then
			love.graphics.setStencil(function()
				love.graphics.circle("fill",self.circle.x, self.circle.y, self.circle.r)
			end)
		end
		local r,g,b,a = love.graphics.getColor()
		love.graphics.setColor(self.color)
		love.graphics.circle("fill",self.x,self.y,self.r)
		love.graphics.setColor(r,g,b,a)
		if self.box then
			love.graphics.setScissor()
		elseif self.circle then
			love.graphics.setStencil()
		end
	end
end

ripple.new = function (typ, x,y,w,h, mx,my, color)
	local self = {}

	self.scolor = {color[1],color[2],color[3],color[4]}
	self.color = {color[1],color[2],color[3],color[4]}

	if typ == "box" then
		self.box = {x = x, y = y, w = w, h = h}
	elseif typ == "circle" then
		self.circle = {x = x, y = y, r = w}
		mx,my,color = h, mx, my
	else
		error("The type passed to ripple.new is not defined", 1)
	end

	self.x, self.y = mx, my

	self.r = 0
	self.t = 0

	self.ft = 1
	self.fr = (w * w + h * h)^0.5 * 2.5

	self.draw = function (...) ripple.draw(...) end
	self.update = function (...) ripple.update(...) end

	self.hide = false

	return self
end

return ripple