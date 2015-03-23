local image = {}

local hsvShader
local supported = love.graphics.isSupported ("shader")

if supported then
	hsvShader = love.graphics.newShader[[
		vec3 rgb2hsv(vec3 c)
		{
			vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
			vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
			vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
			float d = q.x - min(q.w, q.y);
			float e = 1.0e-10;
			return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
		}

		vec3 hsv2rgb(vec3 c)
		{
			vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
			vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
			return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
		}

		extern number sMod;
		extern number vMod;
		extern number opacity;

		vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
			vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
			vec3 hsv = rgb2hsv(pixel.rgb);
			hsv.r *= 1.0;
			hsv.g *= sMod;
			hsv.b *= vMod;
			pixel = vec4(hsv2rgb(hsv).rgb, pixel.a * opacity);
			return pixel * color;
		}
	]]
end

-- Copied from github.com/EmmanuelOga/easing
-- This function was contributed by Kikito
local inOutQuad = function(t, b, c, d)
	t = math.min(math.max(t, 0), 1)
	t = t / d * 2
	if t < 1 then
		return c / 2 * t^2 + b
	else
		return -c / 2 * ((t - 1) * (t - 3) - 1) + b
	end
end

function image.new (img)
	return {
		image = img,
		time = 0,
		update = function (self,dt)
			self.time = math.min(self.time + dt, 1)
		end,
		draw = function (self, x, y, ra, sx, sy)
			image.draw(self.image, self.time, x, y, ra, sx, sy)
		end,
	}
end

function image.draw(img, time, x, y, ra, sx, sy)
	local r,g,b,a = love.graphics.getColor()
	
	local opacity = inOutQuad(time,  0, 1, 1)

	if supported then
		hsvShader:send("sMod", inOutQuad(time * 2, 0, 1, 1))
		hsvShader:send("vMod", inOutQuad(time * 2, 0, 1, 1))
		hsvShader:send("opacity", opacity)

		love.graphics.setShader(hsvShader)
	else --Fuck you Intel GMA 3100 combined with Windows!
		love.graphics.setColor(r, g, b, a * opacity)
	end

	love.graphics.draw(img, x, y, ra, sx, sy)
	
	if supported then
		love.graphics.setShader()
	else
		love.graphics.setColor(r, g, b, a)
	end
end

return draw