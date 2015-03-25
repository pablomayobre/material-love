io.stdout:setvbuf("no")

local m
local lw,lg = love.window,love.graphics
local li = love.image.newImageData
local w, h, ps

local AppBar, Card, Circle, Back, Accept, Cancel, Toast

local click, i, cursor, hover, hf

local Collisions = {
	circle = function (x,y,c,f,e)
		local f = f or function () end
		local e = e or function () end

		if (x - c.x)^2 + (y - c.y)^2 < c.r ^ 2 then
			f(x,y,c)
		else
			e(x,y,c)
		end
	end,

	box = function (x,y,b,t,f,e)
		local f = f or function () end
		local e = e or function () end

		local t = t or {}
		if 	x > b.x - (t[1] or 0) and
			y > b.y - (t[2] or 0) and
			x < (b.x + b.w) + (t[3] or 0) and
			y < (b.y + b.h) + (t[4] or 0) then

			f(x,y,b,t)
		else
			e(x,y,b,t)
		end
	end
}

love.load = function ()
	local a = love.timer.getTime()
	m = require "material-love"
	local b = love.timer.getTime()

	print (b - a)

	-- i = lg.newImage("material-love/images/nine-patch.png")
	-- m.nine.convert(i, "shadow",true)

	-- require "styletolua" ("style.css")
	-- love.system.openURl ("file://"..love.filesystem.getSaveDirectory())

	-- lw.setMode(400, 400)
	-- lw.setTitle("Material - Love")
	-- lw.setIcon(li("material-love/images/icon64.png"))

	-- cursor = {
		-- love.mouse.getCursor(),
		-- love.mouse.getSystemCursor("hand"),
	-- }
	-- hf = function () hover = true end

	lg.setBackgroundColor(m.colors.background("light"))

	w,h = lg.getDimensions()
	ps  = lw.getPixelScale()

	AppBar = {x = 0, y = 0, w = w, h = 48 * ps}

	Circle = m.ripple.circle(48 * ps, h - 48 * ps, 20 * ps--[[, m.colors("red","A200")]])
	Circle.circle.ty = Circle.circle.y

	Back = m.ripple.circle(26 * ps, AppBar.h/2, 16 * ps--[[, m.colors("cyan","200")]])

	Card = {x = 16 * ps, y = AppBar.h + 16 * ps, w = w - 32 * ps}
	Card.h = Circle.circle.y - 8 * ps - Card.y
	Card.p = m.roundrect(Card.x,Card.y,Card.w,Card.h,2,2)

	Accept = {y = Card.y + Card.h - 50 * ps, h = 36 * ps, text = "AGREE"}
	Accept.w = m.roboto.button:getWidth(Accept.text) + 16
	Accept.x = Card.x + Card.w - 16 * ps - Accept.w
	Accept.p = m.roundrect(Accept.x, Accept.y, Accept.w, Accept.h, 2, 2)
	Accept.ripple = m.ripple.custom(function()
		lg.polygon("fill", unpack(Accept.p))
		lg.polygon("line", unpack(Accept.p))
	end, (Accept.w * Accept.w + Accept.h * Accept.h)^0.5--[[, m.colors("grey", "400")]])

	Cancel = {y = Accept.y,h = Accept.h, text = "DISAGREE"}
	Cancel.w = m.roboto.button:getWidth(Cancel.text) + 16
	Cancel.x = Accept.x - 8 * ps - Cancel.w
	Cancel.p = m.roundrect(Cancel.x, Accept.y, Cancel.w, Accept.h, 2, 2)
	Cancel.ripple = m.ripple.custom(function()
		lg.polygon("fill",unpack(Cancel.p))
		lg.polygon("line",unpack(Cancel.p))
	end, (Cancel.w * Cancel.w + Cancel.h * Cancel.h)^0.5--[[, m.colors("grey", "400")]])

	Toast = {
		text = "",
		fh = 48 * ps,
		h = 0,
		t = 0,
		inside = false,
		out = true,
		nupdate = function (Toast,dt)
			Toast.t = Toast.t + dt
			local p = Toast.t/0.5
			Toast.h = Toast.fh * (-p * (p - 2))

			if Toast.t > 0.5 then
				Toast.update = function () end
			end
		end
	}
end

love.update = function (dt)
	-- hover = false
	-- local x,y = love.mouse.getPosition()

	-- Collisions.box(x, y, Accept, {0,6 * ps, 0, 6 * ps}, hf)
	-- Collisions.box(x, y, Cancel, {0,6 * ps, 0, 6 * ps}, hf)
	-- Collisions.circle (x, y, Circle.circle, hf)
	-- Collisions.circle (x, y, Back.circle, hf)

	-- if hover then
		-- love.mouse.setCursor(cursor[2])
	-- else
		-- love.mouse.setCursor(cursor[1])
	-- end

	if not Toast.out then
		Toast:update(dt)
	end

	Circle:update(dt)
	Back:update(dt)
	Accept.ripple:update(dt)
	Cancel.ripple:update(dt)

	Circle.circle.y = Circle.circle.ty - (Toast.h > 14 and Toast.h - 14 or 0)
