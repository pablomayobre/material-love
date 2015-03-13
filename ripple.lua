local ripple = {}

ripple.fade = function (self)
	if self.active then
		self.ripples[#self.ripples + 1] = self.active
		self.ripples[#self.ripples].fade = 0

		self.active = nil
	end
end

ripple.start = function (self,mx,my)
	if self.active then
		self:fade()
	end

	self.active = {
		r = 0,
		t = 0,
		x = mx,
		y = my,
		finished = false,
		fade = 0,
		alpha = self.color[4]
	}
end

local ease = function (t,ft)
	local p = t/ft
	local e = -p * (p - 2)
	return e
end

ripple.update = function (self,dt)
	if self.active and not self.active.finished then
		self.active.t = self.active.t + dt

		self.active.r = ease(self.active.t, self.ft) * self.fr

		if self.active.t >= self.ft then
			self.active.finished = true
		end
	end

	local _remove = {}

	for i=1, #self.ripples do
		if not self.ripples[i].finished then
			self.ripples[i].t = self.ripples[i].t + dt

			self.ripples[i].r = ease(self.ripples[i].t,self.ft) * self.fr

			if self.ripples[i].t >= self.ft then
				self.ripples[i].finished = true
			end
		end

		self.ripples[i].fade = self.ripples[i].fade + dt

		self.ripples[i].alpha = (self.color[4] or 255) - (self.color[4] or 255) * ease(self.ripples[i].fade,self.ft)

		if self.ripples[i].fade >= self.ft then
			_remove[#_remove + 1] = i
		end
	end

	for i=1, #_remove do
		table.remove(self.ripples,_remove[i])
	end
end

ripple.drawbox = function (self,scissor)
	local x1, y1, w1, h1 = self.box.x, self.box.y, self.box.w, self.box.h

	if scissor then
		local x2, y2, w2, h2 = love.graphics.getScissor()

		if x2 and y2 and w2 and h2 and (w2 < love.graphics.getWidth() or h2 < love.graphics.getWidth()) then
			xL, yT = math.max(x1,x2),math.max(y1,y2)
			xR, yB = math.min(x1 + w1,x2 + w2),math.min(y1 + h1,y2 + h2)

			if xL >= xR or yT >= yB then return else
				x1, y1, w1, h1 = xL, yB, xR-xL, yB-yT
			end
		end
	end

	love.graphics.setScissor(x1,y1,w1,h1)

	local _r,_g,_b,_a = love.graphics.getColor()
	local r,g,b = self.color[1], self.color[2], self.color[3]
	
	if self.active then
		love.graphics.setColor(r,g,b,self.active.alpha)

		if finished then
			love.graphics.rectangle("fill",x1,y1,w1,h1)
		else
			love.graphics.circle("fill",self.active.x, self.active.y, self.active.r)
		end
	end

	for i=1, #self.ripples do
		love.graphics.setColor(r,g,b,self.ripples[i].alpha)

		if finished then
			love.graphics.rectangle("fill",x1,y1,w1,h1)
		else
			love.graphics.circle("fill",self.ripples[i].x, self.ripples[i].y, self.ripples[i].r)
		end
	end

	love.graphics.setColor(_r,_g,_b,_a)
	love.graphics.setScissor()
end

ripple.drawcustom = function (self)
	love.graphics.setStencil(self.custom)

	local _r,_g,_b,_a = love.graphics.getColor()
	local r,g,b = self.color[1], self.color[2], self.color[3]
	
	if self.active then
		love.graphics.setColor(r,g,b,self.active.alpha)

		if finished then
			self.custom()
		else
			love.graphics.circle("fill",self.active.x, self.active.y, self.active.r)
		end
	end

	for i=1, #self.ripples do
		love.graphics.setColor(r,g,b,self.ripples[i].alpha)

		if finished then
			self.custom()
		else
			love.graphics.circle("fill",self.ripples[i].x, self.ripples[i].y, self.ripples[i].r)
		end
	end

	love.graphics.setColor(_r,_g,_b,_a)
	love.graphics.setStencil()
end

ripple.box = function (box,color,tim)
	local self = {}

	self.box = {x = box.x, y = box.y, w = box.w, h = box.h}
	self.color = {color[1],color[2],color[3],color[4] or 255}

	self.ft = tim or 1

	self.fr = (box.w * box.w + box.h * box.h)^0.5

	self.ripples = {}

	self.start = ripple.start
	self.fade = ripple.fade

	self.update = ripple.update
	self.draw = ripple.drawbox

	return self
end

ripple.custom = function (custom,fr,color,tim)
	local self = {}

	self.color = {color[1],color[2],color[3],color[4] or 255}

	self.ft = tim or 1
	
	self.custom = custom

	self.fr = fr

	self.ripples = {}

	self.start = ripple.start
	self.fade = ripple.fade

	self.update = ripple.update
	self.draw = ripple.drawcustom

	return self
end

ripple.circle = function (circle,color,tim)
	local self = ripple.custom(function()end,0,color,tim)

	self.circle = {x = circle.x, y = circle.y, r = circle.r}

	self.custom = function () love.graphics.circle("fill",self.circle.x, self.circle.y, self.circle.r) end

	self.fr = circle.r * 2

	return self
end

return ripple