
#include <YSI\y_hooks>

#define MAX_PRIV_VEHICLES ( 100)

#define PV_TOTAL_ITEMS (50)
#define PV_SELECTION_ITEMS 21
#define PV_ITEMS_PER_LINE 7

#define PV_HEADER_TEXT "Pojazdy prywatne"
#define PV_NEXT_TEXT "Dalej"
#define PV_PREV_TEXT "Wroc"

#define PV_DIALOG_BASE_X 75.0
#define PV_DIALOG_BASE_Y 130.0
#define PV_DIALOG_WIDTH 550.0
#define PV_DIALOG_HEIGHT 180.0
#define SPRITE_DIM_X 60.0
#define SPRITE_DIM_Y 70.0

enum e_priv_vehicles {
	pv_vid,
	pv_owner,
	pv_modelid,
	pv_dayUsedLast,
	pv_color[2],
	pv_paintjob,
	//Float:pv_dist[3],
	pv_components[14],
	pv_carname[32],
	Float:pv_dist[3],
	Text3D: pv_label,
	Float: pv_SpawnPos[4], // xyzrot
	//Float: pv_mileage[4], // [0,1] latitude nad longitude of point 1 (start), [2,3] latidue and longitude of point 2 (current position)
	Float: pv_mileage, 
	bool: pv_spawned,
	bool: pv_lock
};

new
	pvlist_TotalItems = PV_TOTAL_ITEMS,
	PlayerText:pvlist_CurrentPage[MAX_GRACZY],
	PlayerText:pvlist_Header[MAX_GRACZY],
	PlayerText:pvlist_BackgroundText[MAX_GRACZY],
	PlayerText:pvlist_NextButton[MAX_GRACZY],
	PlayerText:pvlist_PrevButton[MAX_GRACZY],
	PlayerText:pvlist_SelectionsItems[MAX_GRACZY][PV_SELECTION_ITEMS],
	gSelectionItemsTag[MAX_GRACZY][PV_SELECTION_ITEMS],
	gItemAt[MAX_GRACZY],
	gItemList[PV_TOTAL_ITEMS] = {
		400,401,402,405,411,412,
		415,418,421,424,426,429,
		439,445,451,458,459,466,
		474,475,477,480,482,483,
		492,496,506,507,533,534,
		535,536,540,541,550,551,
		555,558,559,560,561,562,
		565,567,579,580,587,589,
		602,603
	},
	// --
	pvData[MAX_PRIV_VEHICLES][e_priv_vehicles],
	gpVehicleid[MAX_PLAYERS],
	gPlayerLastVID[MAX_PLAYERS]
	//MySQL: mysql_h
;
/*
public OnFilterScriptInit() {
	
	mysql_h = mysql_init(LOG_ALL,1);
	new handle = mysql_connect( "localhost", "testowy", "qwerty", "test");
	if(handle) print( "polaczono z baza");
	
	loadPrivateVehicles();
	return 1;
}*/

//public OnFilterScriptExit() mysql_close(mysql_h);

/* 		columns:
	id
	uid
	modelid
	x
	y
	z
	rot
	color1
	color2
	paintjob
	mods
	datetime_created
	datetime_lastused
*/

stock GetNumberOfPages() {
	if((pvlist_TotalItems>=PV_SELECTION_ITEMS) && (pvlist_TotalItems % PV_SELECTION_ITEMS) == 0) {
		return (pvlist_TotalItems/PV_SELECTION_ITEMS);
	} else return (pvlist_TotalItems/PV_SELECTION_ITEMS)+1;
}

stock PlayerText:CreateCurrentPageTextDraw(playerid, Float:xpos, Float:ypos) {
	new PlayerText:txtInit;
	txtInit = CreatePlayerTextDraw(playerid, xpos, ypos, "0/0");
	PlayerTextDrawUseBox(playerid, txtInit, 0);
	PlayerTextDrawLetterSize(playerid, txtInit, 0.4, 1.1);
	PlayerTextDrawFont(playerid, txtInit, 1);
	PlayerTextDrawSetShadow(playerid, txtInit, 0);
    PlayerTextDrawSetOutline(playerid, txtInit, 1);
    PlayerTextDrawColor(playerid, txtInit, 0xACCBF1FF);
    PlayerTextDrawShow(playerid, txtInit);
    return txtInit;
}

stock PlayerText:CreatePlayerDialogButton(playerid, Float:Xpos, Float:Ypos, Float:Width, Float:Height, button_text[]) {
	new PlayerText:txtInit;
	txtInit = CreatePlayerTextDraw(playerid, Xpos, Ypos, button_text);
	PlayerTextDrawUseBox(playerid, txtInit, 1);
	PlayerTextDrawBoxColor(playerid, txtInit, 0x000000FF);
	PlayerTextDrawBackgroundColor(playerid, txtInit, 0x000000FF);
	PlayerTextDrawLetterSize(playerid, txtInit, 0.4, 1.1);
	PlayerTextDrawFont(playerid, txtInit, 1);
	PlayerTextDrawSetShadow(playerid, txtInit, 0); // no shadow
    PlayerTextDrawSetOutline(playerid, txtInit, 0);
    PlayerTextDrawColor(playerid, txtInit, 0x4A5A6BFF);
    PlayerTextDrawSetSelectable(playerid, txtInit, 1);
    PlayerTextDrawAlignment(playerid, txtInit, 2);
    PlayerTextDrawTextSize(playerid, txtInit, Height, Width); // The width and height are reversed for centering.. something the game does <g>
    PlayerTextDrawShow(playerid, txtInit);
    return txtInit;
}

stock PlayerText:CreatePlayerHeaderTextDraw(playerid, Float:Xpos, Float:Ypos, header_text[]) {
	new PlayerText:txtInit;
	txtInit = CreatePlayerTextDraw(playerid, Xpos, Ypos, header_text);
	PlayerTextDrawUseBox(playerid, txtInit, 0);
	PlayerTextDrawLetterSize(playerid, txtInit, 1.25, 3.0);
	PlayerTextDrawFont(playerid, txtInit, 0);
	PlayerTextDrawSetShadow(playerid, txtInit, 0);
    PlayerTextDrawSetOutline(playerid, txtInit, 1);
    PlayerTextDrawColor(playerid, txtInit, 0xACCBF1FF);
    PlayerTextDrawShow(playerid, txtInit);
    return txtInit;
}

