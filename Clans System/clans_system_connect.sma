/**
*	Plugin: 	Clans System: Connect
*	Version: 	1.0
*	Author: 	MakapoH.
*
*	Requirements: 	AMX Mod X 1.8.3 or higher
*					Main plugin "Clans System"
*/

#include <amxmodx>
#include <clans_system>

#define PLUGIN_NAME 	"Clans System: Connect"
#define PLUGIN_VERSION	"1.0"
#define PLUGIN_AUTHOR	"MakapoH."

/**
* Доступные тэги для подстановки:
*	$msg_name$ - ник зашедшего игрока
*	$msg_authid$ - SteamID зашедшего игрока
*	$msg_level$ - уровень зашедшего игрока
*	$msg_clan$ - клан зашедшего игрока
*/
new MESSAGE[] = "^4На сервер зашёл ^3$msg_name$ ^4[^3$msg_level$ ^4уровень] из клана ^3$msg_clan$^4.";

new data[ClanStructure];

public plugin_init()
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

public client_putinserver(id)
{
	if(is_user_bot(id) || is_user_hltv(id))
		return;

	new name[MAX_NAME_LENGTH], authid[24];
	get_user_name(id, name, charsmax(name));
	get_user_authid(id, authid, charsmax(authid));

	if(cs_get_player_info(data, .player_name = name, .player_authid = authid))
	{
		if(containi(MESSAGE, "$msg_name$") != -1)
			replace_string(MESSAGE, charsmax(MESSAGE), "$msg_name$", data[PLAYER_NAME]);
		if(containi(MESSAGE, "$msg_authid$") != -1)
			replace_string(MESSAGE, charsmax(MESSAGE), "$msg_authid$", data[PLAYER_AUTHID]);
		if(containi(MESSAGE, "$msg_level$") != -1)
			replace_string(MESSAGE, charsmax(MESSAGE), "$msg_level$", fmt("%d", data[PLAYER_LEVEL]));
		if(containi(MESSAGE, "$msg_clan$") != -1)
			replace_string(MESSAGE, charsmax(MESSAGE), "$msg_clan$", data[CLAN_NAME]);

		client_print_color(0, print_team_default, MESSAGE);
	}
}