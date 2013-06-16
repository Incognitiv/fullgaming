--[[
		(c) AXV <AXV@FullGaming.pl>, 2013
	
			You may not copy this code
	Or send email, it can provides you the code
]]


local function replaceTexture(textureName, fpath)
	local myShader = dxCreateShader("shader.fx")
	local myTexture = dxCreateTexture(fpath)
	dxSetShaderValue(myShader, "CUSTOMTEX0", myTexture)
	if myShader then 
		engineApplyShaderToWorldTexture(myShader, textureName) 
	end
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		if getVersion().sortable < "1.1.0" then return end
		
		-- 
		replaceTexture("radar_hospital", "img/icon_hospital.png")
		replaceTexture("radar_bigsmoke", "img/icon_danger.png")
		replaceTexture("radar_pizza", "img/icon_pizza.png")
		replaceTexture("radar_pier", "img/icon_pier.png")
		replaceTexture("radar_airport", "img/icon_airport.png")
		replaceTexture("radar_atms", "img/icon_atm.png")
		replaceTexture("radar_cash", "img/icon_bank.png")
		replaceTexture("radar_mcstrap", "img/icon_vehicle1.png")
		replaceTexture("radar_tshirt", "img/icon_clothes.png")
		replaceTexture("radar_mystery", "img/icon_unkown.png")
		replaceTexture("radar_race", "img/icon_dest.png")
		
	end
)