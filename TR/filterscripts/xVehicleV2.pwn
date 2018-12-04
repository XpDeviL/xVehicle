/*

                                                                                                                                         
                                                                                                                     
                   VVVVVVVV           VVVVVVVV               hhhhhhh               iiii                      lllllll                     
                   V::::::V           V::::::V               h:::::h              i::::i                     l:::::l                     
                   V::::::V           V::::::V               h:::::h               iiii                      l:::::l                     
                   V::::::V           V::::::V               h:::::h                                         l:::::l                     
xxxxxxx      xxxxxxxV:::::V           V:::::V eeeeeeeeeeee    h::::h hhhhh       iiiiiii     cccccccccccccccc l::::l     eeeeeeeeeeee    
 x:::::x    x:::::x  V:::::V         V:::::Vee::::::::::::ee  h::::hh:::::hhh    i:::::i   cc:::::::::::::::c l::::l   ee::::::::::::ee  
  x:::::x  x:::::x    V:::::V       V:::::Ve::::::eeeee:::::eeh::::::::::::::hh   i::::i  c:::::::::::::::::c l::::l  e::::::eeeee:::::ee
   x:::::xx:::::x      V:::::V     V:::::Ve::::::e     e:::::eh:::::::hhh::::::h  i::::i c:::::::cccccc:::::c l::::l e::::::e     e:::::e
    x::::::::::x        V:::::V   V:::::V e:::::::eeeee::::::eh::::::h   h::::::h i::::i c::::::c     ccccccc l::::l e:::::::eeeee::::::e
     x::::::::x          V:::::V V:::::V  e:::::::::::::::::e h:::::h     h:::::h i::::i c:::::c              l::::l e:::::::::::::::::e 
     x::::::::x           V:::::V:::::V   e::::::eeeeeeeeeee  h:::::h     h:::::h i::::i c:::::c              l::::l e::::::eeeeeeeeeee  
    x::::::::::x           V:::::::::V    e:::::::e           h:::::h     h:::::h i::::i c::::::c     ccccccc l::::l e:::::::e           
   x:::::xx:::::x           V:::::::V     e::::::::e          h:::::h     h:::::hi::::::ic:::::::cccccc:::::cl::::::le::::::::e          
  x:::::x  x:::::x           V:::::V       e::::::::eeeeeeee  h:::::h     h:::::hi::::::i c:::::::::::::::::cl::::::l e::::::::eeeeeeee  
 x:::::x    x:::::x           V:::V         ee:::::::::::::e  h:::::h     h:::::hi::::::i  cc:::::::::::::::cl::::::l  ee:::::::::::::e       .d8888b.
xxxxxxx      xxxxxxx           VVV            eeeeeeeeeeeeee  hhhhhhh     hhhhhhhiiiiiiii    ccccccccccccccccllllllll    eeeeeeeeeeeeee      d88P  Y88b 
																																					888 
																																	888  888      .d88P 
																																	888  888  .od888P"  
																																	Y88  88P d88P"      
																																	 Y8bd8P  888"       
																																	  Y88P   888888888  
		xVehicle v2 - Ara� Sistemi // by XpDeviL
		
	~ �zellikler
	
	 * Birden fazla ara� sat�n alabilirsiniz.
	 * Arac�n�z�n anahtar�n� ba�kas�na verebilirsiniz.
	 * Arac�n�z� garaj�n�za koyarak ortal�kta durmamas�n� sa�layabilirsiniz.
	 * Arac�n�z� bulamad���n�z zaman 'Arac�m Nerede?' �zelli�i ile arac�n�z� haritada i�aretleyebilirsiniz.
	 * H�zl� park �zelli�i ile arac�n�zdan indi�iniz anda otomatik park etmesini sa�layabilrisiniz.
	 * Arac�n�z� istedi�iniz zaman ba�ka bir oyuncuya veya galeriye satabilirsiniz.
	 * Sahibi oldu�unuz veya anahtar� sizde olan t�m ara�lara '/a' komutu ile eri�ebilirsiniz.
	 
		Detayl� tan�t�m i�in: http://xpdevil.com/2017/04/04/fs-xvehicle-v2-arac-sistemi-mysql
		Hepsi ve daha fazlas� i�in: http://xpdevil.com
		
*/
																																	  
#include <a_samp>
#include <a_mysql>
#include <zcmd>
#include <sscanf2>
#include <YSI\y_iterate>

// MySQL Bilgileri:
#define		SQL_HOST			"localhost"
#define		SQL_USER			"root"
#define		SQL_PASSWORD		""
#define		SQL_DBNAME			"xfr_testdb"
//-----------------

// Ayarlamalar (Bu ayarlar� istedi�iniz gibi de�i�tirebilirsiniz):
#define OYUNCU_MAX_ARAC	5	// Bir oyuncunun en fazla alabilece�i ara� say�s�.
#define GARAJ_MAX_ARAC	3	// Bir oyuncunun garaja en fazla koyabilece�i ara� say�s�.
//-----------------

// Tan�mlamalar:
#define XV_DIALOGID 3500 // E�er dialog ID'leri modunuzda ba�ka bir dialog ile �ak���rsa bu ID'yi de�i�tirmeniz yeterli olacakt�r.

enum xv_data
{
	xv_Veh,
	xv_ModelID,
	xv_Renk[2],
	Float:xv_Pos[4],
	xv_Paintjob,
	xv_Parca[14],
	xv_Sahip[24],
	xv_Plaka[8],
	xv_Garajda,
	Text3D:xv_Text,
	xv_Fiyat,
	xv_HizliPark
};

new 
	xVehicle[MAX_VEHICLES][xv_data],
	xVeh[MAX_VEHICLES],
	offerTimer[MAX_PLAYERS],
	Iterator:xVehicles<MAX_VEHICLES>,
	Iterator:xVehicleKeys<MAX_PLAYERS, MAX_VEHICLES>,	
	MySQL:mysqlB
;

new VehicleNames[][] =
{
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel",
	"Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
	"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BFInjection",
	"Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
	"Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
	"Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral",
	"Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
	"Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "BerkleysRCVan",
	"Skimmer", "PCJ-600", "Faggio", "Freeway", "RCBaron", "RCRaider", "Glendale",
	"Oceanic","Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy",
	"Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX",
	"Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "NewsChopper",
	"Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking",
	"BlistaCompact", "PoliceMaverick", "Boxvillde", "Benson", "Mesa", "RCGoblin",
	"HotringRacerA", "HotringRacerB", "BloodringBanger", "Rancher", "SuperGT",
	"Elegant", "Journey", "Bike", "MountainBike", "Beagle", "Cropduster", "Stunt",
 	"Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra",
 	"FCR-900", "NRG-500", "HPV1000", "CementTruck", "TowTruck", "Fortune",
 	"Cadrona", "FBITruck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer",
 	"Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent",
    "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo",
	"Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite",
	"Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratium",
	"Elegy", "Raindance", "RCTiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "FreightFlat", "StreakCarriage", "Kart", "Mower", "Dune", "Sweeper",
	"Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
	"News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
	"FreightBox", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "LSPD",
 	"SFPD", "LVPD", "PoliceRanger", "Picador", "S.W.A.T", "Alpha",
 	"Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs", "Boxville",
 	"Tiller", "UtilityTrailer"
};

