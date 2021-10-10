local spinner = {}

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

spinner.new = function (r, width, speed, precision)
    return {
        time = 0,
        radius = r + (width or 1)/2,
        width = width or 1,
        speed = speed or 1,
        precision = precision or 100,
        polygon = {},
        update = spinner.update,
        draw = spinner.draw,
    }
end

local pi2 = math.pi * 2

spinner.update = function (self, dt)
    self.time = (self.time + (dt * self.speed)) % 1

    self.polygon = {}

    local rotation = self.time * 270

    local offset = self.radius * pi2
    local off4 = offset/4

    local dashoffset, plusrotate

    local d = 0.5
    if self.time > 0.5 then
        local t = self.time - d

        dashoffset = inOutQuad(t, off4, offset - off4, d)
        plusrotate = inOutQuad(t, 135,  450 - 135,     d)
    else
        local t = self.time

        dashoffset = inOutQuad(t, offset, off4 - offset, d)
        plusrotate = inOutQuad(t, 0, 135,  d)
    end

    rotation = ((rotation + plusrotate) * math.pi / 180) % pi2

    local start = rotation
    local finish = rotation + ((offset - dashoffset) / self.radius) + 0.25

    finish = finish < start and finish + pi2 or finish

    local a = pi2 / self.precision

    for i = 0, self.precision do
        local ang = start + (a * i)
        if ang < finish then
            self.polygon[#self.polygon + 1] = self.radius * math.cos(ang)
            self.polygon[#self.polygon + 1] = self.radius * math.sin(ang)
        end
    end
end

spinner.draw = function (self, x, y, r, sx, sy)
    love.graphics.push()

    love.graphics.translate(x, y)
    love.graphics.scale(sx, sy)
    love.graphics.rotate((r or 0) - math.pi/2)

    local _w = love.graphics.getLineWidth()
    love.graphics.setLineWidth(self.width)

    if self.polygon and #self.polygon > 4 and #self.polygon % 2 == 0 then
        love.graphics.line(unpack(self.polygon))
    end

    love.graphics.setLineWidth(_w)
    love.graphics.pop()
end

return spinner
