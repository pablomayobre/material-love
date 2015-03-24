local ripple = {}

local ease = function (time, ftime)
	local p = time / ftime
	local e = -p * (p - 2)
	return e
end

local lg = love.graphics

ripple.fade = function (self)
	if self.type == "stencil" then
		return self:fade()
	end

	if self.active then
		self.ripples[#self.ripples + 1] = self.active

		self.active = nil
	end
end

ripple.start = function (self, mx, my, r, g, b, a)
	if self.type == "stencil" then
		return self:start(mx, my)
	end

	local c

	if r and g and b and a then
		c = {r, g, b, a}
	end

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
		ease = 0,
		color = c
	}
end

ripple.update = function (self, dt)
	if self.type == "stencil" then
		return self:update(dt)
	end

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

			self.ripples[i].r = ease(self.ripples[i].time, self.ftime) * self.fr

			if self.ripples[i].time >= self.ftime then
				self.ripples[i].finished = true
			end
		end

		self.ripples[i].fade = self.ripples[i].fade + dt

		self.ripples[i].ease = ease(self.ripples[i].fade, self.ftime)

		if self.ripples[i].fade >= self.ftime then
			_remove[#_remove + 1] = i
		end
	end

	for i=1, #_remove do
		table.remove(self.ripples,_remove[i])
	end
end

ripple.draw = function (self,...)
	if self.type == "stencil" then
		return self:draw(...)
	end

	lg.setStencil(self.custom)

	local _r,_g,_b,_a = lg.getColor()
	
	if self.active then
		local r, g, b, a

		if self.active.color then
			r, g, b, a = unpack(self.active.color)
		else
			r, g, b, a = _r, _g, _b, _a
		end

		lg.setColor(r, g, b, a)

		if finished then
			self.custom()
		else
			lg.circle("fill", self.active.x, self.active.y, self.active.r)
		end
	end

	for i=1, #self.ripples do
		local r, g, b, a

		if self.ripples[i].color then
			r, g, b, a = unpack(self.ripples[i].color)
		else
			r, g, b, a = _r, _g, _b, _a
		end

		lg.setColor(r, g, b, a - a * self.ripples[i].ease)

		if finished then
			self.custom()
		else
			lg.circle("fill", self.ripples[i].x, self.ripples[i].y, self.ripples[i].r)
		end
	end

	lg.setColor(_r, _g, _b, _a)
	lg.setStencil()
end

ripple.custom = function (custom, fr, time)
	local self = {}

	self.ftime = time or 1
	
	self.custom = custom

	self.fr = fr

	self.ripples = {}

	self.start = ripple.start
	self.fade = ripple.fade

	self.update = ripple.update
	self.draw = ripple.draw

	self.type = "custom"

	return self
end

ripple.box = function (x, y, w, h, time)
	local self = ripple.custom(function() end, 0, time)

	self.box = {x = box.x, y = box.y, w = box.w, h = box.h}

	self.custom = function ()
		lg.rectangle("fill", self.box.x, self.box.y, self.box.w, self.box.h)
		lg.rectangle("line", self.box.x, self.box.y, self.box.w, self.box.h)
	end

	self.fr = (self.box.w * self.box.w + self.box.h * self.box.h) ^ 0.5
	self.type = "box"

	return self
end

ripple.circle = function (x, y, ra, time)
	local self = ripple.custom(function() end, 0, time)

	self.circle = {x = x, y = y, r = ra}

	self.custom = function ()
		lg.circle("fill", self.circle.x, self.circle.y, self.circle.r)
		lg.circle("line", self.circle.x, self.circle.y, self.circle.r)
	end

	self.fr = ra * 2
	self.type = "circle"

	return self
end

ripple.stencil = function (x, y, w, h, time)
	return {
		type = "stencil",
		x = x, y = y,
		w = w, h = h,
		ft = time or 1,

		update = function () end,

		draw = function (self, fun)
			if self.active then
				love.graphics.setStencil(self.stencil)
				fun()
				love.graphics.setStencil()
			elseif self.finish then
				fun()
			end
		end,

		start = function (self, x, y, collapse)
			local xw,yh = x - self.x, y - self.y
			local w = math.max(self.w - (xw), xw)
			local h = math.max(self.h - (yh), yh)
			local ra = (h * h + w * w) ^ 0.5

			self.time = 0
			self.active = true
			self.finish = false

			self.update = function (self, dt)
				self.time = self.time + dt

				local r = ra * ease(self.time, self.ft)
				r = collapse and ra - r or r

				self.stencil = function ()
					love.graphics.circle("fill", x, y, r)
				end

				if self.ft < self.time then
					self.active = false
					self.finish = not collapse
					self.update = function () end
				end
			end
		end,

		fade = function (self)
			self:start(self.x + self.w/2, self.y + self.h/2, true)
		end,
	}
end

return ripple