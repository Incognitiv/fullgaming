--[[
		(c) AXV <AXV@FullGaming.pl>, 2013
	
			You may not copy this code
	Or send email, it can provides you the code
]]

screenX, screenY = guiGetScreenSize()

function drawGameTextToScreen(text, duration, colour, font, size, valign, halign, importance)
	if not importance then importance = 1 end
	
	if drawOptions then
		if drawOptions.importance <= importance then
			removeGameTextFromScreen()
		else
			return
		end
	end
	
	drawOptions = { }
	drawOptions.text = text
	drawOptions.colour = colour or {255, 255, 255}
	drawOptions.font = font or "arial"
	drawOptions.size = size or 1.2
	drawOptions.valign = valign or "center"
	drawOptions.halign = halign or "center"
	drawOptions.importance = importance
	
	drawOptions.colour[4] = 0
	
	
	drawOptions.x = (screenX/2) - 300
	drawOptions.y = (screenY/8) - 300
	drawOptions.r = (screenX/2) + 300
	drawOptions.b = (screenY/8) + 300
	
	if drawOptions.y < 0 then 
		drawOptions.y = 0 
	end
	if drawOptions.b > screenY then
		drawOptions.b = screenY
	end
	
	addEventHandler("onClientRender", getRootElement(), drawFunction)
	addEventHandler("onClientRender", getRootElement(), drawFadeIn)
	
	drawTimer = setTimer(
		function()
			removeEventHandler("onClientRender", getRootElement(), drawFadeIn)
			addEventHandler("onClientRender", getRootElement(), drawFadeOut)
		end,
		duration,
		1
	)
end
addEvent("drawGameTextToScreen", true)
addEventHandler("drawGameTextToScreen", true, drawGameTextToScreen)

function removeGameTextFromScreen()
	if drawOptions then
		removeEventHandler("onClientRender", getRootElement(), drawFunction)
		removeEventHandler("onClientRender", getRootElement(), drawFadeOut)
		removeEventHandler("onClientRender", getRootElement(), drawFadeIn)
		
		if isTimer(drawTimer) then
			killTimer(drawTimer)
		end
		drawTimer = nil
		drawOptions = nil
	end
end

function drawFunction()
	dxDrawText(drawOptions.text, drawOptions.x+2, drawOptions.y+2, drawOptions.r+2, drawOptions.b+2, tocolor(0, 0, 0, drawOptions.colour[4]), drawOptions.size, drawOptions.font, drawOptions.halign, drawOptions.valign, false, true, false)
	dxDrawText(drawOptions.text, drawOptions.x, drawOptions.y, drawOptions.r, drawOptions.b, tocolor(unpack(drawOptions.colour)), drawOptions.size, drawOptions.font, drawOptions.halign, drawOptions.valign, false, true, false)
end

function drawFadeIn()
	drawOptions.colour[4] = drawOptions.colour[4] + 7
	if drawOptions.colour[4] >= 255 then
		if drawOptions.colour[4] > 255 then
			drawOptions.colour[4] = 255
		end
		removeEventHandler("onClientRender", getRootElement(), drawFadeIn)
	end
end

function drawFadeOut()
	drawOptions.colour[4] = drawOptions.colour[4] - 7
	if drawOptions.colour[4] <= then
		if drawOptions.colour[4] < 0 then
			drawOptions.colour[4] = 0
		end
		
		removeGameTextFromScreen()
	end
end

	