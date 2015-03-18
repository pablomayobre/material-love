local ripple = {}

local ease = function (time,ftime)
	local p = time/ftime
	local e = -p * (p - 2)
	return e
end

local lg = love.graphics

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
		time = 0,
		x = mx,
		y = my,
		finished = false,
		fade = 0,
		alpha = self.color[4]
	}
end

ripple.update = function (self,dt)
	if self.active and not self.active.finished then
		self.active.time = self.active.time + dt

		self.active.r = ease(self.active.time, self.ftime) * self.fr

		if self.active.time >= self.ftime then
			self.active.finished = true
		end
	end

	local _remove = {}

	for i=1, #self.ripples do
		if not self.ripples[i].finished then
			self.ripples[i].time = self.ripples[i].time + dt

			self.ripples[i].r = ease(self.ripples[i].time,self.ftime) * self.fr

			if self.ripples[i].time >= self.ftime then
				self.ripples[i].finished = true
			end
		end

		self.ripples[i].fade = self.ripples[i].fade + dt

		self.ripples[i].alpha = (self.color[4] or 255) - (self.color[4] or 255) * ease(self.ripples[i].fade,self.ftime)

		if self.ripples[i].fade >= self.ftime then
			_remove[#_remove + 1] = i
		end
	end

	for i=1, #_remove do
		table.remove(self.ripples,_remove[i])
	end
end

ripple.draw = function (self)
	lg.setStencil(self.custom)

	local _r,_g,_b,_a = lg.getColor()
	local r,g,b = self.color[1], self.color[2], self.color[3]
	
	if self.active then
		lg.setColor(r,g,b,self.active.alpha)

		if finished then
			self.custom()
		else
			lg.circle("fill",self.active.x, self.active.y, self.active.r)
		end
	end

	for i=1, #self.ripples do
		lg.setColor(r,g,b,self.ripples[i].alpha)

		if finished then
			self.custom()
		else
			lg.circle("fill",self.ripples[i].x, self.ripples[i].y, self.ripples[i].r)
		end
	end

	lg.setColor(_r,_g,_b,_a)
	lg.setStencil()
end

ripple.custom = function (custom,fr,r,g,b,a,time)
	local self = {}

	self.color = {r,g,b,a or 255}

	self.ftime = time or 1
	
	self.custom = custom

	self.fr = fr

	self.ripples = {}

	self.start = ripple.start
	self.fade = ripple.fade

	self.update = ripple.update
	self.draw = ripple.draw

	return self
end

ripple.box = function (x,y,w,h,r,g,b,a,time)
	local self = ripple.custom(function() end, 0, r, g, b, a, time)

	self.box = {x = box.x, y = box.y, w = box.w, h = box.h}

	self.custom = function ()
		lg.rectangle("fill", self.box.x, self.box.y, self.box.w, self.box.h)
		lg.rectangle("line", self.box.x, self.box.y, self.box.w, self.box.h)
	end

	self.fr = (self.box.w * self.box.w + self.box.h * self.box.h) ^ 0.5

	return self
end

ripple.circle = function (x,y,ra,r,g,b,a,time)
	local self = ripple.custom(function() end, 0, r, g, b, a, time)

	self.circle = {x = x, y = y, r = ra}

	self.custom = function ()
		lg.circle("fill", self.circle.x, self.circle.y, self.circle.r)
		lg.circle("line", self.circle.x, self.circle.y, self.circle.r)
	end

	self.fr = ra * 2

	return self
end

return ripple