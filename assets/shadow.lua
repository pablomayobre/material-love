local a = (...):gsub("%.","%/")

return {
	multiimage = true,
	image = {
		default = 1,
		[1] = a.."-1.png",
		[2] = a.."-2.png",
		[3] = a.."-3.png",
		[4] = a.."-4.png",
		[5] = a.."-5.png",
	},
	hor = {x = 100,w = 200},
	ver = {y = 100,h = 200},
	pad = {0,0,0,0}, --Top, Right, Bottom, Left
}