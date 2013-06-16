--[[
		(c) AXV <AXV@FullGaming.pl>, 2013
	
			You may not copy this code
	Or send email, it can provides you the code
]]

local connection = nil
local null = nil
local results = {}
local max_results = 128

-- connection functions
local function connect()
	-- retrieve the settings
	local server = get("server") or "localhost"
	local user = get("user") or "mta"
	local password = get("password") or "qwerty"
	local port = get("port") or 3306
	local socket = get("socket") or nil
	
	-- connect
	connection = mysql_connect(server, user, password,db, port, socket)
	if connection then
		if user == "root" then
			setTimer(outputDebugString, 100, 1, "Connecting to your MySQL aqs 'root' is strongly discouraged", 2)
		end
		return true
	else 
		outputDebugString("Connection to MySQL Failed", 1)
		return false
	end
end

local function disconnect()
	if connection and mysql_ping(connection) then
		mysql_close(connection)
	end
end

local function checkConnection()
	if not connection or not mysql_ping(connection) then
		return connect()
	end
	return true
end

-- handlers
addEventHandler("onResourceStart", resourceRoot, 
	function()
		if not mysql_connect then
			if hasObjectPermissionTo(resource, "function.shutdown") then
				shutdown("MySQL module missing")
			end
			cancelEvent(true, "MySQL module missing")
		elseif not hasObjectPermissionTo("function.mysql_connect") then
			if hasObjectPermissionTo(resource, "function.shutdown") then
				shutdown("Insufficient ACL rights for mysql resource")
			end
			cancelEvent(true, "Insufficient ACL rights for mysql resource")
		elseif not connect() then
			if connection then
				outputDebugString(mysql_error(connection), 1)
			end
			if hasObjectPermissionTo(resource, "function.shutdown") then
				shutdown("MySQL failed to connect")
			end
			cancelEvent(true, "MySQL failed to connect")
		else 
			null = mysql_null()
		end
end)

addEventHandler("onResourceStop", resourceRoot,
	function()
		for k, v in pairs(results) do
			mysql_free_result(v.r)
			outputDebugString("Query not free()'d: " .. v.q, 2)
		end
		disconnect()
end)

-- scripting functions
function escape_string(str)
	if type(str) == "string" then
		return mysql_escape_string(connection, str)
	elseif type(str) == "number" then
		return tostring(str)
	end
end

local function query(str, ...)
	checkConnection()
	
	if(...) then
		local t = {...}
		for k, v in pairs(t) do
			t[k] = escape_string(tostring(v)) or ""
		end
		str = str:format(unpack(t))
	end
	
	local result = mysql_query(connection, str)
	if result then
		for num = 1, max_results do
			if not results[num] then
				results[num] = { r = result, q = str }
				return num
			end
		end
		mysql_free_result(result)
		return false, "Unable to allocate result in pool!"
	end
	return false, mysql_error(connection)
end

function query_free(str, ...)
	if sourceResource == getResourceFromName("runcode") then
		return false
	end
	
	checkConnection()
	
	if(...) then
		local t = {...}
		for k, v in pairs(t) do
			t[k] = escape_string(tostring(v)) or ""
		end
		str = str:format(unpack(t))
	end
	
	local result = mysql_query(connection, str)
	if result then
		mysql_free_result(result)
		return true
	end
	return false, mysql_error(connection)
end
	
function free_result(result)
	if results[result] then
		mysql_free_result(results[result].r)
		results[result] = nil
	end
end

function query_assoc(str, ...)
	if sourceResource == getResourceFromName("runcode") then
		return false
	end
	
	local t = { }
	local result, error = query(str, ...)
	if result then
		for result, row in mysql_rows_assoc(results[result].r) do
			local num = #t + 1
			t[num] = { }
			for k, v in pairs(row) do
				if v ~= null then
					t[num[k] = tonumber(v) or v
				end
			end
		end
		free_result(result)
		return t
	end
	return false, error
end

function query_assoc_single(str, ...)
	if sourceResource == getResourceFromName("runcode") then
		return false
	end
	
	local t = { }
	local result, error = query(str, ...)
	if result then
		local row = mysql_fetch_assoc(results[result].r)
		if row then
			for k, v in pairs(row) do
				if v ~= null then
					t[k] = tonumber(v) or v
					end
				end
			end
			free_result(result)
			return t
		end
	end 
	return false, error
end

function query_insertid(str, ...)
	if sourceResource == getResourceFromName("runcode") then
		return false
	end
	
	local result, error = query(str, ...)
	if result then
		local id = mysql_insert_id(connection)
		free_result(result)
		return id
	end
	return false, error
end

function query_affected_rows(str, ...)
	if sourceResource == getResourceFromName("runcode") then
		return false
	end
	
	local result, error = query(str, ...)
	if result then
		local rows = mysql_affected_rows(connection)
		free_result(result)
		return rows
	end
	return false, error
end
