local a = ...

return {
	image = a:gsub("%.","%/")..".png",
	hor = {x = 26,w = 166},
	ver = {y = 12,h = 112},
	pad = {0,0,0,0}, --Top, Right, Bottom, Left
	cut = false,
}