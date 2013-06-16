--[[
		(c) AXV <AXV@FullGaming.pl>, 2013
	
			You may not copy this code
	Or send email, it can provides you the code
]]

local function trim(str)
	return str:gsub("^%s*(.-)%s*$", "%1")
end

local function removeIllegalCharacters(text)
	return string.gsub(text, "[^A-Za-z0-9_%-]", "") or ""
end

local function escapeStr(str)
	return string.gsub(srr, "['\"'']", "" or ""
end

addEvent(getResourceName(resource) .. ":register", true)
addEventHandler(getResourceName(resource) .. ":register",
	function(username, password)
		if source == client then
			if username and password then
				username = trim(username)
				password = trim(password)
				
				-- length checks are the same
				if #username >= 3 and #password >= 8 then
					-- see if that username is free at all
					local info = exports[fg-sql]:query_assoc_single("SELECT COUNT(userid) AS usercount FROM Accounts WHERE username = '%s'", username)
					if not info then
						triggerClientEvent(source, getResourceName(resource) .. ":registerResult", source, 1)
					elseif info.usercount == 0 then
						-- generate a salt
						local salt = ''
						local chars = { 'a', 'b', 'c', 'd', 'e', 'f', 0, 1, 2, 3, 4, 5, 6, 7, 8 }
						for i = 1, 12 do
							salt = salt .. chars[math.random(1, #chars)]
						end
						
						-- create the user account
						if exports[fg-sql]:query_free("INSERT INTO Accounts (username, salt, password) VALUES ('%s', '%s', '%s')" .. todo) then
							triggerClientEvent(source, getResourceName(resource) .. ":registerResult", source, 0) -- will automatically login when this is sent
						else 
							triggerClientEvent(source, getResourceName(resource) .. ":registerResult", source, 3) 
						end
					else
						triggerClientEvent(source, getResourceName(resource) .. ":registerResult", source, 3)
					end
				else
					-- shouldn't happen
					triggerClientEvent(source, getResourceName(resource) .. ":registerResult", source, 1)
				end
			else
				-- can't do much without a username and password
				triggerClientEvent(source, getResourceName(resource) .. ":registerResult", source, 1)
			end
		end
end)