/**
*	Plugin: 	Clans System
*	Version: 	1.0
*	Author: 	MakapoH.
*
*	Requirements: AMX Mod X 1.9
*/

#include <amxmodx>
#include <clans_system>

#define PLUGIN_NAME 	"Clans System"
#define PLUGIN_VERSION 	"1.0"
#define PLUGIN_AUTHOR	"MakapoH."

new const parse_text[][] =
{
	"; Настройка кланов.^n^n",

	"; Шаблон:^n",
	";		[Название клана]^n",
	";		^"ник^" ^"стим айди^" ^"уровень^"^n^n",

	"; Уровень игрока создан с целью разграничить новичков от бывалых.^n",
	"; Таким образом можно распоряжатся игроками с разными уровнями.^n^n",

	"[Бывалые]^n",
	"^"PlayerName1^" ^"STEAM_0:0:12345^" 3^n",
	"^"PlayerName2^" ^"STEAM_0:0:123456^" 92^n^n",

	"[Самые слабые]^n",
	"^"PlayerName1^" ^"STEAM_0:0:1234567^" 1^n",
	"^"PlayerName2^" ^"STEAM_0:0:12345678^" 922"
};

new Array:array_clans;
new clans_data[ClanStructure];

public plugin_natives()
{
	array_clans = ArrayCreate(ClanStructure);

	register_native("cs_get_player_info", "native_cs_get_player_info");
	register_native("cs_get_clan_info", "native_cs_get_clan_info");
	register_native("cs_get_clan_players_num", "native_cs_get_clan_players_num");
}

public native_cs_get_player_info(plugin)
{
	new player_name[MAX_NAME_LENGTH], player_authid[24];
	get_string(2, player_name, charsmax(player_name));
	get_string(3, player_authid, charsmax(player_authid));

	for(new item; item < ArraySize(array_clans); item++)
	{
		ArrayGetArray(array_clans, item, clans_data);

		if(player_name[0] && player_authid[0])
		{
			if(!strcmp(player_name, clans_data[PLAYER_NAME]) && !strcmp(player_authid, clans_data[PLAYER_AUTHID]))
			{
				set_array(1, clans_data, ClanStructure);
				return 1;
			}
		}
		else if(player_name[0] || player_authid[0])
		{
			if(!strcmp(player_name, clans_data[PLAYER_NAME]) || !strcmp(player_authid, clans_data[PLAYER_AUTHID]))
			{
				set_array(1, clans_data, ClanStructure);
				return 1;
			}
		}
	}

	return 0;
}

public native_cs_get_clan_info(plugin) // TODO: Not the best way, I know :)
{
	new clan_name[MAX_NAME_LENGTH];
	get_string(1, clan_name, charsmax(clan_name));

	new player_num;

	for(new item, param_player_num = get_param(2); item < ArraySize(array_clans); item++)
	{
		ArrayGetArray(array_clans, item, clans_data);

		if(!strcmp(clan_name, clans_data[CLAN_NAME]))
		{
			if(player_num == param_player_num)
			{
				set_array(3, clans_data, ClanStructure);
				break;
			}
			player_num++;
		}
	}

	if(!player_num)
		return -1;

	return 1;
}

public native_cs_get_clan_players_num(plugin) // TODO: Not the best way, I know :)
{
	new clan_name[MAX_NAME_LENGTH];
	get_string(1, clan_name, charsmax(clan_name));

	new players_num;

	for(new item; item < ArraySize(array_clans); item++)
	{
		ArrayGetArray(array_clans, item, clans_data);

		if(!strcmp(clan_name, clans_data[CLAN_NAME]))
			players_num++;
	}

	if(!players_num)
		return -1;

	return players_num;
}

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	new configs_dir[MAX_FMT_LENGTH], file_path[MAX_FMT_LENGTH];
	get_localinfo("amxx_configsdir", configs_dir, charsmax(configs_dir));
	formatex(file_path, charsmax(file_path), "%s/clans_system.ini", configs_dir);

	if(!file_exists(file_path))
		INI_AutoCreate(file_path);

	new INIParser:parser = INI_CreateParser();

	INI_SetReaders(parser, "Parse_KeyValue", "Parse_NewSection");
	INI_ParseFile(parser, file_path)
	INI_DestroyParser(parser);
}

public plugin_end()
	ArrayDestroy(array_clans);

public bool:Parse_NewSection(INIParser:handle, const section[])
{
	copy(clans_data[CLAN_NAME], charsmax(clans_data[CLAN_NAME]), section);
	return true;
}

public bool:Parse_KeyValue(INIParser:handle, const key[], const value[])
{
	new level[5];
	parse(key, clans_data[PLAYER_NAME], charsmax(clans_data[PLAYER_NAME]), clans_data[PLAYER_AUTHID], charsmax(clans_data[PLAYER_AUTHID]), level, charsmax(level));

	if(clans_data[PLAYER_NAME][0] == EOS || clans_data[PLAYER_AUTHID][0] == EOS)
		return true;

	if(level[0] == EOS)
		level = "1";

	clans_data[PLAYER_LEVEL] = str_to_num(level);
	ArrayPushArray(array_clans, clans_data);

	return true;
}

stock INI_AutoCreate(const file_path[])
{
	new file_pointer = fopen(file_path, "at");

	for(new i; i < sizeof(parse_text); i++)
		fputs(file_pointer, parse_text[i]);

	fclose(file_pointer);
}