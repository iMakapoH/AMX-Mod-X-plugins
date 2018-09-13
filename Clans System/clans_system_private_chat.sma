/**
*	Plugin: 	Clans System: Private Chat
*	Version: 	1.0-hotfix
*	Author: 	MakapoH.
*
*	Requirements: 	AMX Mod X 1.8.3 or higher
*					Main plugin "Clans System"
*/

#include <amxmodx>
#include <clans_system>

#define PLUGIN_NAME		"Clans System: Private Chat"
#define PLUGIN_VERSION	"1.0-hotfix"
#define PLUGIN_AUTHOR	"MakapoH."

/**
* Тэги для подстановки:
*	$clan$ - название клана
*	$player_name$ - имя игрока
*	$player_level$ - уровень игрока
*/
new MESSAGE[] = "^1[Чат клана] ^4$player_name$^1:";

new const CHAT_COMMANDS[][] = // Команды чата
{
	"/c",
	"/clan"
}

new data[ClanStructure];
new player_data[MAX_PLAYERS + 1][ClanStructure];

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	register_clcmd("say", "PrivateChat_Hook");
	register_clcmd("say_team", "PrivateChat_Hook");
}

public client_putinserver(id)
{
	new name[MAX_NAME_LENGTH], authid[24];
	get_user_name(id, name, charsmax(name));
	get_user_authid(id, authid, charsmax(authid));

	if(cs_get_player_info(data, .player_name = name, .player_authid = authid))
	{
		copy(player_data[id][CLAN_NAME], charsmax(player_data[][CLAN_NAME]), data[CLAN_NAME]);
		copy(player_data[id][PLAYER_NAME], charsmax(player_data[][PLAYER_NAME]), data[PLAYER_NAME]);
		copy(player_data[id][PLAYER_AUTHID], charsmax(player_data[][PLAYER_AUTHID]), data[PLAYER_AUTHID]);

		player_data[id][PLAYER_LEVEL] = data[PLAYER_LEVEL];
	}
}

public PrivateChat_Hook(id)
{
	if(!player_data[id][CLAN_NAME])
		return PLUGIN_CONTINUE;

	new message[198];
	read_args(message, charsmax(message));
	remove_quotes(message);

	if(!message[0])
		return PLUGIN_CONTINUE;

	for(new i, cmd_len; i < sizeof(CHAT_COMMANDS); i++)
	{
		cmd_len = strlen(CHAT_COMMANDS[i]);

		if(equali(message, CHAT_COMMANDS[i], cmd_len) && message[cmd_len] == ' ' && message[cmd_len + 1] != EOS)
		{
			if(containi(MESSAGE, "$clan$"))
				replace_string(MESSAGE, charsmax(MESSAGE), "$clan$", player_data[id][CLAN_NAME]);
			if(containi(MESSAGE, "$player_name$"))
				replace_string(MESSAGE, charsmax(MESSAGE), "$player_name$", player_data[id][PLAYER_NAME]);
			if(containi(MESSAGE, "$player_level$"))
				replace_string(MESSAGE, charsmax(MESSAGE), "$player_level$", fmt("%d", player_data[id][PLAYER_LEVEL]));

			replace_string(message, charsmax(message), CHAT_COMMANDS[i], MESSAGE);

			new players[MAX_PLAYERS], players_num;
			get_players(players, players_num, "h");

			for(new i, other_id; i < players_num; i++)
			{
				other_id = players[i];

				if(!strcmp(player_data[id][CLAN_NAME], player_data[other_id][CLAN_NAME]))
					client_print_color(other_id, print_team_default, message);
			}

			return PLUGIN_HANDLED;
		}
	}

	return PLUGIN_CONTINUE;
}