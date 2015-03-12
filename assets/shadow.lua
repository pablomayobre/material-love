local a = (...):gsub("%.","%/")

return {
	multiimage = true,
	image = {
		default = "z-depth-1",
		["z-depth-1"] = a.."-1.png",
		["z-depth-2"] = a.."-2.png",
		["z-depth-3"] = a.."-3.png",
		["z-depth-4"] = a.."-4.png",
		["z-depth-5"] = a.."-5.png",
	},
	hor = {x = 100,w = 200},
	ver = {y = 100,h = 200},
	pad = {-1,-1,-1,-1}, --Top, Right, Bottom, Left
}