public OnFilterScriptInit()
{

	print("+----------------------------------------------------------------------+");
	print("|                                                                      |");
	print("|            888     888          888      d8b          888            |");
	print("|            888     888          888      Y8P          888            |");
	print("|            888     888          888                   888            |");
	print("|   888  888 Y88b   d88P  .d88b.  88888b.  888  .d8888b 888  .d88b.    |");
	print("|   `Y8bd8P'  Y88b d88P  d8P  Y8b 888 '88b 888 d88P'    888 d8P  Y8b   |");
	print("|     X88K     Y88o88P   88888888 888  888 888 888      888 88888888   |");
	print("|   .d8''8b.    Y888P    Y8b.     888  888 888 Y88b.    888 Y8b.       |");
	print("|   888  888     Y8P      'Y8888  888  888 888  'Y8888P 888  'Y8888    |");
	print("|                                                                      |");
	print("+--------------------------------------------------+-------------------+");
	print("                                                   |           .d888b. |");
	print("                                                   |           VP  `8D |");
	print("                                                   |  Y8    8P    odD' |");
	print("                                                   |  `8b  d8'  .88'   |");
	print("                                                   |   `8bd8'  j88.    |");
	print("                                                   |     YP    888888D |");
	print("                                                   +-------------------+");

	print("[xVeh MySql] Veri tabanina baglaniliyor...");

	mysqlB = mysql_connect(SQL_HOST, SQL_USER, SQL_PASSWORD, SQL_DBNAME); 
	mysql_log(ALL); 
	if (mysql_errno(mysqlB) == 0) print("[xVeh MySql] Veri tabanina baglanti basarili!");
	else print("[xVeh MySql] Baglanti Basarisiz!\n\n[!!! xVehicle v2 Y�klenemedi !!!]\n\n");
	
	new query[1024];
	
	strcat(query, "CREATE TABLE IF NOT EXISTS `xVehicle` (\
	  `ID` int(11),\
	  `Sahip` varchar(48) default '',\
	  `Fiyat` int(11) default '0',\
	  `X` float default '0',\
	  `Y` float default '0',\
	  `Z` float default '0',\
	  `A` float default '0',\
	  `HizliPark` int(2) default '0',\
	  `Model` int(5) default '0',\
	  `Renk1` int(5) default '0',\
	  `Renk2` int(5) default '0',\
	  `Plaka` varchar(8),\
	  `Garajda` int(2) default '0',\
	  `PJ` int(5) default '-1',");
	  
	strcat(query, "`Parca1` int(8) default '0',\
	  `Parca2` int(8) default '0',\
	  `Parca3` int(8) default '0',\
	  `Parca4` int(8) default '0',\
	  `Parca5` int(8) default '0',\
	  `Parca6` int(8) default '0',\
	  `Parca7` int(8) default '0',\
	  `Parca8` int(8) default '0',");
	  
	  
	strcat(query, "`Parca9` int(8) default '0',\
	  `Parca10` int(8) default '0',\
	  `Parca11` int(8) default '0',\
	  `Parca12` int(8) default '0',\
	  `Parca13` int(8) default '0',\
	  `Parca14` int(8) default '0',\
	    PRIMARY KEY  (`ID`),\
		UNIQUE KEY `ID_2` (`ID`),\
		KEY `ID` (`ID`)\
		) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
		
	mysql_query(mysqlB, query);
	
	mysql_query(mysqlB, "CREATE TABLE IF NOT EXISTS `xVehicleKeys` (\
	  `AracID` int(11) NOT NULL,\
	  `Isim` varchar(24) NOT NULL\
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;");
	
	Iter_Add(xVehicles, 0);
	
	mysql_tquery(mysqlB, "SELECT * FROM `xVehicle`", "LoadxVehicles");
	return 1;
}

/* --[ Komutlar Ba�lang�� ]-- */

CMD:parket(playerid, params[])
{
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Bu komutu kullanabilmek i�in bir ara�ta olmal�s�n�z!");
	new xid = xVeh[GetPlayerVehicleID(playerid)];
	if(xid == 0) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Bu ara�, ara� sistemine kay�tl� olmad��� i�in park edemezsiniz!");
	if(xStrcmp(Isim(playerid), xVehicle[xid][xv_Sahip]) && !Iter_Contains(xVehicleKeys<playerid>, xid) && !IsPlayerAdmin(playerid)) return  SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Bu arac�n anahtar� sizde olmad��� i�in parkedemezsiniz!");
	if(xVehicle[xid][xv_HizliPark]) SendClientMessage(playerid, -1, "{00BD00}[!] {00FF00}Arac�n�z parkedildi! {FFFB93}H�zl� park �zelli�i devre d��� b�rak�ld�!");
	else SendClientMessage(playerid, -1, "{00BD00}[!] {00FF00}Arac�n�z parkedildi!");
	xVehicle[xid][xv_HizliPark] = 0;
	GetVehiclePos(GetPlayerVehicleID(playerid), xVehicle[xid][xv_Pos][0], xVehicle[xid][xv_Pos][1], xVehicle[xid][xv_Pos][2]);
	GetVehicleZAngle(GetPlayerVehicleID(playerid), xVehicle[xid][xv_Pos][3]);
	SavexVehicle(xid);
	return 1;
}

CMD:a(playerid, params[])
{
	if(IsPlayerInAnyVehicle(playerid) && xVeh[GetPlayerVehicleID(playerid)] != 0) ShowPlayerDialog(playerid, XV_DIALOGID+6, DIALOG_STYLE_LIST, "Ara� Men�s�", "{DCDC22}� {FFFB93}��inde Bulundu�um Ara�\n{DCDC22}� {FFFB93}Kendi Ara�lar�m\n{DCDC22}� {FFFB93}Anahtar� Bende Olan Ara�lar", "Se�", "Kapat");
	else ShowPlayerDialog(playerid, XV_DIALOGID+6, DIALOG_STYLE_LIST, "Ara� Men�s�", "{DCDC22}� {FFFB93}Kendi Ara�lar�m\n{DCDC22}� {FFFB93}Anahtar� Bende Olan Ara�lar", "Se�", "Kapat");
	return 1;
}

CMD:amenu(playerid, params[])
{
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Bu komutu yaln�zca adminler kullanabilir!");
	ShowPlayerDialog(playerid, XV_DIALOGID+16, DIALOG_STYLE_LIST, "xVehicle Admin Men�s�", "{DCDC22}� {FFFB93}Ara�lar� G�r\n{DCDC22}� {FFFB93}T�m Ara�lar� Yenile\n{DCDC22}� {FFFB93}Ara� Olu�tur", "Se�", "Kapat");
	return 1;
}

/* --[Komutlar Biti�]-- */

public OnPlayerConnect(playerid)
{
	SetPVarInt(playerid, "xv_teklif_id", INVALID_PLAYER_ID);
	SetPVarInt(playerid, "xv_teklif_gonderen", INVALID_PLAYER_ID);
	LoadxVehicleKeys(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(GetPVarInt(playerid, "xv_teklif_gonderen") != INVALID_PLAYER_ID)
	{
		new gonderen = GetPVarInt(playerid, "xv_teklif_gonderen");
		KillTimer(offerTimer[playerid]);
		SetPVarInt(gonderen, "xv_teklif_id", INVALID_PLAYER_ID);
		SendClientMessage(gonderen, -1, "{FF0000}[!] {DCDC22}Ara� satmay� teklif etti�iniz oyuncu oyundan ��kt��� i�in teklif iptal edildi.");
	}
	
	if(GetPVarInt(playerid, "xv_teklif_id") != INVALID_PLAYER_ID)
	{
		new alan = GetPVarInt(playerid, "xv_teklif_id");
		SetPVarInt(alan, "xv_teklif_gonderen", INVALID_PLAYER_ID);
		DeletePVar(alan, "xv_teklif_xid");
		DeletePVar(alan, "xv_teklif_fiyat");
		KillTimer(offerTimer[alan]);
		SendClientMessage(alan, -1, "{FF0000}[!] {DCDC22}Ara� satmay� teklif eden oyuncu oyundan ��kt��� i�in teklif iptal edildi.");
	}
	
	if(IsPlayerInAnyVehicle(playerid))
	{
		new xid = xVeh[GetPlayerVehicleID(playerid)], Float:xvHP;
		GetVehicleHealth(GetPlayerVehicleID(playerid), xvHP);
		if(xid != 0 && xVehicle[xid][xv_HizliPark] == 1 && !IsVehicleFlipped(GetPlayerVehicleID(playerid)) && xvHP > 300)
		{
			GetVehiclePos(GetPlayerVehicleID(playerid), xVehicle[xid][xv_Pos][0], xVehicle[xid][xv_Pos][1], xVehicle[xid][xv_Pos][2]);
			GetVehicleZAngle(GetPlayerVehicleID(playerid), xVehicle[xid][xv_Pos][3]);
			SavexVehicle(xid);
		}
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER)
	{
		new xid = xVeh[GetPlayerVehicleID(playerid)];
		if(xid != 0)
		{
			if(!strlen(xVehicle[xid][xv_Sahip]))
			{
				new str[512];
				format(str, sizeof str, "{FFFFFF}---------------------------[Sat�l�k Ara�]---------------------------\n", str);
				format(str, sizeof str, "%s\n", str);
				format(str, sizeof str, "%s{00D700}Bu ara� sat�l�kt�r!\n", str);
				format(str, sizeof str, "%s\n{0098FF}Ara� ad�: {FFFF00}%s\n", str, GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]));
				format(str, sizeof str, "%s{0098FF}Plakas�: {FFFF00}%s\n", str, xVehicle[xid][xv_Plaka]);
				format(str, sizeof str, "%s{0098FF}Fiyat�: {FFFF00}$%d\n", str, xVehicle[xid][xv_Fiyat]);
				format(str, sizeof str, "%s\n{FF8000}Bu arac� sat�n almak istiyor musunuz?{00D700}\n", str);
				format(str, sizeof str, "%s\n{FFFFFF}-------------------------------------------------------------------------", str);
				ShowPlayerDialog(playerid, XV_DIALOGID+5, DIALOG_STYLE_MSGBOX, "Sat�l�k Ara�", str, "Sat�n Al", "Kapat");
			}
			else if(xStrcmp(Isim(playerid), xVehicle[xid][xv_Sahip]) && !Iter_Contains(xVehicleKeys<playerid>, xid))
			{
				SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Bu arac�n anahtar� sizde yok!");
				RemovePlayerFromVehicle(playerid);
			}
			else
			{
				SendClientMessage(playerid, -1, "{00FF00}[!] {DCDC22}Ara� men�s� i�in {ECB021}/a {DCDC22}yaz�n�z.");
			}
		}
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	new xid = xVeh[vehicleid], Float:xvHP;
	GetVehicleHealth(vehicleid, xvHP);
	if(xid != 0 && xVehicle[xid][xv_HizliPark] == 1 && !IsVehicleFlipped(vehicleid) && xvHP > 300)
	{
		GetVehiclePos(vehicleid, xVehicle[xid][xv_Pos][0], xVehicle[xid][xv_Pos][1], xVehicle[xid][xv_Pos][2]);
		GetVehicleZAngle(vehicleid, xVehicle[xid][xv_Pos][3]);
		SavexVehicle(xid);
	}
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	new xid = xVeh[vehicleid];
	if(xid != 0)
	{
		DestroyVehicle(xVehicle[xid][xv_Veh]);
		xVehicle[xid][xv_Veh] = CreateVehicle(xVehicle[xid][xv_ModelID], xVehicle[xid][xv_Pos][0], xVehicle[xid][xv_Pos][1], xVehicle[xid][xv_Pos][2], xVehicle[xid][xv_Pos][3], xVehicle[xid][xv_Renk][0], xVehicle[xid][xv_Renk][1], -1);
		xVeh[xVehicle[xid][xv_Veh]] = xid;
		SetVehicleNumberPlate(xVehicle[xid][xv_Veh], xVehicle[xid][xv_Plaka]);
		LoadVehicleMod(xid);
	}
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	new xid = xVeh[vehicleid];
	if(xid != 0)
    {
		xVehicle[xid][xv_Renk][0] = color1;
		xVehicle[xid][xv_Renk][1] = color2;
    }
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	new xid = xVeh[vehicleid];
	if(xid != 0) xVehicle[xid][xv_Paintjob] = paintjobid;
    return 1;
}

public OnVehicleMod(playerid,vehicleid,componentid)
{
	new xid = xVeh[vehicleid];
	if(xid != 0)
	{
		for(new i; i<14; i++)
		{
			xVehicle[xid][xv_Parca][i] = GetVehicleComponentInSlot(vehicleid, i);
		}
	}
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	DisablePlayerCheckpoint(playerid);
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == XV_DIALOGID)
	{		
		if(response)
		{
			new tmp[8], xid;
			GetPVarString(playerid, "selected_veh_plate", tmp, 8);
			xid = GetVehiclexIDFromPlate(tmp);
			if(xid == 0) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Ara� bulunamad�!");
			
			switch(listitem)
			{
				case 0: // arac nerede?
				{
					if(xVehicle[xid][xv_Garajda])
					{
						if(!xStrcmp(xVehicle[xid][xv_Sahip], Isim(playerid))) ShowPlayerDialog(playerid, XV_DIALOGID+4, DIALOG_STYLE_MSGBOX, "Ara� Nerede", "{FFA500}Bu ara� garajda. Ara� men�s�den ilgili se�ene�i se�erek arac� garajdan ��karabilirsiniz.", "Geri", "");
						else ShowPlayerDialog(playerid, XV_DIALOGID+4, DIALOG_STYLE_MSGBOX, "Ara� Nerede", "{FFA500}Bu ara� garajda. Arac� garajdan yaln�zca ara� sahibi ��karabilir.", "Geri", "");
					}
					else
					{
						new Float:vpos[3];
						GetVehiclePos(xVehicle[xid][xv_Veh], vpos[0], vpos[1], vpos[2]);
						SetPlayerCheckpoint(playerid, vpos[0], vpos[1], vpos[2], 3);
						SendClientMessage(playerid, -1, "{00BD00}[!] {00FF00}Ara� haritada i�aretlendi!");
					}
				}
				case 1: // garaj sok/��kar
				{
					if(xStrcmp(xVehicle[xid][xv_Sahip], Isim(playerid))) return ShowPlayerDialog(playerid, XV_DIALOGID+4, DIALOG_STYLE_MSGBOX, inputtext, "{FF0000}[HATA] {FFA500}Bu �zelli�i sadece ara� sahibi kullanabilir!", "Geri", "");
					if(xVehicle[xid][xv_Garajda])
					{
						new str[128];
						GetPlayerPos(playerid, xVehicle[xid][xv_Pos][0], xVehicle[xid][xv_Pos][1], xVehicle[xid][xv_Pos][2]);
						GetPlayerFacingAngle(playerid, xVehicle[xid][xv_Pos][3]);
						xVehicle[xid][xv_Pos][3] += 90;
						GetXYInFrontOfPlayer(playerid, xVehicle[xid][xv_Pos][0], xVehicle[xid][xv_Pos][1], 3);
						xVehicle[xid][xv_Veh] = CreateVehicle(xVehicle[xid][xv_ModelID], xVehicle[xid][xv_Pos][0], xVehicle[xid][xv_Pos][1], xVehicle[xid][xv_Pos][2], xVehicle[xid][xv_Pos][3], xVehicle[xid][xv_Renk][0], xVehicle[xid][xv_Renk][1], -1);
						xVeh[xVehicle[xid][xv_Veh]] = xid;
						SetVehicleNumberPlate(xVehicle[xid][xv_Veh], xVehicle[xid][xv_Plaka]);
						SetVehicleToRespawn(xVehicle[xid][xv_Veh]);
						xVehicle[xid][xv_Garajda] = 0;
						SavexVehicle(xid);
						format(str, sizeof(str), "{ECEC13}%s {FFFB93}plakal�, {ECEC13}%s {FFFB93}adl� ara� garajdan ��kar�ld�!", xVehicle[xid][xv_Plaka], GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]));
						SendClientMessage(playerid, -1, str);
					}
					else
					{
						if(GetPlayerInGarageVehicleCount(playerid) >= GARAJ_MAX_ARAC) return SendClientMessage(playerid, -1, "{FF0000}[!] {DCDC22}Garaja koyulabilecek en fazla ara� say�s�na ula�m��s�n�z! Garaja daha fazla ara� koyamazs�n�z.");
						new str[128];
						DestroyVehicle(xVehicle[xid][xv_Veh]);
						xVehicle[xid][xv_Garajda] = 1;
						SavexVehicle(xid);
						format(str, sizeof(str), "{ECEC13}%s {FFFB93}plakal�, {ECEC13}%s {FFFB93}adl� ara� garaja koyuldu!", xVehicle[xid][xv_Plaka], GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]));
						SendClientMessage(playerid, -1, str);
					}
				}
				case 2:
				{
					new str[288];
					format(str, sizeof(str), "{FFFB93}H�zl� park, siz ara�tan indi�iniz zaman arac�n�z� otomatik park eden bir sistemdir.\nAra�tan indi�iniz zaman arac�n�z takla atmam��sa ve sa�l��� 300'den fazlaysa mevcut konum kaydedilir. Aksi halde otomatik kaydedilmez\n\nH�zl� Park Durumu: %s", (xVehicle[xid][xv_HizliPark]) ? ("{00FF00}Aktif") : ("{FF0000}Pasif"));
					ShowPlayerDialog(playerid, XV_DIALOGID+1, DIALOG_STYLE_MSGBOX, "H�zl� Park", str, (xVehicle[xid][xv_HizliPark]) ? ("Pasif Yap") : ("Aktif Yap"), "Geri");
				}
				case 3: 
				{
					if(xStrcmp(xVehicle[xid][xv_Sahip], Isim(playerid))) return ShowPlayerDialog(playerid, XV_DIALOGID+4, DIALOG_STYLE_MSGBOX, "Ara� Anahtarlar�", "{FF0000}[HATA] {FFA500}Bu �zelli�i sadece ara� sahibi kullanabilir!", "Geri", "");
					ShowPlayerDialog(playerid, XV_DIALOGID+2, DIALOG_STYLE_LIST, "Arac�n Anahtarlar�", "{DCDC22}� {FFFB93}Anahtar� Olanlar� G�r\n{DCDC22}� {FFFB93}Birine Anahtar Ver\n{DCDC22}� {FFFB93}Kilidi De�i�tir", "Se�", "Geri");
				}
				case 4:
				{
					if(xStrcmp(xVehicle[xid][xv_Sahip], Isim(playerid))) return ShowPlayerDialog(playerid, XV_DIALOGID+4, DIALOG_STYLE_MSGBOX, "Ara� Sat���", "{FF0000}[HATA] {FFA500}Bu �zelli�i sadece ara� sahibi kullanabilir!", "Geri", "");
					ShowPlayerDialog(playerid, XV_DIALOGID+8, DIALOG_STYLE_LIST, "Arac� Sat", "{DCDC22}� {FFFB93}Galeriye Sat\n{DCDC22}� {FFFB93}Ki�iye Sat", "Se�", "Geri");
				}
				case 5:
				{
					new str[256];
					format(str, sizeof(str), "{FFFFFF}----------[ Ara� Bilgileri ]----------\n\n{F0AE0F}-� {ECE913}Sahibi: {FFFFFF}%s\n{F0AE0F}-� {ECE913}Ara� Ad�: {FFFFFF}%s\n{F0AE0F}-� {ECE913}Plakas�: {FFFFFF}%s", xVehicle[xid][xv_Sahip], GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]), xVehicle[xid][xv_Plaka]);
					ShowPlayerDialog(playerid, XV_DIALOGID+4, DIALOG_STYLE_MSGBOX, "Ara� Bilgileri", str, "Geri", "");
				}
			}
		}
		else
		{
			DeletePVar(playerid, "selected_veh_plate");
			cmd_a(playerid, "");
		}
	}
	
	if(dialogid == XV_DIALOGID+1)
	{
		new tmp[8], xid;
		GetPVarString(playerid, "selected_veh_plate", tmp, 8);
		xid = GetVehiclexIDFromPlate(tmp);
		if(xid == 0) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Ara� bulunamad�!");
		
		if(response)
		{
			switch(xVehicle[xid][xv_HizliPark])
			{
				case 0:
				{
					SendClientMessage(playerid, -1, "{00BD00}[!] {00FF00}Arac�n�z�n h�zl� park �zelli�i devreye al�nd�!");
					xVehicle[xid][xv_HizliPark] = 1;
					xvMenuGoster(playerid);
				}
				case 1:
				{
					SendClientMessage(playerid, -1, "{00BD00}[!] {00FF00}Arac�n�z�n h�zl� park �zelli�i devre d��� b�rak�ld�!");
					xVehicle[xid][xv_HizliPark] = 0;
					xvMenuGoster(playerid);
				}
			}
		} else xvMenuGoster(playerid);
	}
	
	if(dialogid == XV_DIALOGID+2)
	{
		if(response)
		{
			new tmp[8], xid;
			GetPVarString(playerid, "selected_veh_plate", tmp, 8);
			xid = GetVehiclexIDFromPlate(tmp);
			if(xid == 0) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Ara� bulunamad�!");
			
			switch(listitem)
			{
				case 0:
				{
					new query[128], Cache:keys;
					mysql_format(mysqlB, query, sizeof(query), "SELECT Isim FROM xVehicleKeys WHERE AracID=%d ORDER BY AracID DESC LIMIT %d, 15", xid, GetPVarInt(playerid, "xvKeysPage")*15);
					keys = mysql_query(mysqlB, query);
					new rows = cache_num_rows();
					if(rows) 
					{
						new list[512], o_isim[MAX_PLAYER_NAME];
						format(list, sizeof(list), "Oyuncu Ad�\n");
						for(new i; i < rows; ++i)
						{
							cache_get_value_name(i, "Isim", o_isim);
							format(list, sizeof(list), "%s%s\n", list, o_isim);
						}
						format(list, sizeof(list), "%s{F4D00B}<< �nceki Sayfa\n{F4D00B}>> Sonraki Sayfa", list);
						ShowPlayerDialog(playerid, XV_DIALOGID+3, DIALOG_STYLE_TABLIST_HEADERS, "Anahtar� Olanlar (Sayfa 1)", list, "Se�", "Geri");
					}
					else
					{
						SendClientMessage(playerid, 0xE74C3CFF, "Arac�n�z�n anahtar� kimsede yok.");
					}
					cache_delete(keys);
				}
				case 1:  ShowPlayerDialog(playerid, XV_DIALOGID+13, DIALOG_STYLE_INPUT, "Ara� Anahtar� Ver", "{FFFB93}Arac�n anahtar�n� vermek istedi�iniz oyuncunun ad�n� veya ID'sini yaz�n:", "�leri", "Geri");
				case 2: 
				{
					ShowPlayerDialog(playerid, XV_DIALOGID+15, DIALOG_STYLE_MSGBOX, "Kilidi De�i�tir", "{FFFB93}Arac�n�z�n kilidini de�i�tirmek istedi�inize emin misiniz?\nArac�n�z�n anahtar� olan t�m oyuncular�n anahtarlar� silinecektir.", "Onayla", "Geri");
				}
			}
		} else xvMenuGoster(playerid);
	}
	
	if(dialogid == XV_DIALOGID+3)
	{
		if(response)
		{
			new tmp[8], xid;
			GetPVarString(playerid, "selected_veh_plate", tmp, 8);
			xid = GetVehiclexIDFromPlate(tmp);
			if(xid == 0) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Ara� bulunamad�!");
			
			if(!xStrcmp(inputtext, "<< �nceki Sayfa"))
			{
				SetPVarInt(playerid, "xvKeysPage", GetPVarInt(playerid, "xvKeysPage")-1);
				if(GetPVarInt(playerid, "xvKeysPage") < 0)
				{
					SetPVarInt(playerid, "xvKeysPage", 0);
					ShowPlayerDialog(playerid, XV_DIALOGID+2, DIALOG_STYLE_LIST, "Arac�n Anahtarlar�", "{DCDC22}� {FFFB93}Anahtar� Olanlar� G�r\n{DCDC22}� {FFFB93}Birine Anahtar Ver\n{DCDC22}� {FFFB93}Kilidi De�i�tir", "Se�", "Geri");
					return 1;
				}
				
				new query[128], Cache:keys;
				mysql_format(mysqlB, query, sizeof(query), "SELECT Isim FROM xVehicleKeys WHERE AracID=%d ORDER BY AracID DESC LIMIT %d, 15", xid, GetPVarInt(playerid, "xvKeysPage")*15);
				keys = mysql_query(mysqlB, query);
				new rows = cache_num_rows();
				if(rows)
				{
					new list[512], o_isim[MAX_PLAYER_NAME];
					format(list, sizeof(list), "Oyuncu Ad�\n");
					for(new i; i < rows; ++i)
					{
						cache_get_value_name(i, "Isim", o_isim);
						format(list, sizeof(list), "%s%s\n", list, o_isim);
					}
					format(list, sizeof(list), "%s{F4D00B}<< �nceki Sayfa\n{F4D00B}>> Sonraki Sayfa", list);
					new head[32];
					format(head, sizeof(head), "Anahtar� Olanlar (Sayfa %d)", GetPVarInt(playerid, "xvKeysPage")+1);
					ShowPlayerDialog(playerid, XV_DIALOGID+3, DIALOG_STYLE_TABLIST_HEADERS, head, list, "Se�", "Geri");
				}
				else
				{
					/*SetPVarInt(playerid, "xvKeysPage", 0);
					ShowPlayerDialog(playerid, XV_DIALOGID+2, DIALOG_STYLE_LIST, "Arac�n Anahtarlar�", "Anahtar� Olanlar� G�r\nBirine Anahtar Ver\nKilidi De�i�tir", "Se�", "Geri");
					*/
					SendClientMessage(playerid, 0xE74C3CFF, "Ba�ka anahtar� olan bulunamad�.");
				}
				cache_delete(keys);
			}
			else if(!xStrcmp(inputtext, ">> Sonraki Sayfa"))
			{
				SetPVarInt(playerid, "xvKeysPage", GetPVarInt(playerid, "xvKeysPage")+1);
			
				new query[128], Cache:keys;
				mysql_format(mysqlB, query, sizeof(query), "SELECT Isim FROM xVehicleKeys WHERE AracID=%d ORDER BY AracID DESC LIMIT %d, 15", xid, GetPVarInt(playerid, "xvKeysPage")*15);
				keys = mysql_query(mysqlB, query);
				new rows = cache_num_rows();
				if(rows)
				{
					new list[512], o_isim[MAX_PLAYER_NAME];
					format(list, sizeof(list), "Oyuncu Ad�\n");
					for(new i; i < rows; ++i)
					{
						cache_get_value_name(i, "Isim", o_isim);
						format(list, sizeof(list), "%s%s\n", list, o_isim);
					}
					format(list, sizeof(list), "%s{F4D00B}<< �nceki Sayfa\n{F4D00B}>> Sonraki Sayfa", list);
					new head[32];
					format(head, sizeof(head), "Anahtar� Olanlar (Sayfa %d)", GetPVarInt(playerid, "xvKeysPage")+1);
					ShowPlayerDialog(playerid, XV_DIALOGID+3, DIALOG_STYLE_TABLIST_HEADERS, head, list, "Se�", "Geri");
				}
				else
				{
					SetPVarInt(playerid, "xvKeysPage", GetPVarInt(playerid, "xvKeysPage") - 1);
					mysql_format(mysqlB, query, sizeof(query), "SELECT Isim FROM xVehicleKeys WHERE AracID=%d ORDER BY AracID DESC LIMIT %d, 15", xid, GetPVarInt(playerid, "xvKeysPage")*15);
					keys = mysql_query(mysqlB, query);
					rows = cache_num_rows();
					if(rows)
					{
						new list[512], o_isim[MAX_PLAYER_NAME];
						format(list, sizeof(list), "Oyuncu Ad�\n");
						for(new i; i < rows; ++i)
						{
							cache_get_value_name(i, "Isim", o_isim);
							format(list, sizeof(list), "%s%s\n", list, o_isim);
						}
						format(list, sizeof(list), "%s{F4D00B}<< �nceki Sayfa\n{F4D00B}>> Sonraki Sayfa", list);
						new head[32];
						format(head, sizeof(head), "Anahtar� Olanlar (Sayfa %d)", GetPVarInt(playerid, "xvKeysPage")+1);
						ShowPlayerDialog(playerid, XV_DIALOGID+3, DIALOG_STYLE_TABLIST_HEADERS, head, list, "Se�", "Geri");
					}
					SendClientMessage(playerid, 0xE74C3CFF, "Ba�ka anahtar� olan bulunamad�.");
				}
				cache_delete(keys);
			}
			else
			{
				SetPVarString(playerid, "tmp_keyname", inputtext);
				ShowPlayerDialog(playerid, XV_DIALOGID+14, DIALOG_STYLE_LIST, "Ara� Anahtar�", "{DCDC22}� {FFFB93}Anahtar� Ki�iden Al", "Uygula", "Geri");
			}
		}
	}
	
	if(dialogid == XV_DIALOGID+4) xvMenuGoster(playerid);
	
	if(dialogid == XV_DIALOGID+5)
	{
		if(response)
		{
			new xid = xVeh[GetPlayerVehicleID(playerid)];
			if(GetPlayerxVehicleCount(playerid) >= OYUNCU_MAX_ARAC) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Al�nabilecek en fazla ara� say�s�na ula�m��s�n�z! Daha fazla ara� alamazs�n�z."), RemovePlayerFromVehicle(playerid);
			if(GetPlayerMoney(playerid) < xVehicle[xid][xv_Fiyat]) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Bu arac� sat�n almak i�in yeterli paran�z yok!"), RemovePlayerFromVehicle(playerid);
			GivePlayerMoney(playerid, -xVehicle[xid][xv_Fiyat]);
			format(xVehicle[xid][xv_Sahip], 24, "%s", Isim(playerid));
			SavexVehicle(xid);
			Delete3DTextLabel(xVehicle[xid][xv_Text]);
			SendClientMessage(playerid, -1, "{00BD00}[!] {00FF00}Bu arac� ba�ar�yla sat�n ald�n�z! {ECB021}/a {00FF00}komutuyla ara�lar�n�z� y�netebilirsiniz!");
		} 
		else
		{
		if(!IsPlayerAdmin(playerid)) RemovePlayerFromVehicle(playerid);
		}
	}
	
	if(dialogid == XV_DIALOGID+6)
	{
		if(response)
		{
			if(!xStrcmp(inputtext, "� ��inde Bulundu�um Ara�"))
			{
				SetPVarString(playerid, "selected_veh_plate", xVehicle[xVeh[GetPlayerVehicleID(playerid)]][xv_Plaka]);
				xvMenuGoster(playerid);
			}
			else if(!xStrcmp(inputtext, "� Kendi Ara�lar�m"))
			{
				new str[256], cnt;
				format(str, sizeof(str), "Plaka\tAra� Ad�\tDurum");
				foreach(new i : xVehicles)
				{
					if(!xStrcmp(xVehicle[i][xv_Sahip], Isim(playerid))) format(str, sizeof(str), "%s\n%s\t%s\t%s", str, xVehicle[i][xv_Plaka], GetVehicleNameFromModel(xVehicle[i][xv_ModelID]), (xVehicle[i][xv_Garajda]) ? ("{F0CE0F}Garajda") : ("{8FE01F}Haritada")), cnt++;
				}
				if(!cnt) ShowPlayerDialog(playerid, XV_DIALOGID-1, DIALOG_STYLE_MSGBOX, "Ara�lar�m", "{FF0000}[!] {F0AE0F}Hi� arac�n�z yok!", "Tamam", "");
				else ShowPlayerDialog(playerid, XV_DIALOGID+7, DIALOG_STYLE_TABLIST_HEADERS, "Ara�lar�m", str, "Arac� Se�", "Geri");
			}
			else if(!xStrcmp(inputtext, "� Anahtar� Bende Olan Ara�lar"))
			{
				new str[256], cnt;
				format(str, sizeof(str), "Plaka\tAra� Ad�\tDurum");
				foreach(new i : xVehicleKeys<playerid>)
				{
					format(str, sizeof(str), "%s\n%s\t%s\t%s", str, xVehicle[i][xv_Plaka], GetVehicleNameFromModel(xVehicle[i][xv_ModelID]), (xVehicle[i][xv_Garajda]) ? ("{F0CE0F}Garajda") : ("{8FE01F}Haritada"));
					cnt++;
				}
				if(!cnt) ShowPlayerDialog(playerid, XV_DIALOGID-1, DIALOG_STYLE_MSGBOX, "Anahtar�m Olan Ara�lar", "{FFA500}Hi�bir arac�n anahtar� sizde de�il!", "Tamam", "");
				else ShowPlayerDialog(playerid, XV_DIALOGID+7, DIALOG_STYLE_TABLIST_HEADERS, "Anahtar�m Olan Ara�lar", str, "Arac� Se�", "Geri");
			}
		}
	}
	
	if(dialogid == XV_DIALOGID+7)
	{
		if(response)
		{
		    new tmp[2][8];
			split(inputtext, tmp, '\t');
			SetPVarString(playerid, "selected_veh_plate", tmp[0]);
			xvMenuGoster(playerid);
		} else cmd_a(playerid, "");
	}
	
	if(dialogid == XV_DIALOGID+8)
	{
		if(response)
		{
			new str[256], tmpp[8], xid;
			GetPVarString(playerid, "selected_veh_plate", tmpp, 8);
			xid = GetVehiclexIDFromPlate(tmpp);
			if(xid == 0) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Ara� bulunamad�!");
			
			switch(listitem)
			{
				case 0:
				{
					format(str, sizeof(str), "{ECCB13}Arac�n�z� galeriye satmak istedi�inizden emin misiniz?\n{FFFB93}Alaca��n�z �cret: {15EC13}$%d\n\n{AAAAAA}(Alaca��n�z �cret sat�n ald���n�z �cretin %%70'idir)", (xVehicle[xid][xv_Fiyat] / 100) * 70);
					ShowPlayerDialog(playerid, XV_DIALOGID+9, DIALOG_STYLE_MSGBOX, "Arac� Galeriye Sat", str, "Onayla", "Geri");
				}
				case 1:
				{
					if(GetPVarInt(playerid, "xv_teklif_id") != INVALID_PLAYER_ID) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Zaten ba�ka bir oyuncuya teklif g�ndermi�siniz! �nce o teklifin yan�tlanmas�n� veya s�resinin bitmesini bekleyin.");
					if(xVehicle[xid][xv_Garajda]) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Arac�n�z� satmak i�in �nce garajdan ��karmal�s�n�z!");
					ShowPlayerDialog(playerid, XV_DIALOGID+10, DIALOG_STYLE_INPUT, "Arac� Oyuncuya Sat", "{FFFB93}Arac� satmak istedi�iniz oyuncunun ad�n� veya ID'sini yaz�n:", "�leri", "Geri");
				}
			}
		} else xvMenuGoster(playerid);
	}
	
	if(dialogid == XV_DIALOGID+9)
	{
		if(response)
		{
			new query[128], tmpp[8], xid;
			GetPVarString(playerid, "selected_veh_plate", tmpp, 8);
			xid = GetVehiclexIDFromPlate(tmpp);
			if(xid == 0) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Ara� bulunamad�!");
			
			GivePlayerMoney(playerid, (xVehicle[xid][xv_Fiyat] / 100) * 70);
			if(IsValidVehicle(xVehicle[xid][xv_Veh])) DestroyVehicle(xVehicle[xid][xv_Veh]);
			Iter_Remove(xVehicles, xid);
			DeletePVar(playerid, "selected_veh_plate");
			foreach(new i : Player)
			{
				if(Iter_Contains(xVehicleKeys<i>, xid)) Iter_Remove(xVehicleKeys<i>, xid);
			}

			mysql_format(mysqlB, query, sizeof(query), "DELETE FROM xVehicleKeys WHERE AracID=%d", xid);
			mysql_query(mysqlB, query);
			mysql_format(mysqlB, query, sizeof(query), "DELETE FROM xVehicle WHERE ID=%d", xid);
			mysql_query(mysqlB, query);
			SendClientMessage(playerid, -1, "{00BD00}[!] {00FF00}Arac�n�z� ba�ar�yla galeriye satt�n�z!");
		} else ShowPlayerDialog(playerid, XV_DIALOGID+8, DIALOG_STYLE_LIST, "Arac� Sat", "{DCDC22}� {FFFB93}Galeriye Sat\n{DCDC22}� {FFFB93}Ki�iye Sat", "Se�", "Geri");
	}
	
	if(dialogid == XV_DIALOGID+10)
	{
		if(response)
		{
			new pid;
			if(sscanf(inputtext, "u", pid)) return ShowPlayerDialog(playerid, XV_DIALOGID+10, DIALOG_STYLE_INPUT, "Arac� Oyuncuya Sat", "{FF0000}[!] {F0AE0F}Bo� b�rakmay�n�z!\n\n{FFFB93}Arac� satmak istedi�iniz oyuncunun ad�n� veya ID'sini yaz�n:", "�leri", "Geri");
			if(!IsPlayerConnected(pid)) return ShowPlayerDialog(playerid, XV_DIALOGID+10, DIALOG_STYLE_INPUT, "Arac� Oyuncuya Sat", "{FF0000}[!] {F0AE0F}Oyuncu ba�l� de�il!\n\n{FFFB93}Arac� satmak istedi�iniz oyuncunun ad�n� veya ID'sini yaz�n:", "�leri", "Geri");
			if(GetPlayerxVehicleCount(playerid) >= OYUNCU_MAX_ARAC) return ShowPlayerDialog(playerid, XV_DIALOGID+10, DIALOG_STYLE_INPUT, "Arac� Oyuncuya Sat", "{FF0000}[!] {F0AE0F}Bu oyuncunun �ok fazla arac� var! Daha fazla ara� alamaz.\n\n{FFFB93}Arac� satmak istedi�iniz oyuncunun ad�n� veya ID'sini yaz�n:", "�leri", "Geri");
			if(GetPVarInt(pid, "xv_teklif_gonderen") != INVALID_PLAYER_ID) return ShowPlayerDialog(playerid, XV_DIALOGID+10, DIALOG_STYLE_INPUT, "Arac� Oyuncuya Sat", "{FF0000}[!] {F0AE0F}Belirtilen oyuncuya �u an ba�kas� teklif sunmu�! Teklifi yan�tlamas�n� beklemelisiniz.\n\n{FFFB93}Arac� satmak istedi�iniz oyuncunun ad�n� veya ID'sini yaz�n:", "�leri", "Geri");
			SetPVarInt(playerid, "xv_teklif_id", pid);
			new str[128];
			format(str, sizeof(str), "{FFFB93}Se�ilen oyuncu: {ECEC13}%s {ECB021}(%d)\n\n{FFFB93}Satmak istedi�iniz fiyat� yaz�n:", Isim(pid), pid);
			ShowPlayerDialog(playerid, XV_DIALOGID+11, DIALOG_STYLE_INPUT, "Ara� Sat - Fiyat", str, "Teklif G�nder", "Geri");
		} else SetPVarInt(playerid, "xv_teklif_id", INVALID_PLAYER_ID), ShowPlayerDialog(playerid, XV_DIALOGID+8, DIALOG_STYLE_LIST, "Arac� Sat", "{DCDC22}� {FFFB93}Galeriye Sat\n{DCDC22}� {FFFB93}Ki�iye Sat", "Se�", "Geri");
	}
	
	if(dialogid == XV_DIALOGID+11)
	{
		if(response)
		{
			new tmpp[8], xid;
			GetPVarString(playerid, "selected_veh_plate", tmpp, 8);
			xid = GetVehiclexIDFromPlate(tmpp);
			if(xid == 0) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Ara� bulunamad�!");
			
			new pid = GetPVarInt(playerid, "xv_teklif_id");
			if(!IsPlayerConnected(pid)) return SendClientMessage(playerid, -1, "{FF0000}[!] {DCDC22}Oyuncu oyundan ��kt��� i�in sat�� iptal edildi.");
			if(!isNumeric(inputtext)) return ShowPlayerDialog(playerid, XV_DIALOGID+11, DIALOG_STYLE_INPUT, "Ara� Sat - Fiyat", "{FF0000}[!] {F0AE0F} Sadece rakam girmelisiniz!\n\n{FFFB93}Satmak istedi�iniz fiyat� yaz�n:", "Teklif G�nder", "Geri");
			if(GetPlayerMoney(pid) < strval(inputtext)) return ShowPlayerDialog(playerid, XV_DIALOGID+11, DIALOG_STYLE_INPUT, "Ara� Sat - Fiyat", "{FF0000}[!] {F0AE0F} Oyuncunun o kadar paras� yok!\n\n{FFFB93}Satmak istedi�iniz fiyat� yaz�n:", "Teklif G�nder", "Geri");
			SetPVarInt(pid, "xv_teklif_gonderen", playerid);
			SetPVarInt(pid, "xv_teklif_fiyat", strval(inputtext));
			SetPVarInt(pid, "xv_teklif_xid", xid);
			offerTimer[pid] = SetTimerEx("TeklifBitir", 30000, false, "uu", playerid, pid);
			new str[400];
			format(str, sizeof(str), "{00BD00}[!] {ECEC13}%s {FFFB93}adl� oyuncuya teklif g�nderildi.", Isim(pid));
			SendClientMessage(playerid, -1, str);
			format(str, sizeof(str), "{FFFFFF}--------------------[ Ara� Sat�� Teklifi ]-------------------\n\n{ECEC13}%s {FFFB93}adl� ki�i size bir ara� satmay� teklif ediyor.\n\nAra� Ad�: {ECB021}%s\n{FFFB93}Ara� Plakas�: {ECB021}%s\n{FFFB93}Fiyat: {00E900}$%d\n\n{FFFB93}Sat�n almak istiyor musunuz?\n\n{FFFFFF}----------------------------------------------------------------------------", Isim(playerid), GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]), xVehicle[xid][xv_Plaka], strval(inputtext));
			ShowPlayerDialog(pid, XV_DIALOGID+12, DIALOG_STYLE_MSGBOX, "Ara� Teklifi", str, "Kabul Et", "Reddet");
		}
		else
		{
			ShowPlayerDialog(playerid, XV_DIALOGID+10, DIALOG_STYLE_INPUT, "Arac� Oyuncuya Sat", "{FFFB93}Arac� satmak istedi�iniz oyuncunun ad�n� veya ID'sini yaz�n:", "�leri", "Geri");
			SetPVarInt(playerid, "xv_teklif_id", INVALID_PLAYER_ID);
		}
	}
	
	if(dialogid == XV_DIALOGID+12)
	{
		if(response)
		{
			new pid = GetPVarInt(playerid, "xv_teklif_gonderen");
			new xid = GetPVarInt(playerid, "xv_teklif_xid");
			new price = GetPVarInt(playerid, "xv_teklif_fiyat");
			if(xid == 0) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Bu teklifi zaman�nda yan�tlamad���n�z i�in s�resi doldu!");
			if(!IsPlayerConnected(pid)) return SendClientMessage(playerid, -1, "{FF0000}[!] {DCDC22}Teklif g�nderen oyuncu oyunda olmad��� i�in sat�� i�lemi iptal edildi.");
			if(xStrcmp(Isim(pid), xVehicle[xid][xv_Sahip])) return SendClientMessage(playerid, -1, "{FF0000}[!] {DCDC22}Teklif g�nderen oyuncu arac�n sahibi olmad��� i�in sat�� i�lemi iptal edildi.");
			if(GetPlayerMoney(playerid) < price)
			{
				SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Yeterli paran�z olmad��� i�in sat�� i�lemi iptal edildi!");
				SendClientMessage(pid, -1, "{FF0000}[!] {F0AE0F}Oyuncunun yeterli paras� olmad��� i�in sat�� i�lemi iptal edildi!");
			}
			
			format(xVehicle[xid][xv_Sahip], 24, "%s", Isim(playerid));
			xVehicle[xid][xv_Fiyat] = price;
			SavexVehicle(xid);
			foreach(new i : Player)
			{
				if(IsValidVehicle(xVehicle[xid][xv_Veh]) && IsPlayerInVehicle(i, xVehicle[xid][xv_Veh]))
				{
					SendClientMessage(i, -1, "{FF0000}[!] {DCDC22}Bu ara� sat�ld��� i�in ara�tan at�ld�n�z.");
					RemovePlayerFromVehicle(i);
				}
			}

			GivePlayerMoney(playerid, -price);
			GivePlayerMoney(pid, price);

			new query[256];
			format(query, sizeof(query), "{ECEC13}%s {FFFB93}adl�, {ECEC13}%s {FFFB93}plakal� arac�n�z�, {ECEC13}%s {FFFB93}adl� oyuncuya {00E900}$%d{FFFB93}'a ba�ar�yla satt�n�z!", GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]), xVehicle[xid][xv_Plaka], Isim(playerid), price);
			ShowPlayerDialog(pid, XV_DIALOGID-1, DIALOG_STYLE_MSGBOX, "Ara� Sat���", query, "Tamam", "");
			format(query, sizeof(query), "{ECEC13}%s {FFFB93}adl�, {ECEC13}%s {FFFB93}plakal� arac�, {ECEC13}%s adl� oyuncudan {00E900}$%d{FFFB93}'a ba�ar�yla sat�n ald�n�z!", GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]), xVehicle[xid][xv_Plaka], Isim(pid), price);
			ShowPlayerDialog(playerid, XV_DIALOGID-1, DIALOG_STYLE_MSGBOX, "Ara� Sat���", query, "Tamam", "");
			mysql_format(mysqlB, query, sizeof(query), "DELETE FROM xVehicleKeys WHERE AracID=%d", xid);
			mysql_query(mysqlB, query);
			mysql_format(mysqlB, query, sizeof(query), "UPDATE xVehicle SET Sahip='%s' WHERE ID=%d", Isim(playerid), xid);
			mysql_query(mysqlB, query);
		}
		else
		{
			SendClientMessage(playerid, -1, "{FF0000}[!] {DCDC22}Teklifi reddettiniz.");
			if(IsPlayerConnected(GetPVarInt(playerid, "xv_teklif_gonderen"))) SendClientMessage(GetPVarInt(playerid, "xv_teklif_gonderen"), -1, "{FF0000}[!] {DCDC22}Ara� satmay� teklif etti�iniz oyuncu teklifi reddetti!");
		}
		KillTimer(offerTimer[playerid]);
		SetPVarInt(GetPVarInt(playerid, "xv_teklif_gonderen"), "xv_teklif_id", INVALID_PLAYER_ID);
		SetPVarInt(playerid, "xv_teklif_gonderen", INVALID_PLAYER_ID);
		DeletePVar(playerid, "xv_teklif_xid");
		DeletePVar(playerid, "xv_teklif_fiyat");
	}
	
	if(dialogid == XV_DIALOGID+13)
	{
		if(response)
		{
			new str[150], tmpp[8], xid, pid;
			GetPVarString(playerid, "selected_veh_plate", tmpp, 8);
			xid = GetVehiclexIDFromPlate(tmpp);
			if(xid == 0) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Ara� bulunamad�!");
			
			if(sscanf(inputtext, "u", pid)) return ShowPlayerDialog(playerid, XV_DIALOGID+13, DIALOG_STYLE_INPUT, "Ara� Anahtar� Ver", "{FF0000}[!] {F0AE0F}Bo� b�rakmay�n�z!\n\n{FFFB93}Arac�n anahtar�n� vermek istedi�iniz oyuncunun ad�n� veya ID'sini yaz�n:", "�leri", "Geri");
			if(!IsPlayerConnected(pid)) return ShowPlayerDialog(playerid, XV_DIALOGID+13, DIALOG_STYLE_INPUT, "Ara� Anahtar� Ver", "{FF0000}[!] {F0AE0F}Oyuncu ba�l� de�il!\n{FFFB93}Arac�n anahtar�n� vermek istedi�iniz oyuncunun ad�n� veya ID'sini yaz�n:", "�leri", "Geri");
			if(pid == playerid) return ShowPlayerDialog(playerid, XV_DIALOGID+13, DIALOG_STYLE_INPUT, "Ara� Anahtar� Ver", "{FF0000}[!] {F0AE0F}Kendinize anahtar vermenize gerek yok!\n{FFFB93}Arac�n anahtar�n� vermek istedi�iniz oyuncunun ad�n� veya ID'sini yaz�n:", "�leri", "Geri");
			if(Iter_Contains(xVehicleKeys<pid>, xid)) return ShowPlayerDialog(playerid, XV_DIALOGID+4, DIALOG_STYLE_MSGBOX, "Ara� Anahtar� Ver", "{FF0000}[!] {F0AE0F}Bu oyuncuda arac�n anahtar� zaten var!", "Geri", "");
			Iter_Add(xVehicleKeys<pid>, xid);
			mysql_format(mysqlB, str, sizeof(str), "INSERT INTO xVehicleKeys SET AracID=%d, Isim='%e'", xid, Isim(pid));
			mysql_query(mysqlB, str);
			format(str, sizeof(str), "{ECEC13}%s {FFFB93}adl� ki�iye, {ECEC13}%s {FFFB93}plakal�, {ECEC13}%s {FFFB93}adl� arac�n�z�n anahtar�n� verdiniz!", Isim(pid), xVehicle[xid][xv_Plaka], GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]));
			SendClientMessage(playerid, -1, str);
			format(str, sizeof(str), "{ECEC13}%s {FFFB93}adl� ki�i size, {ECEC13}%s {FFFB93}plakal�, {ECEC13}%s {FFFB93}adl� arac�n anahtar�n� verdi!", Isim(playerid), xVehicle[xid][xv_Plaka], GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]));
			SendClientMessage(pid, -1, str);
		} else ShowPlayerDialog(playerid, XV_DIALOGID+2, DIALOG_STYLE_LIST, "Arac�n Anahtarlar�", "{DCDC22}� {FFFB93}Anahtar� Olanlar� G�r\n{DCDC22}� {FFFB93}Birine Anahtar Ver\n{DCDC22}� {FFFB93}Kilidi De�i�tir", "Se�", "Geri");
	}
	
	if(dialogid == XV_DIALOGID+14)
	{
		if(response)
		{
			new str[150], tmpp[8], xid, pid;
			GetPVarString(playerid, "selected_veh_plate", tmpp, 8);
			xid = GetVehiclexIDFromPlate(tmpp);
			if(xid == 0) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Ara� bulunamad�!");
			
			new p_is[24];
			GetPVarString(playerid, "tmp_keyname", p_is, 24);
			pid = GetPlayerIDFromName(p_is);
			if(IsPlayerConnected(pid))
			{
				Iter_Remove(xVehicleKeys<pid>, xid);
				format(str, sizeof(str), "{ECEC13}%s {FFFB93}adl� ki�i sizden, {ECEC13}%s {FFFB93}plakal�, {ECEC13}%s {FFFB93}adl� arac�n anahtar�n� geri ald�!", Isim(playerid), xVehicle[xid][xv_Plaka], GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]));
				SendClientMessage(pid, -1, str);
			}
			mysql_format(mysqlB, str, sizeof(str), "DELETE FROM xVehicleKeys WHERE AracID=%d AND Isim='%e'", xid, p_is);
			mysql_query(mysqlB, str);
			format(str, sizeof(str), "{ECEC13}%s {FFFB93}adl� ki�iden, {ECEC13}%s {FFFB93}plakal�, {ECEC13}%s {FFFB93}adl� arac�n anahtar�n� geri ald�n�z!", p_is, xVehicle[xid][xv_Plaka], GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]));
			SendClientMessage(playerid, -1, str);
		}
		else ShowPlayerDialog(playerid, XV_DIALOGID+2, DIALOG_STYLE_LIST, "Arac�n Anahtarlar�", "{DCDC22}� {FFFB93}Anahtar� Olanlar� G�r\n{DCDC22}� {FFFB93}Birine Anahtar Ver\n{DCDC22}� {FFFB93}Kilidi De�i�tir", "Se�", "Geri");
	}
	
	if(dialogid == XV_DIALOGID+15)
	{
		if(response)
		{
			new str[128], tmpp[8], xid;
			GetPVarString(playerid, "selected_veh_plate", tmpp, 8);
			xid = GetVehiclexIDFromPlate(tmpp);
			if(xid == 0) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Ara� bulunamad�!");
			
			foreach(new i : Player)
			{
				if(IsPlayerInVehicle(i, xVehicle[xid][xv_Veh]) && xStrcmp(xVehicle[xid][xv_Sahip], Isim(i))) 
				{
					SendClientMessage(i, -1, "{FF0000}[!] {DCDC22}Ara� sahibi arac�n kilidini de�i�tirdi�i i�in ara�tan indirildiniz.");
					RemovePlayerFromVehicle(i);
				}
				if(Iter_Contains(xVehicleKeys<i>, xid)) Iter_Remove(xVehicleKeys<i>, xid);
			}
			mysql_format(mysqlB, str, sizeof(str), "DELETE FROM xVehicleKeys WHERE AracID=%d", xid);
			mysql_query(mysqlB, str);
			SendClientMessage(playerid, -1, "{00BD00}[!] {00FF00}Arac�n�z�n kilidini ba�ar�yla de�i�tirdiniz!");
		} else ShowPlayerDialog(playerid, XV_DIALOGID+2, DIALOG_STYLE_LIST, "Arac�n Anahtarlar�", "{DCDC22}� {FFFB93}Anahtar� Olanlar� G�r\n{DCDC22}� {FFFB93}Birine Anahtar Ver\n{DCDC22}� {FFFB93}Kilidi De�i�tir", "Se�", "Geri");
	}
	
	if(dialogid == XV_DIALOGID+16)
	{
		if(response)
		{
			switch(listitem)
			{
				case 0:
				{
					new query[128], Cache:vehs;
					SetPVarInt(playerid, "xvKeysPage", 0);
					mysql_format(mysqlB, query, sizeof(query), "SELECT ID FROM xVehicle ORDER BY ID ASC LIMIT %d, 15", GetPVarInt(playerid, "xvKeysPage")*15);
					vehs = mysql_query(mysqlB, query);
					new rows = cache_num_rows();
					if(rows) 
					{
						new list[512], v_id;
						format(list, sizeof(list), "Ara� ID\tPlaka\tAra� Ad�\n");
						for(new i; i < rows; ++i)
						{
							cache_get_value_name_int(i, "ID", v_id);
							format(list, sizeof(list), "%s%d\t%s\t%s\n", list, v_id, xVehicle[v_id][xv_Plaka], GetVehicleNameFromModel(xVehicle[v_id][xv_ModelID]));
						}
						format(list, sizeof(list), "%s{F4D00B}<< �nceki Sayfa\n{F4D00B}>> Sonraki Sayfa", list);
						ShowPlayerDialog(playerid, XV_DIALOGID+17, DIALOG_STYLE_TABLIST_HEADERS, "Ara� Listesi (Sayfa 1)", list, "Se�", "Geri");
					}
					else
					{
						SendClientMessage(playerid, 0xE74C3CFF, "{FF0000}[!] {DCDC22}Hi� ara� olu�turulmam��.");
					}
					cache_delete(vehs);	
				}
				case 1:
				{
					new str[128];
					foreach(new i : xVehicles) if(!xVehicle[i][xv_Garajda]) SetVehicleToRespawn(xVehicle[i][xv_Veh]);
					SendClientMessage(playerid, -1, "{00BD00}[!] {00FF00}T�m ara�lar yenilendi!");
					format(str, sizeof(str), "{00BD00}[!] {ECEC13}%s {FFFB93}adl� admin t�m ara�lar� yeniledi!", Isim(playerid));
					SendClientMessageToAll(-1, str);
				}
				case 2:
				{
					ShowPlayerDialog(playerid, XV_DIALOGID+22, DIALOG_STYLE_INPUT, "Ara� Olu�tur", "{FFFB93}Olu�turulacak arac�n ad�n� veya Model ID'sini girin:", "�leri", "Geri");
				}
			}
		}
	}
	
	if(dialogid == XV_DIALOGID+17)
	{
		if(response)
		{
			if(!xStrcmp(inputtext, "<< �nceki Sayfa"))
			{
				SetPVarInt(playerid, "xvKeysPage", GetPVarInt(playerid, "xvKeysPage")-1);
				if(GetPVarInt(playerid, "xvKeysPage") < 0)
				{
					SetPVarInt(playerid, "xvKeysPage", 0);
					cmd_amenu(playerid, "");
					return 1;
				}
				
				new query[128], Cache:vehs;
				mysql_format(mysqlB, query, sizeof(query), "SELECT ID FROM xVehicle ORDER BY ID ASC LIMIT %d, 15", GetPVarInt(playerid, "xvKeysPage")*15);
				vehs = mysql_query(mysqlB, query);
				new rows = cache_num_rows();
				if(rows)
				{
					new list[512], v_id;
					format(list, sizeof(list), "Ara� ID\tPlaka\tAra� Ad�\n");
					for(new i; i < rows; ++i)
					{
						cache_get_value_name_int(i, "ID", v_id);
						format(list, sizeof(list), "%s%d\t%s\t%s\n", list, v_id, xVehicle[v_id][xv_Plaka], GetVehicleNameFromModel(xVehicle[v_id][xv_ModelID]));
					}
					format(list, sizeof(list), "%s{F4D00B}<< �nceki Sayfa\n{F4D00B}>> Sonraki Sayfa", list);
					new head[32];
					format(head, sizeof(head), "Ara� Listesi (Sayfa %d)", GetPVarInt(playerid, "xvKeysPage")+1);
					ShowPlayerDialog(playerid, XV_DIALOGID+17, DIALOG_STYLE_TABLIST_HEADERS, head, list, "Se�", "Geri");
				}
				else
				{
					SetPVarInt(playerid, "xvKeysPage", 0);
				}
				cache_delete(vehs);
			}
			else if(!xStrcmp(inputtext, ">> Sonraki Sayfa"))
			{
				SetPVarInt(playerid, "xvKeysPage", GetPVarInt(playerid, "xvKeysPage")+1);
			
				new query[128], Cache:vehs;
				mysql_format(mysqlB, query, sizeof(query), "SELECT ID FROM xVehicle ORDER BY ID ASC LIMIT %d, 15", GetPVarInt(playerid, "xvKeysPage")*15);
				vehs = mysql_query(mysqlB, query);
				new rows = cache_num_rows();
				if(rows)
				{
					new list[512], v_id;
					format(list, sizeof(list), "Ara� ID\tPlaka\tAra� Ad�\n");
					for(new i; i < rows; ++i)
					{
						cache_get_value_name_int(i, "ID", v_id);
						format(list, sizeof(list), "%s%d\t%s\t%s\n", list, v_id, xVehicle[v_id][xv_Plaka], GetVehicleNameFromModel(xVehicle[v_id][xv_ModelID]));
					}
					format(list, sizeof(list), "%s{F4D00B}<< �nceki Sayfa\n{F4D00B}>> Sonraki Sayfa", list);
					new head[32];
					format(head, sizeof(head), "Ara� Listesi (Sayfa %d)", GetPVarInt(playerid, "xvKeysPage")+1);
					ShowPlayerDialog(playerid, XV_DIALOGID+17, DIALOG_STYLE_TABLIST_HEADERS, head, list, "Se�", "Geri");
				}
				else
				{
					SetPVarInt(playerid, "xvKeysPage", GetPVarInt(playerid, "xvKeysPage") - 1);
					mysql_format(mysqlB, query, sizeof(query), "SELECT ID FROM xVehicle ORDER BY ID ASC LIMIT %d, 15", GetPVarInt(playerid, "xvKeysPage")*15);
					vehs = mysql_query(mysqlB, query);
					rows = cache_num_rows();
					if(rows)
					{
						new list[512], v_id;
						format(list, sizeof(list), "Ara� ID\tPlaka\tAra� Ad�\n");
						for(new i; i < rows; ++i)
						{
							cache_get_value_name_int(i, "ID", v_id);
							format(list, sizeof(list), "%s%d\t%s\t%s\n", list, v_id, xVehicle[v_id][xv_Plaka], GetVehicleNameFromModel(xVehicle[v_id][xv_ModelID]));
						}
						format(list, sizeof(list), "%s{F4D00B}<< �nceki Sayfa\n{F4D00B}>> Sonraki Sayfa", list);
						new head[32];
						format(head, sizeof(head), "Ara� Listesi (Sayfa %d)", GetPVarInt(playerid, "xvKeysPage")+1);
						ShowPlayerDialog(playerid, XV_DIALOGID+17, DIALOG_STYLE_TABLIST_HEADERS, head, list, "Se�", "Geri");
					}
					SendClientMessage(playerid, 0xE74C3CFF, "Ba�ka ara� yok! Son sayfadas�n�z.");
				}
				cache_delete(vehs);
			}
			else
			{
				new tm[2][8];
				split(inputtext, tm, '\t');
				SetPVarInt(playerid, "adm_sl_id", strval(tm[0]));
				ShowPlayerDialog(playerid, XV_DIALOGID+18, DIALOG_STYLE_LIST, "xVehicle Admin Men�s�", "{ECCB13}� {FFFFFF}Ara� Bilgilerini G�r\n{ECCB13}� {FFFFFF}Arac� �ek\n{ECCB13}� {FFFFFF}Arac� Yenile\n{ECCB13}� {FFFFFF}Arac�n Fiyat�n� De�i�tir\n{ECCB13}� {FFFFFF}Arac�n Sahibini Sil\n{ECCB13}� {FFFFFF}Arac� Sil", "Se�", "Geri");
			}
		} else cmd_amenu(playerid, "");
	}
	
	if(dialogid == XV_DIALOGID+18)
	{
		if(response)
		{
			new xid = GetPVarInt(playerid, "adm_sl_id");
			if(xid == 0 || !Iter_Contains(xVehicles, xid)) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Ara� bulunamad�!");
			switch(listitem)
			{
				case 0: // ara� bilgileri
				{
					new str[256], sahip[24];
					if(!strlen(xVehicle[xid][xv_Sahip])) format(sahip, sizeof(sahip), "-Sat�l�k-");
					else format(sahip, sizeof(sahip), "%s", xVehicle[xid][xv_Sahip]);
					format(str, sizeof(str), "{FFFFFF}----------[ Ara� Bilgileri ]----------\n\n{F0AE0F}-� {ECE913}Sahibi: {FFFFFF}%s\n{F0AE0F}-� {ECE913}Ara� Ad�: {FFFFFF}%s\n{F0AE0F}-� {ECE913}Plakas�: {FFFFFF}%s\n{F0AE0F}-� {ECE913}Durumu: %s", sahip, GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]), xVehicle[xid][xv_Plaka], (xVehicle[xid][xv_Garajda]) ? ("{F0CE0F}Garajda") : ("{8FE01F}Haritada"));
					ShowPlayerDialog(playerid, XV_DIALOGID+19, DIALOG_STYLE_MSGBOX, "Ara� Bilgileri", str, "Geri", "");
				}
				case 1: // arac� �ek
				{
					GetPlayerPos(playerid, xVehicle[xid][xv_Pos][0], xVehicle[xid][xv_Pos][1], xVehicle[xid][xv_Pos][2]);
					GetPlayerFacingAngle(playerid, xVehicle[xid][xv_Pos][3]);
					xVehicle[xid][xv_Pos][0] += 1;
					xVehicle[xid][xv_Pos][1] += 1;
					if(xVehicle[xid][xv_Garajda])
					{
						xVehicle[xid][xv_Veh] = CreateVehicle(xVehicle[xid][xv_ModelID], xVehicle[xid][xv_Pos][0], xVehicle[xid][xv_Pos][1], xVehicle[xid][xv_Pos][2], xVehicle[xid][xv_Pos][3], xVehicle[xid][xv_Renk][0], xVehicle[xid][xv_Renk][1], -1);
						xVeh[xVehicle[xid][xv_Veh]] = xid;
						SetVehicleNumberPlate(xVehicle[xid][xv_Veh], xVehicle[xid][xv_Plaka]);
						SetVehicleToRespawn(xVehicle[xid][xv_Veh]);
						xVehicle[xid][xv_Garajda] = 0;
					}
					else
					{
						SetVehiclePos(xVehicle[xid][xv_Veh], xVehicle[xid][xv_Pos][0], xVehicle[xid][xv_Pos][1], xVehicle[xid][xv_Pos][2]);
						SetVehicleZAngle(xVehicle[xid][xv_Veh], xVehicle[xid][xv_Pos][3]);
					}
					DeletePVar(playerid, "adm_sl_id");
					new str[128];
					format(str, sizeof(str), "{ECEC13}%s {FFFB93}plakal�, {ECEC13}%s {FFFB93}adl� arac� yan�n�za �ektiniz! {ECB021}(ID: %d)", xVehicle[xid][xv_Plaka], GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]), xid);
					SendClientMessage(playerid, -1, str);
				}
				case 2: // yenile
				{
					if(xVehicle[xid][xv_Garajda]) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Garajdaki arac� yenileyemezsiniz!");
					SetVehicleToRespawn(xVehicle[xid][xv_Veh]);
					SendClientMessage(playerid, -1, "{00BD00}[!] {00FF00}Arac� yenilediniz!");
				}
				case 3: // fiyat�n� de�i�tir
				{
					new str[128];
					format(str, sizeof(str), "{FFFB93}Arac�n mevcut fiyat�: {ECEC13}$%d\n\n{FFFB93}De�i�tirmek istedi�iniz fiyat� yaz�n:", xVehicle[xid][xv_Fiyat]);
					ShowPlayerDialog(playerid, XV_DIALOGID+26, DIALOG_STYLE_INPUT, "Fiyat De�i�tir", str, "Tamam", "Geri");
				}
				case 4: // ara� sahibini sil
				{
					new str[256];
					format(str, sizeof(str), "{ECEC13}%s {FFFB93}plakal�, {ECEC13}%s {FFFB93}adl� arac�n {ECB021}(ID: %d) {FFFB93}sahibini silmek istedi�inize emin misiniz?\n{AAAAAA}(Ara� sat�l��a ��kacakt�r ve arac�n anahtar� olan oyuncular�n anahtar� silinecektir.)", xVehicle[xid][xv_Plaka], GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]), xid);
					ShowPlayerDialog(playerid, XV_DIALOGID+20, DIALOG_STYLE_MSGBOX, "Ara� Sahibini Sil", str, "Onayla", "Geri");
				}
				case 5: // arac� sil
				{
					new str[128];
					format(str, sizeof(str), "{ECEC13}%s {FFFB93}plakal�, {ECEC13}%s {FFFB93}adl� arac� {ECB021}(ID: %d) {FFFB93}silmek istedi�inize emin misiniz?", xVehicle[xid][xv_Plaka], GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]), xid);
					ShowPlayerDialog(playerid, XV_DIALOGID+21, DIALOG_STYLE_MSGBOX, "Arac� Sil", str, "Onayla", "Geri");
				}
			}
		}
		else
		{
			DeletePVar(playerid, "adm_sl_id");
			cmd_amenu(playerid, "");
		}
	}
	
	if(dialogid == XV_DIALOGID+19) ShowPlayerDialog(playerid, XV_DIALOGID+18, DIALOG_STYLE_LIST, "xVehicle Admin Men�s�", "{ECCB13}� {FFFFFF}Ara� Bilgilerini G�r\n{ECCB13}� {FFFFFF}Arac� �ek\n{ECCB13}� {FFFFFF}Arac� Yenile\n{ECCB13}� {FFFFFF}Arac�n Fiyat�n� De�i�tir\n{ECCB13}� {FFFFFF}Arac�n Sahibini Sil\n{ECCB13}� {FFFFFF}Arac� Sil", "Se�", "Geri");
	
	if(dialogid == XV_DIALOGID+20)
	{
		if(response)
		{
			new xid = GetPVarInt(playerid, "adm_sl_id");
			if(xid == 0 || !Iter_Contains(xVehicles, xid)) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Ara� bulunamad�!");
			if(!strlen(xVehicle[xid][xv_Sahip])) return ShowPlayerDialog(playerid, XV_DIALOGID+19, DIALOG_STYLE_MSGBOX, "Ara� Sahibini Sil", "{FF0000}[!] {DCDC22}Bu arac�n zaten bir sahibi yok!", "Geri", "");
			format(xVehicle[xid][xv_Sahip], 24, "");
			foreach(new i : Player)
			{
				if(IsPlayerInVehicle(i, xVehicle[xid][xv_Veh]))
				{
					SendClientMessage(i, -1, "{FF0000}[!] {DCDC22}Bu arac�n sahibi admin taraf�ndan silindi�i i�in ara�tan indirildiniz.");
					RemovePlayerFromVehicle(i);
				}
				if(Iter_Contains(xVehicleKeys<i>, xid)) Iter_Remove(xVehicleKeys<i>, xid);
			}
			new str[128];
			mysql_format(mysqlB, str, sizeof(str), "DELETE FROM xVehicleKeys WHERE AracID=%d", xid);
			mysql_query(mysqlB, str);
			SavexVehicle(xid);
			format(str, sizeof(str), "{00FF00}Bu Ara� Sat�l�k!\n{FFA500}Ad�: {FFFFFF}%s\n{FFA500}Plaka: {FFFFFF}%s\n{FFA500}Fiyat�: {00FF00}$%d", GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]), xVehicle[xid][xv_Plaka], xVehicle[xid][xv_Fiyat]);
			xVehicle[xid][xv_Text] = Create3DTextLabel(str, 0x008080FF, 0.0, 0.0, 0.0, 50.0, 0);
			Attach3DTextLabelToVehicle(xVehicle[xid][xv_Text], xVehicle[xid][xv_Veh], 0.0, 0.0, 1.0);
			DeletePVar(playerid, "adm_sl_id");
			format(str, sizeof(str), "{ECB021}%d {FFFB93}ID'li arac�n sahibini sildiniz.", xid);
			SendClientMessage(playerid, -1, str);
		} else ShowPlayerDialog(playerid, XV_DIALOGID+18, DIALOG_STYLE_LIST, "xVehicle Admin Men�s�", "{ECCB13}� {FFFFFF}Ara� Bilgilerini G�r\n{ECCB13}� {FFFFFF}Arac� �ek\n{ECCB13}� {FFFFFF}Arac� Yenile\n{ECCB13}� {FFFFFF}Arac�n Fiyat�n� De�i�tir\n{ECCB13}� {FFFFFF}Arac�n Sahibini Sil\n{ECCB13}� {FFFFFF}Arac� Sil", "Se�", "Geri");
	}
	
	if(dialogid == XV_DIALOGID+21)
	{
		if(response)
		{
			new xid = GetPVarInt(playerid, "adm_sl_id");
			if(xid == 0 || !Iter_Contains(xVehicles, xid)) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Ara� bulunamad�!");
			DestroyVehicle(xVehicle[xid][xv_Veh]);
			Iter_Remove(xVehicles, xid);
			DeletePVar(playerid, "adm_sl_id");
			foreach(new i : Player)
			{
				if(Iter_Contains(xVehicleKeys<i>, xid)) Iter_Remove(xVehicleKeys<i>, xid);
			}
			new query[128];
			mysql_format(mysqlB, query, sizeof(query), "DELETE FROM xVehicleKeys WHERE AracID=%d", xid);
			mysql_query(mysqlB, query);
			mysql_format(mysqlB, query, sizeof(query), "DELETE FROM xVehicle WHERE ID=%d", xid);
			mysql_query(mysqlB, query);
			format(query, sizeof(query), "{ECB021}%d {FFFB93}ID'li arac� ba�ar�yla sildiniz.", xid);
			SendClientMessage(playerid, -1, query);
		} else ShowPlayerDialog(playerid, XV_DIALOGID+18, DIALOG_STYLE_LIST, "xVehicle Admin Men�s�", "{ECCB13}� {FFFFFF}Ara� Bilgilerini G�r\n{ECCB13}� {FFFFFF}Arac� �ek\n{ECCB13}� {FFFFFF}Arac� Yenile\n{ECCB13}� {FFFFFF}Arac�n Fiyat�n� De�i�tir\n{ECCB13}� {FFFFFF}Arac�n Sahibini Sil\n{ECCB13}� {FFFFFF}Arac� Sil", "Se�", "Geri");
	}
	
	if(dialogid == XV_DIALOGID+22)
	{
		if(response)
		{
			if(!strlen(inputtext)) return ShowPlayerDialog(playerid, XV_DIALOGID+22, DIALOG_STYLE_INPUT, "Ara� Olu�tur", "{FF0000}[!] {F0AE0F}Hi�bir �ey yazmad�n�z!\n\n{FFFB93}Olu�turulacak arac�n ad�n� veya Model ID'sini girin:", "�leri", "Geri");
			new veh;
			if(!isNumeric(inputtext)) veh = GetVehicleModelIDFromName(inputtext); else veh = strval(inputtext);
			if(veh < 400 || veh > 611) return ShowPlayerDialog(playerid, XV_DIALOGID+22, DIALOG_STYLE_INPUT, "Ara� Olu�tur", "{FF0000}[!] {F0AE0F}Ge�ersiz ara� ad� veya ID'si!\n\n{FFFB93}Olu�turulacak arac�n ad�n� veya Model ID'sini girin:", "�leri", "Geri");
			SetPVarInt(playerid, "xv_ao_model", veh);
			new str[192];
			format(str, sizeof(str), "{00BD00}[!] {00FF00}Se�ilen model: {ECEC13}%s {ECB021}(%d)\n\n{FFFB93}Olu�turulacak arac�n 1. rengini girin:\n{AAAAAA}(0-255 aras�)", GetVehicleNameFromModel(GetPVarInt(playerid, "xv_ao_model")), GetPVarInt(playerid, "xv_ao_model"));
			ShowPlayerDialog(playerid, XV_DIALOGID+23, DIALOG_STYLE_INPUT, "Ara� Olu�tur - Renk", str, "Ileri", "Geri");
		} else cmd_amenu(playerid, "");
	}
	
	if(dialogid == XV_DIALOGID+23)
	{
		if(response)
		{
			if(!strlen(inputtext)) return ShowPlayerDialog(playerid, XV_DIALOGID+23, DIALOG_STYLE_INPUT, "Ara� Olu�tur - Renk", "{FF0000}[!] {F0AE0F}Hi�bir �ey yazmad�n�z!\n\n{FFFB93}Olu�turulacak arac�n 1. rengini girin:\n{AAAAAA}(0-255 aras�)", "Ileri", "Geri");
			if(!isNumeric(inputtext))return ShowPlayerDialog(playerid, XV_DIALOGID+23, DIALOG_STYLE_INPUT, "Ara� Olu�tur - Renk", "{FF0000}[!] {F0AE0F}Yaln�zca rakam girin!\n\n{FFFB93}Olu�turulacak arac�n 1. rengini girin:\n{AAAAAA}(0-255 aras�)", "Ileri", "Geri");
			if(strval(inputtext) < 0 || strval(inputtext) > 255) return ShowPlayerDialog(playerid, XV_DIALOGID+23, DIALOG_STYLE_INPUT, "Ara� Olu�tur - Renk", "{FF0000}[!] {F0AE0F}0 ile 255 aras� bir de�er girin!\n\n{FFFB93}Olu�turulacak arac�n 1. rengini girin:\n{AAAAAA}(0-255 aras�)", "Ileri", "Geri");
			SetPVarInt(playerid, "xv_ao_col1", strval(inputtext));
			new str[128];
			format(str, sizeof(str), "{00BD00}[!] {00FF00}Se�ilen 1. renk: {ECEC13}%d\n\n{FFFB93}Olu�turulacak arac�n 2. rengini girin:\n{AAAAAA}(0-255 aras�)", GetPVarInt(playerid, "xv_ao_col1"));
			ShowPlayerDialog(playerid, XV_DIALOGID+24, DIALOG_STYLE_INPUT, "Ara� Olu�tur - Renk", str, "Ileri", "Geri");
		} else DeletePVar(playerid, "xv_ao_model"), ShowPlayerDialog(playerid, XV_DIALOGID+22, DIALOG_STYLE_INPUT, "Ara� Olu�tur", "{FFFB93}Olu�turulacak arac�n ad�n� veya Model ID'sini girin:", "�leri", "Geri");
	}
	
	if(dialogid == XV_DIALOGID+24)
	{
		if(response)
		{
			if(!strlen(inputtext)) return ShowPlayerDialog(playerid, XV_DIALOGID+24, DIALOG_STYLE_INPUT, "Ara� Olu�tur - Renk", "{FF0000}[!] {F0AE0F}Hi�bir �ey yazmad�n�z!\n\n{FFFB93}Olu�turulacak arac�n 2. rengini girin:\n{AAAAAA}(0-255 aras�)", "Ileri", "Geri");
			if(!isNumeric(inputtext))return ShowPlayerDialog(playerid, XV_DIALOGID+24, DIALOG_STYLE_INPUT, "Ara� Olu�tur - Renk", "{FF0000}[!] {F0AE0F}Yaln�zca rakam girin!\n\n{FFFB93}Olu�turulacak arac�n 2. rengini girin:\n{AAAAAA}(0-255 aras�)", "Ileri", "Geri");
			if(strval(inputtext) < 0 || strval(inputtext) > 255) return ShowPlayerDialog(playerid, XV_DIALOGID+24, DIALOG_STYLE_INPUT, "Ara� Olu�tur - Renk", "{FF0000}[!] {F0AE0F}0 ile 255 aras� bir de�er girin!\n\n{FFFB93}Olu�turulacak arac�n 2. rengini girin:\n{AAAAAA}(0-255 aras�)", "Ileri", "Geri");
			SetPVarInt(playerid, "xv_ao_col2", strval(inputtext));
			new str[128];
			format(str, sizeof(str), "{00BD00}[!] {00FF00}Se�ilen 2. renk: {ECEC13}%d\n\n{FFFB93}Olu�turulacak arac�n fiyat�n� girin:", GetPVarInt(playerid, "xv_ao_col2"));
			ShowPlayerDialog(playerid, XV_DIALOGID+25, DIALOG_STYLE_INPUT, "Ara� Olu�tur - Fiyat", str, "Olu�tur", "Geri");
		}
		else
		{
			DeletePVar(playerid, "xv_ao_col1");
			new str[192];
			format(str, sizeof(str), "{00BD00}[!] {00FF00}Se�ilen model: {ECEC13}%s {ECB021}(%d)\n\n{FFFB93}Olu�turulacak arac�n 1. rengini girin:\n{AAAAAA}(0-255 aras�)", GetVehicleNameFromModel(GetPVarInt(playerid, "xv_ao_model")), GetPVarInt(playerid, "xv_ao_model"));
			ShowPlayerDialog(playerid, XV_DIALOGID+23, DIALOG_STYLE_INPUT, "Ara� Olu�tur - Renk", str, "Ileri", "Geri");
		}
	}
	
	if(dialogid == XV_DIALOGID+25)
	{
		if(response)
		{
			if(!strlen(inputtext)) return ShowPlayerDialog(playerid, XV_DIALOGID+25, DIALOG_STYLE_INPUT, "Ara� Olu�tur - Fiyat", "{FF0000}[!] {F0AE0F}Hi�bir �ey yazmad�n�z!\n\n{FFFB93}Olu�turulacak arac�n fiyat�n� girin:", "Olu�tur", "Geri");
			if(!isNumeric(inputtext))return ShowPlayerDialog(playerid, XV_DIALOGID+25, DIALOG_STYLE_INPUT, "Ara� Olu�tur - Fiyat", "{FF0000}[!] {F0AE0F}Yaln�zca rakam girin!\n\n{FFFB93}Olu�turulacak arac�n fiyat�n� girin:", "Olu�tur", "Geri");
			if(strval(inputtext) < 0) return ShowPlayerDialog(playerid, XV_DIALOGID+25, DIALOG_STYLE_INPUT, "Ara� Olu�tur - Fiyat", "{FF0000}[!] {F0AE0F}Sadece pozitif de�er girin!\n\n{FFFB93}Olu�turulacak arac�n fiyat�n� girin:", "Olu�tur", "Geri");
			new tmp_var[3], Float:ppos[4], veh, xid;
			tmp_var[0] = GetPVarInt(playerid, "xv_ao_model");
			tmp_var[1] = GetPVarInt(playerid, "xv_ao_col1");
			tmp_var[2] = GetPVarInt(playerid, "xv_ao_col2");
			GetPlayerPos(playerid, ppos[0], ppos[1], ppos[2]);
			GetPlayerFacingAngle(playerid, ppos[3]);
			veh = CreatexVehicle(tmp_var[0], "", strval(inputtext), ppos[0], ppos[1], ppos[2], ppos[3], tmp_var[1], tmp_var[2]);
			xid = xVeh[veh];
			PutPlayerInVehicle(playerid, veh, 0);
			new str[256]; 
			SendClientMessage(playerid, -1, "------------------------------------------------------------------------------------------------------------");
			format(str, sizeof(str), "{00FF00}[!] {ECEC13}%s {ECB021}(%d) {FFFB93}model ara�, {ECEC13}%d, %d {FFFB93}renkleriyle ba�ar�yla olu�turuldu!", GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]), xVehicle[xid][xv_ModelID], xVehicle[xid][xv_Renk][0], xVehicle[xid][xv_Renk][1]);
			SendClientMessage(playerid, -1, str);
			format(str, sizeof(str), "{FFFB93}Verilen plaka: {ECEC13}%s, {FFFB93}Ara� ID'si: {ECB021}%d, {FFFB93}Fiyat�: {ECB021}$%d", xVehicle[xid][xv_Plaka], xid, xVehicle[xid][xv_Fiyat]);
			SendClientMessage(playerid, -1, str);
			SendClientMessage(playerid, -1, "{FFFB93}Sat�l�k arac�n konumunu de�i�tirmek i�in, araca binip istedi�iniz yere gidin ve {ECEC13}/parket {FFFB93}yaz�n.");
			SendClientMessage(playerid, -1, "------------------------------------------------------------------------------------------------------------");
			DeletePVar(playerid, "xv_ao_model");
			DeletePVar(playerid, "xv_ao_col1");
			DeletePVar(playerid, "xv_ao_col2");
		}
		else
		{
			DeletePVar(playerid, "xv_ao_col2");
			new str[128];
			format(str, sizeof(str), "{00BD00}[!] {00FF00}Se�ilen 1. renk: {ECEC13}%d\n\n{FFFB93}Olu�turulacak arac�n 2. rengini girin:\n{AAAAAA}(0-255 aras�)", GetPVarInt(playerid, "xv_ao_col1"));
			ShowPlayerDialog(playerid, XV_DIALOGID+24, DIALOG_STYLE_INPUT, "Ara� Olu�tur - Renk", str, "Ileri", "Geri");
		}
	}
	
	if(dialogid == XV_DIALOGID+26)
	{
		if(response)
		{
			new xid = GetPVarInt(playerid, "adm_sl_id");
			if(xid == 0 || !Iter_Contains(xVehicles, xid)) return SendClientMessage(playerid, -1, "{FF0000}[!] {F0AE0F}Ara� bulunamad�!");
			if(!strlen(inputtext)) return ShowPlayerDialog(playerid, XV_DIALOGID+26, DIALOG_STYLE_INPUT, "Fiyat De�i�tir", "{FF0000}[!] {F0AE0F}Hi�bir �ey yazmad�n�z!\n\n{FFFB93}De�i�tirmek istedi�iniz fiyat� yaz�n:", "Tamam", "Geri");
			if(!isNumeric(inputtext)) return ShowPlayerDialog(playerid, XV_DIALOGID+26, DIALOG_STYLE_INPUT, "Fiyat De�i�tir", "{FF0000}[!] {F0AE0F}Yaln�zca rakam girin!\n\n{FFFB93}De�i�tirmek istedi�iniz fiyat� yaz�n:", "Tamam", "Geri");
			if(strval(inputtext) < 0) return ShowPlayerDialog(playerid, XV_DIALOGID+26, DIALOG_STYLE_INPUT, "Fiyat De�i�tir", "{FF0000}[!] {F0AE0F}Sadece pozitif de�er girin!\n\n{FFFB93}De�i�tirmek istedi�iniz fiyat� yaz�n:", "Tamam", "Geri");
			xVehicle[xid][xv_Fiyat] = strval(inputtext);
			new str[128];
			if(!strlen(xVehicle[xid][xv_Sahip]))
			{
				Delete3DTextLabel(xVehicle[xid][xv_Text]);
				format(str, sizeof(str), "{00FF00}Bu Ara� Sat�l�k!\n{FFA500}Ad�: {FFFFFF}%s\n{FFA500}Plaka: {FFFFFF}%s\n{FFA500}Fiyat�: {00FF00}$%d", GetVehicleNameFromModel(xVehicle[xid][xv_ModelID]), xVehicle[xid][xv_Plaka], xVehicle[xid][xv_Fiyat]);
				xVehicle[xid][xv_Text] = Create3DTextLabel(str, 0x008080FF, 0.0, 0.0, 0.0, 50.0, 0);
				Attach3DTextLabelToVehicle(xVehicle[xid][xv_Text], xVehicle[xid][xv_Veh], 0.0, 0.0, 1.0);
			}
			SavexVehicle(xid);
			format(str, sizeof(str), "{00BD00}[!] {00FF00}Arac�n fiyat� {ECEC13}$%d {00FF00}olarak de�i�tirildi!", xVehicle[xid][xv_Fiyat]);
			SendClientMessage(playerid, -1, str);
		} 
		ShowPlayerDialog(playerid, XV_DIALOGID+18, DIALOG_STYLE_LIST, "xVehicle Admin Men�s�", "{ECCB13}� {FFFFFF}Ara� Bilgilerini G�r\n{ECCB13}� {FFFFFF}Arac� �ek\n{ECCB13}� {FFFFFF}Arac� Yenile\n{ECCB13}� {FFFFFF}Arac�n Fiyat�n� De�i�tir\n{ECCB13}� {FFFFFF}Arac�n Sahibini Sil\n{ECCB13}� {FFFFFF}Arac� Sil", "Se�", "Geri");
	}
	return 1;
}