stock PlayerText:CreatePlayerBackgroundTextDraw(playerid, Float:Xpos, Float:Ypos, Float:Width, Float:Height) {
	new PlayerText:txtBackground = CreatePlayerTextDraw(playerid, Xpos, Ypos, "_"); // ReEdited by AirKite (for universal localization)
    PlayerTextDrawUseBox(playerid, txtBackground, 1);
    PlayerTextDrawBoxColor(playerid, txtBackground, 0x00000099);
	PlayerTextDrawLetterSize(playerid, txtBackground, 5.0, 30.0); // ReEdited by AirKite (for universal localization)
	PlayerTextDrawFont(playerid, txtBackground, 0);
	PlayerTextDrawSetShadow(playerid, txtBackground, 0);
    PlayerTextDrawSetOutline(playerid, txtBackground, 0);
    PlayerTextDrawColor(playerid, txtBackground,0x000000FF);
    PlayerTextDrawTextSize(playerid, txtBackground, Width, Height);
	PlayerTextDrawBackgroundColor(playerid, txtBackground, 0x00000099);
    PlayerTextDrawShow(playerid, txtBackground);
    return txtBackground;
}

stock PlayerText:CreateModelPreviewTextDraw(playerid, modelindex, Float:Xpos, Float:Ypos, Float:width, Float:height) {
    new PlayerText:txtPlayerSprite = CreatePlayerTextDraw(playerid, Xpos, Ypos, ""); // it has to be set with SetText later
    PlayerTextDrawFont(playerid, txtPlayerSprite, TEXT_DRAW_FONT_MODEL_PREVIEW);
    PlayerTextDrawColor(playerid, txtPlayerSprite, 0xFFFFFFFF);
    PlayerTextDrawBackgroundColor(playerid, txtPlayerSprite, 0x000000EE);
    PlayerTextDrawTextSize(playerid, txtPlayerSprite, width, height); // Text size is the Width:Height
    PlayerTextDrawSetPreviewModel(playerid, txtPlayerSprite, modelindex);
    PlayerTextDrawSetPreviewRot(playerid,txtPlayerSprite, -16.0, 0.0, -55.0);
    PlayerTextDrawSetSelectable(playerid, txtPlayerSprite, 1);
    PlayerTextDrawShow(playerid,txtPlayerSprite);
    return txtPlayerSprite;
}

stock DestroyPlayerModelPreviews(playerid) {
	new x=0;
	while(x != PV_SELECTION_ITEMS) {
		if(pvlist_SelectionsItems[playerid][x] != PlayerText:INVALID_TEXT_DRAW) {
			PlayerTextDrawDestroy(playerid, pvlist_SelectionsItems[playerid][x]);
			pvlist_SelectionsItems[playerid][x] = PlayerText:INVALID_TEXT_DRAW;
		}
		x++;
	}
}

ShowPlayerModelPreviews(playerid) {
    new x=0;
	new Float:BaseX = PV_DIALOG_BASE_X;
	new Float:BaseY = PV_DIALOG_BASE_Y - (SPRITE_DIM_Y * 0.33); // down a bit
	new linetracker = 0;
       
	new itemat = GetPVarInt(playerid, "vspawner_page") * PV_SELECTION_ITEMS;
       
	// Destroy any previous ones created
	DestroyPlayerModelPreviews(playerid);
 
	while(x != PV_SELECTION_ITEMS && itemat < pvlist_TotalItems) {
		if(linetracker == 0) {
			BaseX = PV_DIALOG_BASE_X + 25.0; // in a bit from the box
			BaseY += SPRITE_DIM_Y + 1.0; // move on the Y for the next line
		}
		pvlist_SelectionsItems[playerid][x] = CreateModelPreviewTextDraw(playerid, gItemList[itemat], BaseX, BaseY, SPRITE_DIM_X, SPRITE_DIM_Y);
		gSelectionItemsTag[playerid][x] = gItemList[itemat];
		BaseX += SPRITE_DIM_X + 1.0; // move on the X for the next sprite
		linetracker++;
		if(linetracker == PV_ITEMS_PER_LINE) linetracker = 0;
		itemat++;
		x++;
	}
}

UpdatePageTextDraw(playerid)
{
        new PageText[64+1];
        format(PageText, 64, "%d/%d", GetPVarInt(playerid,"vspawner_page") + 1, GetNumberOfPages());
        PlayerTextDrawSetString(playerid, pvlist_CurrentPage[playerid], PageText);
}
 
//------------------------------------------------
 
stock CreateSelectionMenu(playerid)
{
    pvlist_BackgroundText[playerid] = CreatePlayerBackgroundTextDraw(playerid, PV_DIALOG_BASE_X, PV_DIALOG_BASE_Y + 20.0, PV_DIALOG_WIDTH, PV_DIALOG_HEIGHT);
    pvlist_Header[playerid] = CreatePlayerHeaderTextDraw(playerid, PV_DIALOG_BASE_X, PV_DIALOG_BASE_Y, PV_HEADER_TEXT);
    pvlist_CurrentPage[playerid] = CreateCurrentPageTextDraw(playerid, PV_DIALOG_WIDTH - 30.0, PV_DIALOG_BASE_Y + 15.0);
    pvlist_NextButton[playerid] = CreatePlayerDialogButton(playerid, PV_DIALOG_WIDTH - 30.0, PV_DIALOG_BASE_Y+PV_DIALOG_HEIGHT+100.0, 50.0, 16.0, PV_NEXT_TEXT);
    pvlist_PrevButton[playerid] = CreatePlayerDialogButton(playerid, PV_DIALOG_WIDTH - 90.0, PV_DIALOG_BASE_Y+PV_DIALOG_HEIGHT+100.0, 50.0, 16.0, PV_PREV_TEXT);
 
    ShowPlayerModelPreviews(playerid);
    UpdatePageTextDraw(playerid);
}
 
//------------------------------------------------
 
stock DestroySelectionMenu(playerid)
{
	DestroyPlayerModelPreviews(playerid);
 
	PlayerTextDrawDestroy(playerid, pvlist_Header[playerid]);
	PlayerTextDrawDestroy(playerid, pvlist_BackgroundText[playerid]);
	PlayerTextDrawDestroy(playerid, pvlist_CurrentPage[playerid]);
	PlayerTextDrawDestroy(playerid, pvlist_NextButton[playerid]);
	PlayerTextDrawDestroy(playerid, pvlist_PrevButton[playerid]);
 
	pvlist_Header[playerid] = PlayerText:INVALID_TEXT_DRAW;
    pvlist_BackgroundText[playerid] = PlayerText:INVALID_TEXT_DRAW;
    pvlist_CurrentPage[playerid] = PlayerText:INVALID_TEXT_DRAW;
    pvlist_NextButton[playerid] = PlayerText:INVALID_TEXT_DRAW;
    pvlist_PrevButton[playerid] = PlayerText:INVALID_TEXT_DRAW;
}

