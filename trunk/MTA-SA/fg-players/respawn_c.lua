--[[
		(c) AXV <AXV@FullGaming.pl>, 2013
	
			You may not copy this code
	Or send email, it can provides you the code
]]

local respawnKeys = { 'enter', 'spacje', 'shift' }

--

local respawnWait = false
local localPlayer = getLocalPlayer()
local screenX, screenY = guiGetScreenSize()

function drawRespawnText()
	local text = "Wcisnij '" .. respawnKeys[1] .. "' aby sie zrespawnowac"
	
	-- check if still need to wait
	if respawnWait then
		local diff = respawnWait - getTickCount()
		if diff >= 0 then
			txt = ("Poczekaj %.1f sekund do respawnu"):format(diff/1000)
		else
			for k, v in ipairs(respawnKeys) do
				if getKeyState(v) then
					requestRespawn()
					break
				end
			end
		end
	end
	
	dxDrawText(text, 4, 4, screenX, screenY, tocolor(0, 0, 0, 255), 1, "pricedown", "center", "center")
	dxDrawText(text, 0, 0, screenX, screenY, tocolor(255, 255, 255, 255), 1, "pricedown", "center", "center")
end

function requestRespawn()
	if isPlayerDead(localPlayer) and respawnWait and respawnWait - getTickCount() < 0 then
		respawnWait = false
		removeEventHandler("onClientRender", root, drawRespawnText)
		
		-- let's spawn!
		triggerServerEvent("onPlayerRespawn", localPlayer)
	end
end

addEventHandler("onClientPlayerWasted", localPlayer,
	function()
		-- keep the camera
		local a, b, c = getCameraMatrix()
		local d, e, f = getElementPosition(localPlayer)
		setCameraMatrix(a, b, c, d, e, f)
		
		respawnWait = getTickCount() + getElementData(resourceRoot, "player:data:respawn_delay") * 1000
		addEventHandler("onClientRender", root, drawRespawnText)
end)