end

love.draw = function ()
	lg.setColor(m.colors "white")
	m.shadow.draw(Card.x, Card.y, Card.w, Card.h, false, false, 3)
	lg.polygon("fill", unpack(Card.p))
	lg.polygon("line", unpack(Card.p))

	lg.setColor(m.colors.mono("black", "subhead"))
	lg.setFont(m.roboto "subhead")
	lg.printf("Implementing the material-design spec in LOVE", Card.x + 16 * ps, Card.y + 16 * ps, Card.w - 32 * ps)
	lg.setColor(m.colors.mono("black", "divider"))
	lg.line(Card.x + 16 * ps, Card.y + 40 * ps, Card.x + Card.w - 16 * ps, Card.y + 40 * ps)
	lg.setColor(m.colors.mono("black", "body"))
	lg.setFont(m.roboto "body1")
	lg.printf([[Material-love provides functions to easily recreate the material-design functionalities in Love, such as ripples and shadows.
	Go to the repo by clicking the heart or close this form with the back arrow in the AppBar. You can also open the toasts by clicking any of the two buttons in the bottom of the card.
	
	PS: Enjoy the ripples!]], Card.x + 16 * ps, Card.y + 48 * ps, Card.w - 32 * ps)

	lg.setColor(m.colors("grey", "400"))
	Accept.ripple:draw()
	Cancel.ripple:draw()

	lg.setColor(m.colors "blue")
	lg.setFont(m.roboto.button)
	lg.printf(Cancel.text, Cancel.x, Cancel.y + 10 * ps, Cancel.w, "center")
	lg.printf(Accept.text, Accept.x, Accept.y + 10 * ps, Accept.w, "center")

	m.shadow.draw(AppBar.x, AppBar.y, AppBar.w, AppBar.h, false, false, 2)
	lg.setColor(m.colors "cyan")
	lg.rectangle("fill", AppBar.x, AppBar.y, AppBar.w, AppBar.h)
	lg.rectangle("line", AppBar.x, AppBar.y, AppBar.w, AppBar.h)
	Back:draw()
	m.icons.draw ("arrow-left", Back.circle.x, Back.circle.y)

	lg.setColor(m.colors.mono("white", "title"))
	lg.setFont(m.roboto "title")
	lg.printf("Material - Love", AppBar.x, AppBar.y + 14 * ps, AppBar.w, "center")

	lg.setColor(m.colors "red")
	m.fab(Circle.circle.x, Circle.circle.y, "mini", 3)
	Circle:draw()
	m.icons.draw ("heart", Circle.circle.x, Circle.circle.y)

	lg.setColor(m.colors("grey", "800"))
	lg.rectangle("fill", 0, h - Toast.h, w, Toast.h)
	lg.setColor(m.colors.mono("white", "secondary-text"))
	lg.setFont(m.roboto "body2")
	lg.print(Toast.text, 24 * ps, h - Toast.h + 16 * ps)
end

love.keypressed = function (k)
	if k == "escape" then
		love.event.quit()
	end
end

love.mousepressed = function (x,y,b)
	if Toast.inside then
		Toast.inside = false
		Toast.t = 0
		Toast.update = function (Toast, dt)
			Toast.t = Toast.t + dt
			local p = Toast.t/0.5
			Toast.h = Toast.fh - Toast.fh * (-p * (p - 2))

			if Toast.t > 0.5 then
				Toast.out = true
			end
		end
	end

	Collisions.box(x, y, Accept, {0,6 * ps, 0, 6 * ps}, function ()
		Accept.ripple:start(x, y)
		Toast.h = 0
		Toast.inside = true
		Toast.t = 0
		Toast.out = false
		Toast.update = Toast.nupdate
		Toast.text = "Thanks mate!"
	end)

	Collisions.box(x, y, Cancel, {0,6 * ps, 0, 6 * ps}, function ()
		Cancel.ripple:start(x, y)
		Toast.h = 0
		Toast.inside = true
		Toast.t = 0
		Toast.out = false
		Toast.update = Toast.nupdate
		Toast.text = "You shall OBEY!"
	end)

	Collisions.circle (x, y, Circle.circle,function ()
		Circle:start(x, y, m.colors("red","A200"))
		if b == "l" then
			love.system.openURL("https://www.github.com/Positive07/material-love/")
		end
	end)

	Collisions.circle (x, y, Back.circle, function ()
		Back:start(x, y, m.colors("cyan","200"))
		if b == "l" then
			click = true
		end
	end)
end

love.mousereleased = function (x,y,b)
	Accept.ripple:fade()
	Cancel.ripple:fade()
	Back:fade()
	Circle:fade()

	if click then love.event.quit() end
end