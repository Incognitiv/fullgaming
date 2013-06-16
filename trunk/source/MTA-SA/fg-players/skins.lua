--[[
		(c) AXV <AXV@FullGaming.pl>, 2013
	
			You may not copy this code
	Or send email, it can provides you the code
]]

local skins =
{
	male =
	{
		0, 7, 14, 15, 16, 17, 18, 19, 20, 21, 22, 24, 25, 28, 51, 66, 67, 79, 80, 83, 84, 102, 103, 104, 105, 
		106, 107, 134, 136, 142, 143, 144, 156, 163, 166, 168, 176, 180, 182, 183, 185, 220, 221, 222, 249, 253, 
		260, 262, 23, 26, 27, 29, 30, 32, 33, 34, 35, 36, 37, 43, 44, 45, 46, 47, 48, 49, 50, 52, 57, 58, 59, 60, 61
	},
	female =
	{
		9, 10, 11, 13, 63, 69, 76, 139, 148, 190, 195, 207, 215, 218, 219, 238, 244, 245, 256,
		12, 31, 38, 39, 40, 41, 53, 54, 55, 56, 64, 75, 77, 85, 87, 88, 89, 90, 91, 92, 93, 129, 
		130, 131, 138, 140, 141, 145, 150, 151, 152, 157, 169, 178, 191, 192, 193, 194, 196, 197, 
		198, 199, 201, 205, 211, 214, 216, 224, 225, 226, 231, 232, 233, 237, 243, 246, 251, 257, 263
	}
}

local skins_ = { }
local skins__ = { }

for k, v in pairs(skins) do
	for k2, v2 in pairs(v) do
		for _, skin in ipairs(v2) do
			table.insert(skins_, skin)
			skins__[skin] = { gender = k }
		end
	end
end

table.sort(skins_)

function getSkins()
	return skins_
end

function isValidSkin(skin)
	return skin and skins__[skin] and true or false
end