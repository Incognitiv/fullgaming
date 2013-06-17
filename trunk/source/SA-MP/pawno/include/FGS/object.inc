#define file "object.txt"
new logiobiektow[128];
#define FormatObjectLog(%0,%1) format(logiobiektow,128,%0,%1), ObjectLog(logiobiektow)
stock LoadFromFile(filename[], &ret_vehicles = 0, &ret_objects = 0)
{
	if(!fexist(filename))
		return FormatObjectLog("Nie odnaleziono pliku \"%s\"", filename), 0;
	new string[128], line, File:fLoader = fopen(filename, io_read);
	while(fread(fLoader,string))
	{
	    line++;
	    if(WarningsDetector(string, line)) continue;
	    string[strfind(string, ");")] = EOS;
		if(strfind(string, "AddStaticVehicle(") != -1)
		{
		    new d[3], Float:f[4];
    		sscanf(string,"{p<(>s[128]}p<,>iffffii",d[0],f[0],f[1],f[2],f[3],d[1],d[2]);
			AddStaticVehicle(d[0],f[0],f[1],f[2],f[3],d[1],d[2]);
			ret_vehicles++;
			continue;
		}
		if(strfind(string, "AddStaticVehicleEx(") != -1)
		{
		    new d[4], Float:f[4];
    		sscanf(string,"{p<(>s[128]}p<,>iffffiii",d[0],f[0],f[1],f[2],f[3],d[1],d[2],d[3]);
			AddStaticVehicleEx(d[0],f[0],f[1],f[2],f[3],d[1],d[2],d[3]);
			ret_vehicles++;
			continue;
		}
		if(strfind(string, "CreateVehicle(") != -1)
		{
		    new d[4], Float:f[4];
    		sscanf(string,"{p<(>s[128]}p<,>iffffiii",d[0],f[0],f[1],f[2],f[3],d[1],d[2],d[3]);
			CreateVehicle(d[0],f[0],f[1],f[2],f[3],d[1],d[2],d[3]);
			ret_vehicles++;
			continue;
		}
    	if(strfind(string, "CreateObject(") != -1)
    	{
    		new d[1], Float:f[6];
    		sscanf(string,"{p<(>s[128]}p<,>iffffff",d[0],f[0],f[1],f[2],f[3],f[4],f[5]);
    		CreateObject(d[0],f[0],f[1],f[2],f[3],f[4],f[5]);
    		ret_objects++;
    		continue;
    	}  
    	if(strfind(string, "CreateDynamicObject(") != -1)
    	{
    		new d[1], Float:f[6];
    		sscanf(string,"{p<(>s[128]}p<,>iffffff",d[0],f[0],f[1],f[2],f[3],f[4],f[5]);
    		CreateDynamicObject(d[0],f[0],f[1],f[2],f[3],f[4],f[5]);
    		ret_objects++;
    		continue;
    	}
    }
	fclose(fLoader);
	return 1;
}
stock LoadFromFileObject(filename[], &ret_objects = 0)
{
	if(!fexist(filename))
		return FormatObjectLog("Nie odnaleziono pliku \"%s\"", filename), 0;
	new string[128], line, File:fLoader = fopen(filename, io_read);
	while(fread(fLoader,string))
	{
	    line++;
	    if(WarningsDetector(string, line)) continue;
	    string[strfind(string, ");")] = EOS;
    	if(strfind(string, "CreateObject(") != -1)
    	{
    		new d[1], Float:f[6];
    		sscanf(string,"{p<(>s[128]}p<,>iffffff",d[0],f[0],f[1],f[2],f[3],f[4],f[5]);
    		CreateObject(d[0],f[0],f[1],f[2],f[3],f[4],f[5]);
    		ret_objects++;
    		continue;
    	}  
    	if(strfind(string, "CreateDynamicObject(") != -1)
    	{
    		new d[1], Float:f[6];
    		sscanf(string,"{p<(>s[128]}p<,>iffffff",d[0],f[0],f[1],f[2],f[3],f[4],f[5]);
    		CreateDynamicObject(d[0],f[0],f[1],f[2],f[3],f[4],f[5]);
    		ret_objects++;
    		continue;
    	}
    }
	fclose(fLoader);
	return 1;
}

stock WarningsDetector(const string[], line)
{
	if(!strcmp(string, "\r\n"))
		return 1;
	if(!strfind(string, "//"))
		return 1;
    if(strfind(string, ");") == -1 && line != 0) //
		return SetTimerEx("WarnPrint", 400, false, "i", line);
	return 0;
}

forward WarnPrint(line);
public WarnPrint(line)
	return FormatObjectLog("Warning detected in line %d!", line);
	
stock ObjectLog(string[])
{
	new File:Log;
	Log = fopen("logs_objects.txt", io_append);

	new String[255], LTime[6];
	gettime(LTime[0], LTime[1]);
	getdate(LTime[2], LTime[3], LTime[4]);
	format(String, sizeof(String), "\n[%d/%d/%d %d:%d] %s \n", LTime[4], LTime[3], LTime[2], LTime[0], LTime[1], string);

	fwrite(Log, String);
	fclose(Log);
	return 1;
}