stock SpawnVehicle_InfrontOfPlayer(playerid, vehiclemodel, color1, color2) {
	new Float:x,Float:y,Float:z;
	new Float:facing;
	new Float:distance;
 
    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, facing);
 
    new Float:size_x,Float:size_y,Float:size_z;
	GetVehicleModelInfo(vehiclemodel, VEHICLE_MODEL_INFO_SIZE, size_x, size_y, size_z);
       
	distance = size_x + 0.5;
 
	x += (distance * floatsin(-facing, degrees));
    y += (distance * floatcos(-facing, degrees));
 
	facing += 90.0;
	if(facing > 360.0) facing -= 360.0;
 
	if(IsVIP(playerid)) {
		Respekt[playerid]-=1000;
	} else {
		Respekt[playerid]-=3500;
	}
	
	new buf[200], nick[24];
	GetPlayerName(playerid,nick,24);
	format(buf,sizeof(buf)-1,"INSERT INTO priv_vehicles (uid,modelid,x,y,z,rot,color1,color2,name_car) VALUES (%d,%d,'%4.4f','%4.4f','%3.3f','%3.2f',%d,%d,'%s');", Player[playerid][uID], vehiclemodel, x, y, z, facing, color1, color2, nick);
	if(mysql_query(buf)) mysql_ping();
	
	SendClientMessage(playerid,-1,"Gratulacje! Zakupi³eœ swój prywatny pojazd!");
	SendClientMessage(playerid,-1,"Menu do zarz¹dzania prywatnym pojazdem: /pcar");
	SendClientMessage(playerid,-1," *** Pamiêtaj, ¿eby pojazd u¿ywaæ raz na 14 dni. W przeciwnym wypadku system usunie Twój prywatny pojazd.");
	
	return priv_CreateVehicle(vehiclemodel, x, y, z + (size_z * 0.25), facing, color1, color2, -1, Player[playerid][uID]);
}

stock priv_CreateVehicle(modelid,Float:x,Float:y,Float:z,Float:ang,color1,color2,respawn_delay,uid) {
	new noweid=INVALID_VEHICLE_ID;
	for(new i = 0; i < MAX_PRIV_VEHICLES; i++) {
		if(pvData[i][pv_modelid] == 0) {
			noweid=i;
			break;
		}
	}
	
	if(noweid==INVALID_VEHICLE_ID) return 0;
	new idgracza = INVALID_PLAYER_ID;
	foreachPly(playerid) {
		if(uid==Player[playerid][uID]) {
			idgracza=playerid;
			break;
		}
	}
	if(idgracza==INVALID_PLAYER_ID) return 0;
	
	new nick[24];
	GetPlayerName(idgracza,nick,sizeof(nick));
	
	pvData[noweid][pv_owner] = uid;
	pvData[noweid][pv_modelid] = modelid;
	pvData[noweid][pv_SpawnPos][0] = x;
	pvData[noweid][pv_SpawnPos][1] = y;
	pvData[noweid][pv_SpawnPos][2] = z;
	pvData[noweid][pv_SpawnPos][3] = ang;
	pvData[noweid][pv_color][0] = color1;
	pvData[noweid][pv_color][1] = color2;
	format(pvData[noweid][pv_carname], 32, nick);
	
	new buf[128];
	pvData[noweid][pv_vid] = CreateVehicle( pvData[noweid][pv_modelid], pvData[noweid][pv_SpawnPos][0], pvData[noweid][pv_SpawnPos][1], pvData[noweid][pv_SpawnPos][2], pvData[noweid][pv_SpawnPos][3], pvData[noweid][pv_color][0], pvData[noweid][pv_color][1], respawn_delay);
	format( buf, sizeof( buf), "{eaeaea}%s\n{D9C2AD}Wlasciciel: %s\nPrzebieg: %.3fkm", pvData[noweid][pv_carname], nick, pvData[noweid][pv_mileage]);
	pvData[noweid][pv_label] = CreateDynamic3DTextLabel( buf, 0xD9C2ADFF, 0.0, 0.0, 0.250, 40.0, INVALID_PLAYER_ID, pvData[noweid][pv_vid], 1, -1, -1, -1, 50.0);
	
	tVehicles[pvData[noweid][pv_vid]][vo_destroyIfEmpty] = false;
	tVehicles[pvData[noweid][pv_vid]][vo_private] = true;
	tVehicles[pvData[noweid][pv_vid]][vo_owningPlayerId] = idgracza;
	tVehicles[pvData[noweid][pv_vid]][vo_pvid] = noweid;
	tVehicles[pvData[noweid][pv_vid]][vo_static] = false;
	tVehicles[pvData[noweid][pv_vid]][vo_color][0] = pvData[noweid][pv_color][0];
	tVehicles[pvData[noweid][pv_vid]][vo_color][1] = pvData[noweid][pv_color][1];

	new pvengine, pvlights, pvalarm, pvdoors, pvbonnet, pvboot, pvobjective;
    GetVehicleParamsEx(pvData[noweid][pv_vid], pvengine, pvlights, pvalarm, pvdoors, pvbonnet, pvboot, pvobjective);
	SetVehicleParamsEx(pvData[noweid][pv_vid], pvengine, pvlights, pvalarm, 0, pvbonnet, pvboot, pvobjective);
	
	SetVehicleParamsForPlayer(pvData[noweid][pv_vid], idgracza, 0, 0);
	vehicleDoorState[pvData[noweid][pv_vid]] = 1;
	vehicleDoorOwner[pvData[noweid][pv_vid]] = idgracza;
	
	gpVehicleid[idgracza]=noweid;			
	return 1;
}
	
	
stock HandlePlayerItemSelection(playerid, selecteditem) {
        // In this case we're spawning a vehicle for them
    SpawnVehicle_InfrontOfPlayer(playerid, gSelectionItemsTag[playerid][selecteditem], -1, -1);
}

