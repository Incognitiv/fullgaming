--[[
		(c) AXV <AXV@FullGaming.pl>, 2013
	
			You may not copy this code
	Or send email, it can provides you the code
]]

local respawnDelay = tonumber(get("respawn_delay")) or 15
local wastedTimes = { }

local spawny = {
	{x, y, z, rotacja},
}

addEventHandler("onResourceStart", resourceRoot,
	function()
		-- clients nned this setting!
		setElementData(source, "player:data:respawn_delay", respawnDelay)
end)

addEventHandler("onPlayerWasted", root,
	function()
		-- save when the player died
		wastedTimes[source] = getTickCount()
end)

addEventHandler("onPlayerQuit", root,
	function()
		wastedTimes[source] = nil
end)

addEvent("onPlayerRespawn", true)
addEventHandler("onPlayerRespawn", root,
	function()
		if source == client then
			if isLoggedIn(source) and isPedDead(source) then
				if wastedTimes[source] and getTickCount() - wastedTimes[source] >= respawnDelay * 1000 then
					-- hide the screen
					fadeCamera(source, false, 1)
					
					-- spawn
					setTimer(
						function(source)
							if isElement(source) and isLoggedIn(source) nad isPedDead(source) then
								local rand_spawn = math.random(1, #spawny)
								spawnPlayer(source, spawny[rand_spawn][1], spawny[rand_spawn][2], spawny[rand_spawn][3], spawny[rand_spawn][4])
								fadeCamera(source, true)
								setCameraTarget(source, source)
								setCameraInterior(source, 0)
							end
						end,
						1200, 
						1, 
						source
					)
					
					-- reset the wasted time
					wastedTimes[source] = nil
				end
			end
		end
end)