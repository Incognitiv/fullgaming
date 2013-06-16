static Timer:CountDownTimer;

new Text:CountdownText = Text:INVALID_TEXT_DRAW;

stock StartCountdown(m, s)
{
	if(s > 60) s = 60;
	
	gServerTemp[st_CountMinute] = m;
	gServerTemp[st_CountSecond] = s;
	
	CountDownTimer = repeat CountDownTick();
}

timer CountDownTick[1000]()
{
	new 
		timeStr[16];
	
	format(timeStr, 16, "%02d:%02d", gServerTemp[st_CountMinute], gServerTemp[st_CountSecond]);
	
	// set to format timestr
	TextDrawSetString(CountdownText, timeStr);
	TextDrawShowForAll(CountdownText);
	
	if(gServerTemp[st_CountMinute] != 0 && gServerTemp[st_CountSecond] == 0)
	{
		gServerTemp[st_CountMinute]--;
		gServerTemp[st_CountSecond] = 60;
	}
	
	if(gServerTemp[st_CountMinute] == 0 && gServerTemp[st_CountSecond] == 0)
	{
		StopCountdown();
	} else {
		gServerTemp[st_CountSecond]--;
	}
}

stock StopCountdown()
{
	TextDrawHideForAll(CountdownText);
	if(gServerTemp[st_CountMinute] == 0 && gServerTemp[st_CountSecond] == 0)
	{
		GameTextForAll("~r~GO!", 3000, 5);
	}
	
	gServerTemp[st_CountMinute] = 0;
	gServerTemp[st_CountSecond] = 0;
	
	stop CountDownTimer;
	return 1;
}