--Based on Robin's roundrect.lua https://gist.github.com/gvx/9072860 all credits to him
return function (w,h,xr,yr,pre,t)
	--w = The width of the rectangle
	--h = The height of the rectangle
	--xr = The radius in the x axis
	--yr = The radius in the y axis, defaults to xr
	--pre = The precision of the angles, default to the sum of xr + yr
	--t = a table specifying which corners should be rounded (top-right, bottom-right, bottom-left, top-left)
	local yr = yr or xr
	local p,pre = {}, pre or xr + yr
	--Make the radius in the x axis dont exceed half of the width, same in the y axis
	if xr > w * .5 then xr = w * .5 end
	if yr > h * .5 then yr = h * .5 end
	--Store commonly used vars
	local hp,cos,sin = math.pi * .5, math.cos, math.sin
	--The other points in the rect
	local x2,y2 = w - xr, h - yr
	--This table are kinda like logic tables to do some tricks in the for loop
	local xs = {true,true,false,false}
	local ys = {false,true,true,false}

	for i = 1, 4 do --Four corners
		if t and not t[i] then --If the corner should not be rounded
			--Store the points in the table 
			p[#p + 1] = xs[i] and w or 0 --Depending on the tables before here goes the width or 0
			p[#p + 1] = ys[i] and h or 0 --Same with height
		else
			for j = 0, pre do --Make the corner, with n points where n is the precision specified
				local a = (j / pre + (i - 2))*hp --Get the ange for the current point
				p[#p + 1] = (xs[i] and x2 or xr) + xr * cos(a) --Calculate the x position of the point
				p[#p + 1] = (ys[i] and y2 or yr) + yr * sin(a) --Calculate the y position of the point
			end
		end
	end
	--Returns a function that has the ability to change the x and y position of the polygon
	return function (x,y)
		local r = {}
		for i=1, #p do
			r[i] = p[i] + (i%2 == 0 and y or x)
		end
		return r --Polygon once translated
	end
end