xvMenuGoster(playerid)
{
	new str[256], tmp[8], xid;
	GetPVarString(playerid, "selected_veh_plate", tmp, 8);
	xid = GetVehiclexIDFromPlate(tmp);
	if(xid == 0) return 1;
	format(str, sizeof(str), "{FFA500}� {FFFFFF} Ara� Nerede?\n%s\n{FFA500}� {FFFFFF} H�zl� Park\n{FFA500}� {%s} Arac�n Anahtarlar�\n{FFA500}� {%s} Arac� Sat\n{FFA500}� {CACACA} Ara� Bilgileri", 
	(xVehicle[xid][xv_Garajda]) ? (!xStrcmp(xVehicle[xid][xv_Sahip], Isim(playerid))) ? ("{FFA500}� {FFFFFF} Arac� Garajdan ��kar") : ("{FFA500}� {FF0000} Arac� Garajdan ��kar") : (!xStrcmp(xVehicle[xid][xv_Sahip], Isim(playerid))) ? ("{FFA500}� {FFFFFF} Arac� Garaja Koy") : ("{FFA500}� {FF0000} Arac� Garaja Koy"), (xStrcmp(xVehicle[xid][xv_Sahip], Isim(playerid))) ? ("FF0000") : ("FFFFFF"), (xStrcmp(xVehicle[xid][xv_Sahip], Isim(playerid))) ? ("FF0000") : ("FFFFFF"));
	ShowPlayerDialog(playerid, XV_DIALOGID, DIALOG_STYLE_LIST, "Ara� Men�s�", str, "Se�", "Geri");
	return 1;
}

