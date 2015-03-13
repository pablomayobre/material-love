--Based on Robin's roundrect.lua https://gist.github.com/gvx/9072860 all credits to him
return function (w,h,xr,yr,pre,t)
	local p,pre = {}, pre or xr + yr

	if xr > w * .5 then xr = w * .5 end
	if yr > h * .5 then yr = h * .5 end

	local hp,cos,sin = math.pi * .5, math.cos, math.sin

	local x2,y2 = w - xr, h - yr
	local xs = {true,true,false,false}
	local ys = {false,true,true,false}

	for i = 1, 4 do
		if t and not t[i] then
			p[#p + 1] = xs[i] and w or 0
			p[#p + 1] = ys[i] and h or 0
		else
			for j = 0, pre do
				local a = (j / pre + (i - 2))*hp
				p[#p + 1] = (xs[i] and x2 or xr) + xr * cos(a)
				p[#p + 1] = (ys[i] and y2 or yr) + yr * sin(a)
			end
		end
	end

	return function (x,y)
		local r = {}
		for i=1, #p do
			r[i] = p[i] + (i%2 == 0 and y or x)
		end
		return r
	end
end