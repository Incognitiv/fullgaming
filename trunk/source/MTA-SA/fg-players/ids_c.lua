--[[
		(c) AXV <AXV@FullGaming.pl>, 2013
	
			You may not copy this code
	Or send email, it can provides you the code
]]

local ids = {}

addEventHandler("onPlayerJoin", root,
	function()
		for i = 1, getMaxPlayers() do
			if not ids[i] then
				ids[i] = source
				setElementData(source, "player:data:id", i)
				
				-- send message to all players
				outputChatBox("*** " .. getPlayerName(source) .. " (" .. i .. " ) #666666do³¹czy³ do Gry!", root, 255, 255, 255, true)
				break
			end
		end
end)

addEventHandler("onResourceStart", resourceRoot,
	function()
		for i, source in ipairs(getElementsByType("player")) do
			ids[i] = source
			setElementData(source, "player:data:id", i)
		end
end)

addEventHandler("onPlayerQuit", root,
	function(type, reason, responsible)
		for i = 1, getMaxPlayers() do
			if ids[i] == source then
				ids[i] = nil
				if reason then
					type = type .. " - " .. reason
					if isElement(responsible) and getElementType(responsible) == "player" then
						type = type .. " - " .. getPlayerName(responsible)
					end
				end
				outputChatBox("*** " .. getPlayerName(source) .. " (" .. i .. " ) #666666opuœci³ Grê!", root, 255, 255, 255, true)
			end
		end
end)

--[[
			getPlayerID
	
	@params 			element player
	
	@returns 			playerid
]]

function getPlayerID(player)
	local id = getElementData(player, "player:data:id")
	if ids[id] == player then
		return id
	else 
		for i = 1, getMaxPlayers() do
			if ids[i] == player then
				return id
			end
		end
	end
end