forward TeklifBitir(gonderen, alan);
public TeklifBitir(gonderen, alan)
{
	SetPVarInt(alan, "xv_teklif_gonderen", INVALID_PLAYER_ID);
	DeletePVar(alan, "xv_teklif_xid");
	DeletePVar(alan, "xv_teklif_fiyat");
	if(IsPlayerConnected(gonderen)) SetPVarInt(gonderen, "xv_teklif_id", INVALID_PLAYER_ID), SendClientMessage(gonderen, -1, "{FF0000}[!] {DCDC22}Ara� satmay� teklif etti�iniz oyuncu zaman�nda yan�tlamad��� i�in teklif iptal edildi.");
	return 1;
}

CreatexVehicle(modelid, owner[], price, Float:spawn_x, Float:spawn_y, Float:spawn_z, Float:z_angle, color1, color2)
{
	new id = Iter_Free(xVehicles);
	
	xVehicle[id][xv_Veh] = CreateVehicle(modelid, spawn_x, spawn_y, spawn_z, z_angle, color1, color2, -1);
	
	xVeh[xVehicle[id][xv_Veh]] = id;
	xVehicle[id][xv_ModelID] = modelid;
	xVehicle[id][xv_Renk][0] = color1;
	xVehicle[id][xv_Renk][1] = color2;
	xVehicle[id][xv_Paintjob] = -1;
	xVehicle[id][xv_Pos][0] = spawn_x;
	xVehicle[id][xv_Pos][1] = spawn_y;
	xVehicle[id][xv_Pos][2] = spawn_z;
	xVehicle[id][xv_Pos][3] = z_angle;
	format(xVehicle[id][xv_Sahip], 24, "%s", owner);
	xVehicle[id][xv_Fiyat] = price;
	plate_check:
	format(xVehicle[id][xv_Plaka], 8, "%s", CreatePlate());
	foreach(new i : xVehicles) if(!xStrcmp(xVehicle[id][xv_Plaka], xVehicle[i][xv_Plaka])) goto plate_check;
	SetVehicleNumberPlate(xVehicle[id][xv_Veh], xVehicle[id][xv_Plaka]);
	SetVehicleToRespawn(xVehicle[id][xv_Veh]);
	Iter_Add(xVehicles, id);
	new query[256];
	format(query, sizeof(query),"INSERT INTO `xVehicle` (`ID`,`Sahip`,`Fiyat`,`X`,`Y`,`Z`,`A`,`Model`,`Renk1`,`Renk2`,`Plaka`) VALUES ('%d','%s','%d','%f','%f','%f','%f','%d','%d','%d','%s')",
	id, owner, price, spawn_x, spawn_y, spawn_z, z_angle, modelid, color1, color2, xVehicle[id][xv_Plaka]);
	mysql_query(mysqlB, query);
	
	if(!strlen(xVehicle[id][xv_Sahip]))
	{
		new str[128];
		format(str, sizeof(str), "{00FF00}Bu Ara� Sat�l�k!\n{FFA500}Ad�: {FFFFFF}%s\n{FFA500}Plaka: {FFFFFF}%s\n{FFA500}Fiyat�: {00FF00}$%d", GetVehicleNameFromModel(xVehicle[id][xv_ModelID]), xVehicle[id][xv_Plaka], xVehicle[id][xv_Fiyat]);
		xVehicle[id][xv_Text] = Create3DTextLabel(str, 0x008080FF, 0.0, 0.0, 0.0, 50.0, 0);
		Attach3DTextLabelToVehicle(xVehicle[id][xv_Text], xVehicle[id][xv_Veh], 0.0, 0.0, 1.0);
	}
	return xVehicle[id][xv_Veh];
}

