enum _:ClanStructure
{
	CLAN_NAME[MAX_NAME_LENGTH], // Название клана
	PLAYER_NAME[MAX_NAME_LENGTH], // Ник игрока
	PLAYER_AUTHID[24], // STEAM_ID игрока
	PLAYER_LEVEL // Уровень игрока
};

/**
* Получение информации о игроке.
*
* @param inc_data			массив для хранения даных
* @param player_name		ник игрока
# @param player_authid		стим айди игрока
*
* @return					1 если игрок найден, 0 если игрок не найден
*/

native cs_get_player_info(inc_data[ClanStructure], player_name[MAX_NAME_LENGTH] = "", player_authid[24] = "");

/**
* Получение информации о клане.
*
* @param clan_name			название клана
* @param player_num			номер игрока по списку
* @param inc_data			массив для хранения даных
*
* @return					1 если информация найдена, -1 если никто не найден или клана не существует
*/
native cs_get_clan_info(clan_name[MAX_NAME_LENGTH], player_num, inc_data[ClanStructure]);

/**
* Получение количества участников в клане.
*
* @param clan_name			название клана
*
* @return					количество участников, -1 если ни одного или клана не существует
*/
native cs_get_clan_players_num(clan_name[MAX_NAME_LENGTH]);