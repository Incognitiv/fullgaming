--[[
		(c) AXV <AXV@FullGaming.pl>, 2013
	
			You may not copy this code
	Or send email, it can provides you the code
]]

local afkTime = tonumber(get("afk_time")) or 300

addEventHandler("onResourceStart", resourceRoot,
	function()
		setElementData(resourceRoot, "player:data:afk_time", afkTime)
end)


addEvent(getResourceName(resource) .. ":afk", true)
addEventHandler(getResourceName(resource) .. ":afk", root,
	function()
		if source == client then
			if hasObjectPermissionTo(source, "general.WillNotBeAfkKicked", false) then
				return
			end
			kickPlayer(source, "Away from Keyboard")
		end
end)
