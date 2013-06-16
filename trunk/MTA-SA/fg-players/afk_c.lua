--[[
		(c) AXV <AXV@FullGaming.pl>, 2013
	
			You may not copy this code
	Or send email, it can provides you the code
]]

local afkTime = 0
timer = setTimer(
	function()
		if isLoggedIn() then
			afkTime = afkTime + 10
			if afkTime > getElementData(resourceRoot, "player:data:afk_time") then
				killTimer(timer)
				triggerServerEvent(getResourceName(resource) .. ":afk", getLocalPlayer())
			end
		else
			afkTime = 0
		end
	end,
	10000,
0)

local function reset()
	afkTime = 0
end

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		addEventHandler("onClientCursorMove", root, reset)
		local controls = { 'fire', 'next_weapon', 'previous_weapon', 'forwards', 'backwards', 'left', 'right', 'zoom_in', 'zoom_out', 'change_camera', 'jump', 'sprint', 'look_behind', 'crouch', 'walk', 'aim_weapon', 'enter_exit', 'vehicle_fire', 'vehicle_secondary_fire', 'vehicle_left', 'vehicle_right', 'steer_forward', 'steer_back', 'accelerate', 'brake_reverse', 'horn', 'sub_mission', 'vehicle_look_left', 'vehicle_look_right', 'vehicle_look_behind', 'vehicle_mouse_look', 'special_control_left', 'special_control_right', 'special_control_up', 'special_control_down' }
		for k, v in ipairs(controls) do
			bindKey(v, "both", reset)
		end

		addEventHandler("onClientConsole", root, reset)
end)