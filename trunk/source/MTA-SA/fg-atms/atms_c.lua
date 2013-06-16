--[[
		(c) AXV <AXV@FullGaming.pl>, 2013
	
			You may not copy this code
	Or send email, it can provides you the code
]]

local amts = 
{
	-- zaokraglac rotacje do pelnych wartosci: 0, 90, 180, 270, 360 
	{x, y, z, rot},
}

for i, v in pairs(amts) do
	v.object = createObject(v[1], v[2], v[3]-1, 0, 0, v[4])
	v.icon = createBlip(v[1], v[2], v[3], 52, 2, 255, 255, 255, 255, -1000, 500)
	v.cs = createColSphere(v[1], v[2], v[3]+1, 1.5)
	
	if v.dimension then
		setElementDimension(v.object, v.dimension)
		setElementDimension(v.icon, v.dimension)
		setElementDimension(v.cs, v.dimension)
	end
	if v.interior then
		setElementInterior(v.object, v.interior)
		setElementInterior(v.icon, v.interior)
		setElementInterior(v.cs, v.interior)
	end
end
		