SavexVehicle(xvehid)
{
	if(xvehid == 0) return 0;
	new query[512];
	
	mysql_format(mysqlB, query, sizeof(query), "UPDATE `xVehicle` SET Sahip='%e', Fiyat=%d, X=%f, Y=%f, Z=%f, A=%f, HizliPark=%d, Model=%d, Renk1=%d, Renk2=%d, Plaka='%s', PJ=%d, Garajda=%d, Parca1=%d, Parca2=%d, Parca3=%d, Parca4=%d, Parca5=%d, Parca6=%d, Parca7=%d, Parca8=%d, Parca9=%d, Parca10=%d, Parca11=%d, Parca12=%d, Parca13=%d, Parca14=%d WHERE ID=%d",
	xVehicle[xvehid][xv_Sahip], xVehicle[xvehid][xv_Fiyat], xVehicle[xvehid][xv_Pos][0], xVehicle[xvehid][xv_Pos][1], xVehicle[xvehid][xv_Pos][2], xVehicle[xvehid][xv_Pos][3], xVehicle[xvehid][xv_HizliPark], xVehicle[xvehid][xv_ModelID], xVehicle[xvehid][xv_Renk][0], xVehicle[xvehid][xv_Renk][1], xVehicle[xvehid][xv_Plaka], xVehicle[xvehid][xv_Paintjob], xVehicle[xvehid][xv_Garajda],
	xVehicle[xvehid][xv_Parca][0],
	xVehicle[xvehid][xv_Parca][1],
	xVehicle[xvehid][xv_Parca][2],
	xVehicle[xvehid][xv_Parca][3],
	xVehicle[xvehid][xv_Parca][4],
	xVehicle[xvehid][xv_Parca][5],
	xVehicle[xvehid][xv_Parca][6],
	xVehicle[xvehid][xv_Parca][7],
	xVehicle[xvehid][xv_Parca][8],
	xVehicle[xvehid][xv_Parca][9],
	xVehicle[xvehid][xv_Parca][10],
	xVehicle[xvehid][xv_Parca][11],
	xVehicle[xvehid][xv_Parca][12],
	xVehicle[xvehid][xv_Parca][13],
	xvehid);
	mysql_query(mysqlB, query);
	return 1;
}

