#include <amxmodx>
#include <clans_system>

new data[ClanStructure];

public plugin_init()
	register_concmd("test", "Test");

public Test()
{
	// Пример поиска информации о клане
	for(new i; i < cs_get_clan_players_num("Бывалые"); i++)
	{
		cs_get_clan_info("Бывалые", i, data);

		server_print("Бывалые -> Name: %s -> SteamID: %s -> Level: %d", data[PLAYER_NAME], data[PLAYER_AUTHID], data[PLAYER_LEVEL]);
	}

	for(new i; i < cs_get_clan_players_num("Самые слабые"); i++)
	{
		cs_get_clan_info("Самые слабые", i, data);

		server_print("Самые слабые -> Name: %s -> SteamID: %s -> Level: %d", data[PLAYER_NAME], data[PLAYER_AUTHID], data[PLAYER_LEVEL]);
	}

	// Пример поиска инофрмации о игроке по нику
	cs_get_player_info(data, .player_name = "PlayerName2");
	server_print("Find player -> Name: %s -> SteamID: %s -> Level: %d", data[PLAYER_NAME], data[PLAYER_AUTHID], data[PLAYER_LEVEL]);

	// Пример поиска инофрмации о игроке по SteamID
	cs_get_player_info(data, .player_authid = "STEAM_0:0:123456");
	server_print("Find player -> Name: %s -> SteamID: %s -> Level: %d", data[PLAYER_NAME], data[PLAYER_AUTHID], data[PLAYER_LEVEL]);

	// Пример поиска инофрмации о игроке по нику и SteamID
	new result = cs_get_player_info(data, .player_name = "PlayerName2", .player_authid = "STEAM_0:0:123456");

	if(result)
		server_print("Find player -> Name: %s -> SteamID: %s -> Level: %d", data[PLAYER_NAME], data[PLAYER_AUTHID], data[PLAYER_LEVEL]);
}