hook OnPlayerConnect(playerid)
{
	
	pvlist_Header[playerid] = PlayerText:INVALID_TEXT_DRAW;
    pvlist_BackgroundText[playerid] = PlayerText:INVALID_TEXT_DRAW;
    pvlist_CurrentPage[playerid] = PlayerText:INVALID_TEXT_DRAW;
    pvlist_NextButton[playerid] = PlayerText:INVALID_TEXT_DRAW;
    pvlist_PrevButton[playerid] = PlayerText:INVALID_TEXT_DRAW;
	
	for(new x=0; x < PV_SELECTION_ITEMS; x++) {
        pvlist_SelectionsItems[playerid][x] = PlayerText:INVALID_TEXT_DRAW;
	}
	
	gPlayerLastVID[playerid] = INVALID_VEHICLE_ID;
	gItemAt[playerid] = 0;
	gpVehicleid[playerid] = -1;
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid) {
	if(GetPVarInt(playerid, "vspawner_active") == 0) return 0;
 
	// Handle: They cancelled (with ESC)
	if(clickedid == Text:INVALID_TEXT_DRAW) {
        DestroySelectionMenu(playerid);
        SetPVarInt(playerid, "vspawner_active", 0);
        PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
		ShowPlayerPasek(playerid);
        return 1;
	}
       
	return 0;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {
	if(GetPVarInt(playerid, "vspawner_active") == 0) return 0;
	
	new curpage = GetPVarInt(playerid, "vspawner_page");
	
	// Handle: next button
	if(playertextid == pvlist_NextButton[playerid]) {
		if(curpage < (GetNumberOfPages() - 1)) {
			SetPVarInt(playerid, "vspawner_page", curpage + 1);
			ShowPlayerModelPreviews(playerid);
			UpdatePageTextDraw(playerid);
			PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
		} else {
			PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
		}
		return 1;
	}
	
	// Handle: previous button
	if(playertextid == pvlist_PrevButton[playerid]) {
		if(curpage > 0) {
			SetPVarInt(playerid, "vspawner_page", curpage - 1);
			ShowPlayerModelPreviews(playerid);
			UpdatePageTextDraw(playerid);
			PlayerPlaySound(playerid, 1084, 0.0, 0.0, 0.0);
		} else {
			PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
		}
		return 1;
	}
	
	// Search in the array of textdraws used for the items
	new x=0;
	while(x != PV_SELECTION_ITEMS) {
		if(playertextid == pvlist_SelectionsItems[playerid][x]) {
			HandlePlayerItemSelection(playerid, x);
			PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
			DestroySelectionMenu(playerid);
			CancelSelectTextDraw(playerid);
			ShowPlayerPasek(playerid);
			SetPVarInt(playerid, "vspawner_active", 0);
			return 1;
		}
		x++;
	}
	
	return 0;
}

stock pv_SpawnVehicle(playerid, Float:pX = -1.0, Float:pY = -1.0, Float:pZ = -1.0, Float:pA = -1.0)
{
	new vid = gpVehicleid[playerid];
	if(vid<0) return 0;
	if(!(pvData[vid][pv_modelid]>=400)) return 0;
	//printf("2");
	
	
	if (pvData[vid][pv_vid]!=INVALID_VEHICLE_ID && tVehicles[pvData[vid][pv_vid]][vo_private] && tVehicles[pvData[vid][pv_vid]][vo_pvid]==vid && GetVehicleModel(pvData[vid][pv_vid])==pvData[vid][pv_modelid]) {
	} else {
		if (pvData[vid][pv_vid]!=INVALID_VEHICLE_ID && pvData[vid][pv_vid]>0) {
			printf("Usuwanie starego pojazdu %d", pvData[vid][pv_vid]);
			//niszczymy stary pojazd i informacje o tym ze jest prywatny
			tVehicles[pvData[vid][pv_vid]][vo_private]=false;
			tVehicles[pvData[vid][pv_vid]][vo_owningPlayerId]=INVALID_PLAYER_ID;
			tVehicles[pvData[vid][pv_vid]][vo_pvid]=-1;
			tVehicles[pvData[vid][pv_vid]][vo_destroyIfEmpty]=true;
			tVehicles[pvData[vid][pv_vid]][vo_licensePlateSet]=false;
			tVehicles[pvData[vid][pv_vid]][vo_color][0]=-1;
			tVehicles[pvData[vid][pv_vid]][vo_color][1]=-1;
			tVehicles[pvData[vid][pv_vid]][vo_static]=false;
			DestroyDynamic3DTextLabel(pvData[vid][pv_label]);
		}
		
		new cvid = CreateVehicle(pvData[vid][pv_modelid], pX==-1? pvData[vid][pv_SpawnPos][0]: pX, pY==-1? pvData[vid][pv_SpawnPos][1]: pY, pZ==-1? pvData[vid][pv_SpawnPos][2]: pZ,
			pA==-1? pvData[vid][pv_SpawnPos][3]: pA, pvData[vid][pv_color][0], pvData[vid][pv_color][1], 4*3600);
		
		printf("Stworzono pojazd %d dla gracza %d model %d", cvid, playerid, pvData[vid][pv_modelid]);
		pvData[vid][pv_vid] = cvid;
		for(new i = 0; i<=13; i++)
		{
			if(pvData[vid][pv_components][i] > 0) 
				AddVehicleComponent(cvid, pvData[vid][pv_components][i]);
		}
		
		new buf[128];
		format( buf, sizeof( buf), "{eaeaea}%s\n{D9C2AD}Wlasciciel: %s\nPrzebieg: %.3fkm", pvData[vid][pv_carname], PlayerName(playerid), pvData[vid][pv_mileage]);
		DestroyDynamic3DTextLabel(pvData[vid][pv_label]);
		pvData[vid][pv_label] = CreateDynamic3DTextLabel( buf, 0xD9C2ADFF, 0.0, 0.0, 0.250, 40.0, INVALID_PLAYER_ID, pvData[vid][pv_vid], 1, 0, 0, -1, 50.0);
	}
	//printf("3");
	if(strlen(pvData[vid][pv_carname])>3)
	{
		SetVehicleNumberPlate(pvData[vid][pv_vid], pvData[vid][pv_carname]); 
		tVehicles[pvData[vid][pv_vid]][vo_licensePlateSet]=true;
	}
	
	tVehicles[pvData[vid][pv_vid]][vo_destroyIfEmpty] = false;
	tVehicles[pvData[vid][pv_vid]][vo_private] = true;
	tVehicles[pvData[vid][pv_vid]][vo_owningPlayerId] = playerid;
	tVehicles[pvData[vid][pv_vid]][vo_pvid] = vid;
	tVehicles[pvData[vid][pv_vid]][vo_static] = false;
	tVehicles[pvData[vid][pv_vid]][vo_color][0] = pvData[vid][pv_color][0];
	tVehicles[pvData[vid][pv_vid]][vo_color][1] = pvData[vid][pv_color][1];
	
	new cccengine, ccclights, cccalarm, cccdoors, cccbonnet, cccboot, cccobjective;
    GetVehicleParamsEx(pvData[vid][pv_vid], cccengine, ccclights, cccalarm, cccdoors, cccbonnet, cccboot, cccobjective);
	SetVehicleParamsEx(pvData[vid][pv_vid], cccengine, ccclights, cccalarm, 0, cccbonnet, cccboot, cccobjective);
	
	SetVehicleParamsForPlayer(pvData[vid][pv_vid], playerid, 0, 0);
	vehicleDoorState[pvData[vid][pv_vid]] = 1;
	vehicleDoorOwner[pvData[vid][pv_vid]] = playerid;
	return 1;
}

stock pv_OnVehicleOwnerLogin(playerid)
{
	if(gpVehicleid[playerid]>=0 && pvData[gpVehicleid[playerid]][pv_owner] == Player[playerid][uID])
	{
		if(pvData[gpVehicleid[playerid]][pv_spawned] && pvData[gpVehicleid[playerid]][pv_modelid])
		{
			printf("step 2 - ok.");
			pv_SpawnVehicle(playerid);
			SCM(playerid,COLOR_INFO,"Twój prywatny pojazd czeka na Ciebie w miejscu, w którym go zostawi³eœ. Aby go przywo³aæ u¿yj /mp");		
		}
	}
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(gpVehicleid[playerid]>=0 && logged[playerid]) 
	{
		new vid = gpVehicleid[playerid];
		
		new buf[255], Float:vP[4], vcomp[60];
		
		GetVehiclePos(pvData[vid][pv_vid], vP[0], vP[1], vP[2]);
		GetVehicleZAngle(pvData[vid][pv_vid], vP[3]);
		
		for(new i=0;i<=13;i++) 
		{
			pvData[vid][pv_components][i]=0;
			pvData[vid][pv_components][i]=GetVehicleComponentInSlot(pvData[vid][pv_vid], i);
			format(vcomp,sizeof vcomp,"%s%s%d", vcomp, (strlen(vcomp)>0 ? (":") : ("")), pvData[vid][pv_components][i]);
		}
		format(buf,sizeof(buf),"UPDATE priv_vehicles SET x='%4.3f', y='%4.3f', z='%3.3f', rot='%3.2f', color1='%d', color2='%d', paintjob='%d', mods='%s', przebieg='%.3f', carlock='%d' WHERE uid = '%d'", 
			vP[0], vP[1], vP[2], vP[3], tVehicles[pvData[vid][pv_vid]][vo_color][0], tVehicles[pvData[vid][pv_vid]][vo_color][1], tVehicles[pvData[vid][pv_vid]][vo_paintjob], vcomp, pvData[vid][pv_mileage], !!pvData[vid][pv_lock], Player[playerid][uID]);
		mysql_query(buf);
		DestroyDynamic3DTextLabel(pvData[vid][pv_label]);
		//DestroyVehicle(pvData[vid][pv_vid]);
		tVehicles[pvData[vid][pv_vid]][vo_private] = true;
		tVehicles[pvData[vid][pv_vid]][vo_owningPlayerId] = INVALID_PLAYER_ID;
		tVehicles[pvData[vid][pv_vid]][vo_pvid] = vid;
	}
}

stock pv_ZapiszPojazd(playerid, bool:posplayer = false)
{
	if(!logged[playerid] || gpVehicleid[playerid]==-1) return 0;
	
	new Float:vP[4];
	new vid = gpVehicleid[playerid];
	
	if(posplayer)
	{
		GetPlayerPos(playerid, vP[0], vP[1], vP[2]);
		GetPlayerFacingAngle(playerid, vP[3]);
	} 
	else {
		GetVehiclePos(pvData[vid][pv_vid], vP[0], vP[1], vP[2]);
		GetVehicleZAngle(pvData[vid][pv_vid], vP[3]);
	}
	new buf[255], vcomp[60];

	for(new i=0;i<=13;i++) 
	{
		pvData[vid][pv_components][i]=0;
		pvData[vid][pv_components][i]=GetVehicleComponentInSlot(pvData[vid][pv_vid], i);
		format(vcomp,sizeof vcomp,"%s%s%d", vcomp, (strlen(vcomp)>0 ? (":") : ("")), pvData[vid][pv_components][i]);
	}
	format(buf,sizeof(buf),"UPDATE priv_vehicles SET x='%4.3f', y='%4.3f', z='%3.3f', rot='%3.2f', color1='%d', color2='%d', paintjob='%d', mods='%s', przebieg='%.3f', carlock='%d' WHERE uid = '%d'", 
		vP[0], vP[1], vP[2], vP[3], tVehicles[pvData[vid][pv_vid]][vo_color][0], tVehicles[pvData[vid][pv_vid]][vo_color][1], tVehicles[pvData[vid][pv_vid]][vo_paintjob], vcomp, pvData[vid][pv_mileage], !!pvData[vid][pv_lock], Player[playerid][uID]);
	mysql_query(buf);
	
	SCM(playerid, COLOR_INFO, "Pojazd zosta³ zapisany. U¿yj /mp aby go przywo³aæ!");
	
	pvData[vid][pv_spawned] = true;
	pvData[vid][pv_SpawnPos][0] = vP[0];
	pvData[vid][pv_SpawnPos][1] = vP[1];
	pvData[vid][pv_SpawnPos][2] = vP[2];
	pvData[vid][pv_SpawnPos][3] = vP[3];
	pvData[vid][pv_color][0] = tVehicles[pvData[vid][pv_vid]][vo_color][0];
	pvData[vid][pv_color][1] = tVehicles[pvData[vid][pv_vid]][vo_color][1];
	pvData[vid][pv_paintjob] = tVehicles[pvData[vid][pv_vid]][vo_paintjob];
	
	if(!tVehicles[pvData[vid][pv_vid]][vo_static] && !tVehicles[pvData[vid][pv_vid]][vo_private])
	{
		DestroyVehicle(pvData[vid][pv_vid]);
	}
	else
	{
		SetVehicleToRespawn(pvData[vid][pv_vid]);
	}
	
	pv_SpawnVehicle(playerid);
	return 1;
}

stock pv_findVehicleByOwnerID(accountid)
{
	for(new i = 0; i < sizeof(pvData); i++)
	{
		if(pvData[i][pv_owner] == accountid) return i;
	}
	return -1;
}

CMD:mp(playerid, params[])
{
	if(pAttraction[playerid] == 1 || GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return SCM(playerid, COLOR_ERROR, "Nie mo¿esz tego teraz zrobiæ.");
	if(!logged[playerid]) return SCM(playerid, COLOR_ORANGE, "Zapisywanie i przywo³ywanie pojazdu jest mozliwe tylko dla zarejestrowanych graczy.");
	
	new vid = pv_findVehicleByOwnerID(Player[playerid][uID]);
	if(vid<0) return SCM(playerid, COLOR_ERROR, "Nie posiadasz prywatnego pojazdu.");
	if(IsPlayerInAnyVehicle(playerid)) return SCM(playerid, COLOR_ERROR, "Najpierw wysi¹dŸ z pojazdu...");
	if(!pvData[vid][pv_spawned]) return SCM(playerid, COLOR_ERROR, "Nie posiadasz zapisanego pojazdu.");
	
	pv_SpawnVehicle(playerid);
	
	new Float:pP[4];
	GetVehiclePos(pvData[vid][pv_vid], pP[0], pP[1], pP[2]);
	SetPlayerInterior(playerid, 0);
	SetPlayerPos(playerid, pP[0], pP[1], pP[2]);
	PutPlayerInVehicle(playerid, pvData[vid][pv_vid], 0);
	return 1;
}

stock privcar_OnPlayerDisconnect(playerid) 
{
	pv_OnPVOwnerDisconnect(playerid);
	KillTimer(GetPVarInt(playerid, "pv_timer"));
}

// functions
/*
#define PI 3.1415

stock Float:deg2rad( Float:deg) {
	return ( deg * PI / 180);
}

stock Float:rad2deg( Float:rad) {
	return ( rad * 180 / PI);
}

stock Float:distanceMileage( Float:start_x, Float:start_y, Float:current_x, Float:current_y) {
	new Float:theta, Float:dist;
	theta = start_y - current_y;
	dist = floatsin(deg2rad(start_x)) * floatsin(deg2rad(current_x)) * floatcos(deg2rad(start_y)) * floatcos(deg2rad(current_y)) * floatcos(deg2rad(theta));
	dist = acos(dist);
	dist = rad2deg(dist);
	dist = dist * 60 * 1.515;
	dist = dist * 1.6093;
	return (dist);
}*/

stock Float:GetPlayerOrVehicleSpeed( playerid) {
	static Float:vector_speed[4], vehicleid = INVALID_VEHICLE_ID;
	
	(vehicleid = GetPlayerVehicleID( playerid)) && GetVehicleVelocity( vehicleid, vector_speed[0], vector_speed[1], vector_speed[2]) || GetPlayerVelocity( playerid, vector_speed[0], vector_speed[1], vector_speed[2]);

	vector_speed[3] = floatsqroot( floatpower( floatabs( vector_speed[0]), 2.0) + floatpower( floatabs( vector_speed[1]), 2.0) + floatpower( floatabs( vector_speed[2]), 2.0)) * 179.2862;
	return vector_speed[3];
}

forward privVehicles_refresh( playerid);
public privVehicles_refresh( playerid) {
	static buf[90],nick[24],vehicleid;
	vehicleid = GetPlayerVehicleID(playerid);
	GetPlayerName(playerid,nick,24);
	
	if (vehicleid == pvData[gpVehicleid[playerid]][pv_vid] && GetPlayerOrVehicleSpeed( playerid) > 0) {
		pvData[gpVehicleid[playerid]][pv_mileage] += floatround(GetVehicleDistanceFromPoint(GetPlayerVehicleID(playerid), pvData[gpVehicleid[playerid]][pv_dist][0], pvData[gpVehicleid[playerid]][pv_dist][1], pvData[gpVehicleid[playerid]][pv_dist][2]))*0.001;
		GetVehiclePos(pvData[gpVehicleid[playerid]][pv_vid], pvData[gpVehicleid[playerid]][pv_dist][0], pvData[gpVehicleid[playerid]][pv_dist][1], pvData[gpVehicleid[playerid]][pv_dist][2]);
		format(buf,sizeof(buf),"{eaeaea}%s\n{D9C2AD}Wlasciciel: %s\nPrzebieg: %.3fkm", pvData[gpVehicleid[playerid]][pv_carname], nick, pvData[gpVehicleid[playerid]][pv_mileage]);
		UpdateDynamic3DTextLabelText(pvData[gpVehicleid[playerid]][pv_label], 0xD9C2ADFF, buf);
	}
}

forward loadPrivateVehicles(); 
public loadPrivateVehicles() {
	new buf[255], veh_component[60], i = 0;
	format( buf, sizeof( buf), "SELECT pv.name_car, pv.uid, pv.przebieg, pv.carlock, pv.modelid, pv.x, pv.y, pv.z, pv.rot, pv.color1, pv.color2, pv.paintjob, pv.mods, IFNULL(DATEDIFF(pv.datetime_lastused, NOW()), '-1') FROM priv_vehicles pv LIMIT %d",MAX_PRIV_VEHICLES);
	mysql_query( buf);
	mysql_store_result();
	while( mysql_fetch_row( buf, "|")) {
		//print(buf);
		sscanf( buf, "p<|>s[32]dfddffffddds[60]d", 
			pvData[i][pv_carname],
			pvData[i][pv_owner],
			pvData[i][pv_mileage],
			pvData[i][pv_lock],
			pvData[i][pv_modelid],
			pvData[i][pv_SpawnPos][0],
			pvData[i][pv_SpawnPos][1],
			pvData[i][pv_SpawnPos][2],
			pvData[i][pv_SpawnPos][3],
			pvData[i][pv_color][0],
			pvData[i][pv_color][1],
			pvData[i][pv_paintjob],
			veh_component,
			pvData[i][pv_dayUsedLast]
		);
		
		if(pvData[i][pv_modelid]>0) {
			pvData[i][pv_spawned] = true;
		} else {
			pvData[i][pv_spawned] = false;
		}
		
		if(pvData[i][pv_spawned] && pvData[i][pv_vid] != INVALID_VEHICLE_ID && GetVehicleModel(pvData[i][pv_vid]) != pvData[i][pv_modelid])	
		{
			tVehicles[pvData[i][pv_vid]][vo_private]=false;
			tVehicles[pvData[i][pv_vid]][vo_owningPlayerId]=INVALID_PLAYER_ID;
			pvData[i][pv_vid]=INVALID_VEHICLE_ID;
		}
		
		if (strcmp( veh_component, "brak") != 0) {
			sscanf( veh_component, "p<:>dddddddddddddd",
				pvData[i][pv_components][0], 
				pvData[i][pv_components][1], 
				pvData[i][pv_components][2], 
				
				pvData[i][pv_components][3], 
				pvData[i][pv_components][4], 
				pvData[i][pv_components][5], 
				
				pvData[i][pv_components][6], 
				pvData[i][pv_components][7], 
				pvData[i][pv_components][8], 
				
				pvData[i][pv_components][9], 
				pvData[i][pv_components][10], 
				pvData[i][pv_components][11],
				pvData[i][pv_components][12],
				pvData[i][pv_components][13]
			);
		}
		
		if(pvData[i][pv_lock]>!!0)
		{
			pvData[i][pv_lock] = true;
		} else {
			pvData[i][pv_lock] = false;
		}
		
		//printf("modelid: %d", pvData[i][pv_modelid]);
		// = CreateVehicle( pvData[i][pv_modelid], pvData[i][pv_pos][0], pvData[i][pv_pos][1], pvData[i][pv_pos][2], pvData[i][pv_pos][3], pvData[i][pv_colors][0], pvData[i][pv_colors][1], 99*99);
		i++;
	}
	
	new bool:ponownie_wywolaj_ladowanie = false;
	for( ; i>=0; i--) {
		if(pvData[i][pv_dayUsedLast] < -14) {
			format(buf,sizeof(buf),"DELETE FROM priv_vehicles WHERE uid = %d", pvData[i][pv_owner]);
			mysql_query(buf);
			pvData[i][pv_owner] = -1;
			pvData[i][pv_dayUsedLast] = 0;
			DestroyVehicle(pvData[i][pv_vid]);
			DestroyDynamic3DTextLabel( pvData[i][pv_label]);
			ponownie_wywolaj_ladowanie=true;
		}
	}
	if (ponownie_wywolaj_ladowanie) {
		SetTimer("loadPrivateVehicles",500,false);
	}
	mysql_free_result();
	printf("wczytano %d pojazdow", i);
}

/*CMD:refreshid(playerid) {
	new buff[128], nicfk[24];
	
	GetPlayerName(playerid,nicfk,24);
	format(buff,sizeof(buff),"SELECT id FROM fg_players WHERE Nick='%s' LIMIT 1;", nicfk);
	mysql_query( buff);
	mysql_store_result();
	playerAccountID[playerid] = mysql_fetch_int();
	mysql_free_result();
	
	format(buff,sizeof(buff), "id konta: %d", playerAccountID[playerid]);
	SendClientMessage(playerid,-1,buff);
	return 1;
}*/
/*
CMD:buypv(playerid) {
	if(!Registered[playerid]){
		SendClientMessage(playerid,COLOR_RED2,"››› Nie jesteœ zarejestrowany/a!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	new bool:mapojazd=false;
	for( new i = MAX_PRIV_VEHICLES; i>=0; i--) {
		if( Player[playerid][uID] == pvData[i][pv_userid]) {
			mapojazd=true;
			break;
		}
	}
	if(mapojazd) {
		return SendClientMessage(playerid,-1,"Jesteœ ju¿ w posiadaniu prywatnego pojazdu.");
	} else {
		DestroySelectionMenu(playerid);
               
		SetPVarInt(playerid, "vspawner_active", 1);
		//SetPVarInt(playerid, "vspawner_page", 0); // will reset the page back to the first
           
		CreateSelectionMenu(playerid);
		SelectTextDraw(playerid, 0xACCBF1FF);
	}
	return 1;
}*/

#define PRIVATE_CAR_MAIN 15570
#define PRIVATE_CAR_OPIS 15571
#define PRIVATE_CAR_DOORS 15572


hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[]) 
{
	switch(dialogid) 
	{
		case PRIVATE_CAR_MAIN: {
		
			if(!response) return 1;
			switch(listitem)
			{
				case 0: return ShowPlayerDialog(playerid, PRIVATE_CAR_OPIS, DIALOG_STYLE_INPUT, "Prywatny pojazd > Opis", "WprowadŸ swój opis pojazdu:", "Zmieñ", "Anuluj");
				case 1: {
					new buf[160], lockable_vehicle[20];
					
					if(pvData[gpVehicleid[playerid]][pv_lock]>!!0) {
						pvData[gpVehicleid[playerid]][pv_lock] = false;
					} else {
						pvData[gpVehicleid[playerid]][pv_lock] = true;
					}
					
					format(lockable_vehicle,20, pvData[gpVehicleid[playerid]][pv_lock]? ("Otwórz pojazd"): ("Zamknij pojazd"));
					format(buf,sizeof(buf), "Zmieñ opis pojazdu\n%s\nPrzywo³aj pojazd\nZaparkuj pojazd\n{FF0000}Zmieñ pojazd (wkrótce)\n{FF0000}Zamontuj modyfikacje (wkrótce)", lockable_vehicle);
					
					//format(lockable_vehicle,20, pvData[gpVehicleid[playerid]][pv_lock]? ("{9BFF67}otwarte"): ("{ff0000}zamkniête"));
					//format(buf,sizeof(buf), "Wybierz status drzwi:\nAktualny status: %s", lockable_vehicle);
					return ShowPlayerDialog(playerid,PRIVATE_CAR_MAIN,DIALOG_STYLE_LIST, "Prywatny pojazd > Zarz¹dzanie", buf, "Wybierz", "Anuluj");
				}
				case 2: {
					/*new Float:x, Float:y, Float:z, Float:ang;
					GetPlayerPos(playerid, x, y, z);
					GetPlayerFacingAngle(playerid, ang);
					
					pvData[gpVehicleid[playerid]][pv_pos][0] = z;
					pvData[gpVehicleid[playerid]][pv_pos][1] = y;
					pvData[gpVehicleid[playerid]][pv_pos][2] = z;
					pvData[gpVehicleid[playerid]][pv_pos][3] = ang;
			
					SetVehiclePos(pvData[gpVehicleid[playerid]][pv_vid], x+2.0, y+2.0, z+1.0);
					SetVehicleZAngle(pvData[gpVehicleid[playerid]][pv_vid], ang+random(10));
					SCM(playerid, -1, " Przywo³a³eœ(aœ) swój prywatny pojazd.");*/
					return cmd_mp(playerid, "");
				}
				case 3: {
					//if (Player[playerid][uID]<0) return;
					/*new buf[255], Float:pos[4], vcomp[60];

					GetVehiclePos(playerPrivVehicle[playerid], pos[0], pos[1], pos[2]);
					GetVehicleZAngle(playerPrivVehicle[playerid], pos[3]);
					for(new i=0;i<=13;i++) {
						pvData[gpVehicleid[playerid]][pv_components][i]=0;
						pvData[gpVehicleid[playerid]][pv_components][i]=GetVehicleComponentInSlot(playerPrivVehicle[playerid],i);
						format(vcomp,sizeof vcomp,"%s%s%d", vcomp, (strlen(vcomp)>0 ? (":") : ("")), pvData[gpVehicleid[playerid]][pv_components][i]);
					}
					format(buf,sizeof(buf),"UPDATE priv_vehicles SET x='%4.4f', y='%4.4f', z='%3.3f', rot='%3.2f', color1='%d', color2='%d', paintjob='%d', mods='%s', przebieg='%.3f', carlock='%d' WHERE uid = '%d'", 
						pos[0], pos[1], pos[2], pos[3], pvData[gpVehicleid[playerid]][pv_colors][0], pvData[gpVehicleid[playerid]][pv_colors][1], pvData[gpVehicleid[playerid]][pv_paintjob], vcomp, pvData[gpVehicleid[playerid]][pv_mileage], !!pvData[gpVehicleid[playerid]][pv_lock], Player[playerid][uID]);
					mysql_query(buf);
					SCM(playerid,COLOR_INFO," * Pomyœlnie zaparkowa³eœ swój pojazd.");*/
					return pv_ZapiszPojazd(playerid, true);
				}
				
				default: return 1;
			}
		}
		case PRIVATE_CAR_OPIS: {
			if(!response) return 1;
			
			if(!inputtext[0] || strlen(inputtext) < 3 && strlen(inputtext) > 32) {
				return ShowPlayerDialog(playerid, PRIVATE_CAR_OPIS, DIALOG_STYLE_INPUT, "Prywatny pojazd > Opis", "WprowadŸ swój opis pojazdu:\n\n{ff0000}* Tekst jest zbyt krótki/d³ugi", "Zmieñ", "Anuluj");
			}
			
			new pojazd = gpVehicleid[playerid];
			format(pvData[pojazd][pv_carname], 32, inputtext);
			new buf[128];
			format(buf,sizeof(buf), " Zmieni³eœ opis pojazdu na: %s", inputtext);
			SCM(playerid, COLOR_INFO, buf);
			
			for(new i, j = strlen(inputtext); i!=j; i++) 
			{
				switch(tolower(inputtext[i]))
				{
					case 'ê': inputtext[i] = 'e';
					case 'ó': inputtext[i] = 'o';
					case '¿': inputtext[i] = 'z';
					case 'æ': inputtext[i] = 'c';
					case '³': inputtext[i] = 'l';
					case 'ñ': inputtext[i] = 'n';
					case '¹': inputtext[i] = 'a';
					case 'Ÿ': inputtext[i] = 'z';
				}
			}
			
			format(buf,sizeof(buf),"{eaeaea}%s\n{D9C2AD}Wlasciciel: %s\nPrzebieg: %.3fkm", pvData[gpVehicleid[playerid]][pv_carname], PlayerName(playerid), pvData[gpVehicleid[playerid]][pv_mileage]);
			UpdateDynamic3DTextLabelText( pvData[gpVehicleid[playerid]][pv_label], 0xD9C2ADFF, buf);
			
			new dsc_esc[32+6];
			mysql_real_escape_string(inputtext, dsc_esc);
			format(buf,sizeof(buf),"UPDATE priv_vehicles SET name_car = '%s' WHERE uid = '%d'", dsc_esc, Player[playerid][uID]);
			mysql_query(buf);
		}
		case PRIVATE_CAR_DOORS: {
			if(!response) {
				pvData[gpVehicleid[playerid]][pv_lock] = false;
				return SCM(playerid, COLOR_INFO, " Zaktualizowa³eœ status drzwi na {9BFF67}otwarte.");
			} 
			else {
				pvData[gpVehicleid[playerid]][pv_lock] = true;
				return SCM(playerid, COLOR_INFO, " Zaktualizowa³eœ status drzwi na {ff0000}zamkniête.");
			}
		}
	}
	return 1;
}
	
CMD:pcar(playerid) 
{
	if(!Registered[playerid]){
		SendClientMessage(playerid,COLOR_RED2," * Nie jesteœ zarejestrowany/a!");
        PlayerPlaySound(playerid,1085,0.0,0.0,0.0);
		return 1;
	}
	if( Player[playerid][uID]<0) return SendClientMessage(playerid,-1," * Wyst¹pi³ b³¹d z odczytaniem twojego systemowego id. Aby to naprawiæ: po³¹cz siê ponownie z serwerem (relog)");
	if( gpVehicleid[playerid]<0) {
		if( Respekt[playerid] < 3500 || Respekt[playerid] < 1000 && IsVIP(playerid)) {
			if( IsVIP(playerid)) {
				return SendClientMessage(playerid,-1,"Aby zakupiæ prywatny pojazd potrzebujesz 1000exp.");
			} else {
				return SendClientMessage(playerid,-1,"Aby zakupiæ prywatny pojazd potrzebujesz 3500xp.");
			}
		}
		SendClientMessage(playerid,-1,"Wybierz pojazd z listy.");
		DestroySelectionMenu(playerid);
               
		SetPVarInt(playerid, "vspawner_active", 1);
		//SetPVarInt(playerid, "vspawner_page", 0); // will reset the page back to the first
		
		HidePlayerPasek(playerid);
		CreateSelectionMenu(playerid);
		SelectTextDraw(playerid, 0xACCBF1FF);
		return 1;
	}
	//if( pvData[gpVehicleid[playerid]][pv_userid] != Player[playerid][uID])
	
	new lockable_vehicle[16], string[160];
	format(lockable_vehicle,16, pvData[gpVehicleid[playerid]][pv_lock]? ("Otwórz pojazd"): ("Zamknij pojazd"));
	format(string,sizeof(string), "Zmieñ opis pojazdu\n%s\nPrzywo³aj pojazd\nZaparkuj pojazd\n{FF0000}Zmieñ pojazd (wkrótce)\n{FF0000}Zamontuj modyfikacje (wkrótce)", lockable_vehicle);
	ShowPlayerDialog(playerid,PRIVATE_CAR_MAIN,DIALOG_STYLE_LIST, "Prywatny pojazd > Zarz¹dzanie", string, "Wybierz", "Anuluj");
	return 1;
}