forward LoadxVehicles();
public LoadxVehicles()
{
	new rows = cache_num_rows();
	new id, loaded;
 	if(rows)
  	{
		while(loaded < rows)
		{
  			cache_get_value_name_int(loaded, "ID", id);
	    	cache_get_value_name(loaded, "Sahip", xVehicle[id][xv_Sahip], MAX_PLAYER_NAME);
		    cache_get_value_name_int(loaded, "Fiyat", xVehicle[id][xv_Fiyat]);
		    cache_get_value_name_float(loaded, "X", xVehicle[id][xv_Pos][0]);
		    cache_get_value_name_float(loaded, "Y", xVehicle[id][xv_Pos][1]);
		    cache_get_value_name_float(loaded, "Z", xVehicle[id][xv_Pos][2]);
		    cache_get_value_name_float(loaded, "A", xVehicle[id][xv_Pos][3]);
		    cache_get_value_name_int(loaded, "HizliPark", xVehicle[id][xv_HizliPark]);
		    cache_get_value_name_int(loaded, "Model", xVehicle[id][xv_ModelID]);
		    cache_get_value_name_int(loaded, "Renk1", xVehicle[id][xv_Renk][0]);
		    cache_get_value_name_int(loaded, "Renk2", xVehicle[id][xv_Renk][1]);
			cache_get_value_name(loaded, "Plaka", xVehicle[id][xv_Plaka], 8);
			cache_get_value_name_int(loaded, "Garajda", xVehicle[id][xv_Garajda]);
		    cache_get_value_name_int(loaded, "PJ", xVehicle[id][xv_Paintjob]);
		    cache_get_value_name_int(loaded, "Parca1", xVehicle[id][xv_Parca][0]);
		    cache_get_value_name_int(loaded, "Parca2", xVehicle[id][xv_Parca][1]);
		    cache_get_value_name_int(loaded, "Parca3", xVehicle[id][xv_Parca][2]);
		    cache_get_value_name_int(loaded, "Parca4", xVehicle[id][xv_Parca][3]);
		    cache_get_value_name_int(loaded, "Parca5", xVehicle[id][xv_Parca][4]);
		    cache_get_value_name_int(loaded, "Parca6", xVehicle[id][xv_Parca][5]);
		    cache_get_value_name_int(loaded, "Parca7", xVehicle[id][xv_Parca][6]);
		    cache_get_value_name_int(loaded, "Parca8", xVehicle[id][xv_Parca][7]);
		    cache_get_value_name_int(loaded, "Parca9", xVehicle[id][xv_Parca][8]);
		    cache_get_value_name_int(loaded, "Parca10", xVehicle[id][xv_Parca][9]);
		    cache_get_value_name_int(loaded, "Parca11", xVehicle[id][xv_Parca][10]);
		    cache_get_value_name_int(loaded, "Parca12", xVehicle[id][xv_Parca][11]);
		    cache_get_value_name_int(loaded, "Parca13", xVehicle[id][xv_Parca][12]);
		    cache_get_value_name_int(loaded, "Parca14", xVehicle[id][xv_Parca][13]);
			
			if(!xVehicle[id][xv_Garajda])
			{
				xVehicle[id][xv_Veh] = CreateVehicle(xVehicle[id][xv_ModelID], xVehicle[id][xv_Pos][0], xVehicle[id][xv_Pos][1], xVehicle[id][xv_Pos][2], xVehicle[id][xv_Pos][3], xVehicle[id][xv_Renk][0], xVehicle[id][xv_Renk][1], -1);
				xVeh[xVehicle[id][xv_Veh]] = id;
				SetVehicleNumberPlate(xVehicle[id][xv_Veh], xVehicle[id][xv_Plaka]);
				SetVehicleToRespawn(xVehicle[id][xv_Veh]);
			}
			Iter_Add(xVehicles, id);
			loaded++;

			if(!strlen(xVehicle[id][xv_Sahip]))
			{
				new str[128];
				format(str, sizeof(str), "{00FF00}Bu Ara� Sat�l�k!\n{FFA500}Ad�: {FFFFFF}%s\n{FFA500}Plaka: {FFFFFF}%s\n{FFA500}Fiyat�: {00FF00}$%d", GetVehicleNameFromModel(xVehicle[id][xv_ModelID]), xVehicle[id][xv_Plaka], xVehicle[id][xv_Fiyat]);
				xVehicle[id][xv_Text] = Create3DTextLabel(str, 0x008080FF, 0.0, 0.0, 0.0, 50.0, 0);
				Attach3DTextLabelToVehicle(xVehicle[id][xv_Text], xVehicle[id][xv_Veh], 0.0, 0.0, 1.0);
			}
	    }
	}
	printf("[xVehicle] %d arac yuklendi.", loaded);
	return 1;
}

