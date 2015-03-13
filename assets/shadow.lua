local a = (...):gsub("%.","%/")

return {
	multiimage = true, --true to use multiple images false for one
	image = { --Table when multiimage is true, string otherwise
		[1] = a.."-1.png", --Holds the path to the images
		[2] = a.."-2.png",
		[3] = a.."-3.png",
		[4] = a.."-4.png",
		[5] = a.."-5.png",
		default = 1, --Default asset to use, in this case #1
	},
	hor = {x = 100,w = 200}, --Horizontal line for cropping
	ver = {y = 100,h = 200}, --Vertical   line for cropping
	pad = {0,0,0,0}, --Top, Right, Bottom, Left
}