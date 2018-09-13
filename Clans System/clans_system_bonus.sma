/**
*	Plugin: 	Clans System: Bonus
*	Version: 	1.0
*	Author: 	MakapoH.
*
*	Requirements: 	AMX Mod X 1.8.3 or higher
*					ReAPI
*					Main plugin "Clans System"
*/

#include <amxmodx>
#include <reapi>
#include <clans_system>

#define PLUGIN_NAME 	"Clans System: Bonus"
#define PLUGIN_VERSION 	"1.0"
#define PLUGIN_AUTHOR	"MakapoH."

const REQUIERD_LEVEL = 3; // Уровень игрока для получения бонуса

new data[ClanStructure];
new player_data[MAX_CLIENTS + 1][ClanStructure];

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	RegisterHookChain(RG_CBasePlayer_Spawn, "GamedllFunc_CBasePlayer_Spawn_Post", 1);
}

public GamedllFunc_CBasePlayer_Spawn_Post(const id)
{
	if(get_member(id, m_bJustConnected))
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
	else
	{
		if(player_data[id][PLAYER_LEVEL] >= REQUIERD_LEVEL)
		{
			rg_give_item(id, "weapon_deagle", GT_REPLACE);
			rg_set_user_bpammo(id, WEAPON_DEAGLE, 35);
		}
	}
}