stock LoadVehicleMod(xid)
{
	for(new c; c<14; c++) AddVehicleComponent(xVehicle[xid][xv_Veh], xVehicle[xid][xv_Parca][c]);
	ChangeVehiclePaintjob(xVehicle[xid][xv_Veh], xVehicle[xid][xv_Paintjob]);
	return 1;
}

stock LoadxVehicleKeys(playerid)
{
    Iter_Clear(xVehicleKeys<playerid>);
    
    new query[72];
    mysql_format(mysqlB, query, sizeof(query), "SELECT * FROM xVehicleKeys WHERE Isim='%e'", Isim(playerid));
	mysql_tquery(mysqlB, query, "LoadCarKeys", "i", playerid);
	return 1;
}


forward LoadCarKeys(playerid);
public LoadCarKeys(playerid)
{
	if(!IsPlayerConnected(playerid)) return 1;
	new rows = cache_num_rows();
 	if(rows)
  	{
   		new loaded, vehid;
     	while(loaded < rows)
      	{
      	    cache_get_value_name_int(loaded, "AracID", vehid);
       		Iter_Add(xVehicleKeys<playerid>, vehid);
   			loaded++;
 		}
   	}

	return 1;
}

stock GetVehiclexIDFromPlate(plate[])
{
	foreach(new i : xVehicles) if(!xStrcmp(plate, xVehicle[i][xv_Plaka])) return i;
	return 0;
}

stock CreatePlate() // forum.sa-mp 'KoczkaHUN'dan al�nt�d�r...
{
	const len = 7, hyphenpos = 4;
	new plate[len+1];
	for (new i = 0; i < len; i++)
	{
		if (i + 1 == hyphenpos)
		{
			plate[i] = '-';
			continue;
		}
		if (random(2)) plate[i] = 'A' + random(26);
		else plate[i] = '0' + random(10);
	}
	return plate;
}

stock IsVehicleFlipped(vehicleid)
{
    new Float:Quat[2];
    GetVehicleRotationQuat(vehicleid, Quat[0], Quat[1], Quat[0], Quat[0]);
    return (Quat[1] >= 0.60 || Quat[1] <= -0.60);
}

stock GetPlayerxVehicleCount(playerid)
{
	new count;
	foreach(new i : xVehicles)
	{
		if(!xStrcmp(xVehicle[i][xv_Sahip], Isim(playerid))) count++;
	}
	return count;
}

stock GetPlayerInGarageVehicleCount(playerid)
{
	new count;
	foreach(new i : xVehicles)
	{
		if(!xStrcmp(xVehicle[i][xv_Sahip], Isim(playerid)) && xVehicle[i][xv_Garajda]) count++;
	}
	return count;
}

stock GetVehicleNameFromModel(modelid)
{
	new String[64];
    format(String,sizeof(String),"%s",VehicleNames[modelid - 400]);
    return String;
}

stock GetVehicleModelIDFromName(vname[])
{
	for(new i = 0; i < 211; i++)
	{
		if ( strfind(VehicleNames[i], vname, true) != -1 )
			return i + 400;
	}
	return -1;
}

stock GetPlayerIDFromName(name[])
{
	foreach(new i : Player) if(!xStrcmp(Isim(i), name)) return i;
	return INVALID_PLAYER_ID;
}

stock xStrcmp(str1[], str2[])
{
    if(strlen(str1) == strlen(str2) && strcmp(str1, str2) == 0) return 0;
	return 1;
}

stock split(const src[], dest[][], const delimiter) // wiki.samp'tan al�nt�d�r. [Yap�mc�: Kaliber|Kaliber]
{
    new n_pos,num,old,str[1];
    str[0] = delimiter;
    while(n_pos != -1)
    {
        n_pos = strfind(src,str,false,n_pos+1);
        strmid(dest[num++], src, (!num)?0:old+1,(n_pos==-1)?strlen(src):n_pos,256);
        old=n_pos;
    }
    return 1;
}

stock Isim(playerid)
{
	new ism[24];
	GetPlayerName(playerid, ism, 24);
	return ism;
}

stock isNumeric(const string[]) {
	new length=strlen(string);
	if (length==0) return false;
	for (new i = 0; i < length; i++) {
		if (
		(string[i] > '9' || string[i] < '0' && string[i]!='-' && string[i]!='+') // Not a number,'+' or '-'
		|| (string[i]=='-' && i!=0)                                             // A '-' but not at first.
		|| (string[i]=='+' && i!=0)                                             // A '+' but not at first.
		) return false;
	}
	if (length==1 && (string[0]=='-' || string[0]=='+')) return false;
	return true;
}

stock GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance)
{
	// Created by Y_Less

	new Float:a;

	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);

	if (GetPlayerVehicleID(playerid)) {
	    GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}

	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}