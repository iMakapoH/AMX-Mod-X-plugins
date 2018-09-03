/**
*	Plugin: 	Lottery
*	Version: 	3.0.3 (dev)
*	Author: 	MakapoH.
*
*	Requirements: AMX Mod X 1.8.3 or higher
*/

#include <amxmodx>

#define PLUGIN_NAME 	"Lottery"
#define PLUGIN_VERSION 	"3.0.3 dev"
#define PLUGIN_AUTHOR 	"MakapoH."

enum Cvars_Value
{
	Participation_Cost,
	Only_Alive,
	Round_Access,
	Number_Attempts,
	Create_Menu
};

new settings[Cvars_Value];

new const cvar_name_lottery_commands[] = "lottery_commands";
new const cvar_name_lottery_participation_cost[] = "lottery_participation_cost";
new const cvar_name_lottery_only_alive[] = "lottery_only_alive";
new const cvar_name_lottery_round_access[] = "lottery_round_access";
new const cvar_name_lottery_number_attempts[] = "lottery_number_attempts";
new const cvar_name_lottery_create_menu[] = "lottery_create_menu";

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	new cvar_pointer;

	create_cvar(cvar_name_lottery_commands, "lottery;ly", FCVAR_NONE, "[EN] Client commands for call the lottery game.^nAutomatic adds say and say_team.^n^n[RU] Клиентские команды для вызова игры в лотерею.^nАвтоматический добавляет say и say_team.");

	cvar_pointer = create_cvar(cvar_name_lottery_participation_cost, "1500", FCVAR_NONE, "[EN] The cost of participation in the lottery.^n[RU] Стоимость участия в лотерее.", true, 1.0);
	bind_pcvar_num(cvar_pointer, settings[Participation_Cost]);

	cvar_pointer = create_cvar(cvar_name_lottery_only_alive, "0", FCVAR_NONE, "[EN] The lottery game is only available to live players.^n[RU] Игра в лотерею доступна только для живых игроков.", true, 0.0, true, 1.0);
	bind_pcvar_num(cvar_pointer, settings[Only_Alive]);

	cvar_pointer = create_cvar(cvar_name_lottery_round_access, "3", FCVAR_NONE, "[EN] The number of the round to access the lottery game.^n[RU] Номер раунда для доступа к игре в лотерею.", true, 0.0);
	bind_pcvar_num(cvar_pointer, settings[Round_Access]);

	cvar_pointer = create_cvar(cvar_name_lottery_number_attempts, "5", FCVAR_NONE, "[EN] The number of attempts to participate in the lottery.^n[RU] Количество попыток участия в лотерее.", true, 0.0);
	bind_pcvar_num(cvar_pointer, settings[Number_Attempts]);

	cvar_pointer = create_cvar(cvar_name_lottery_create_menu, "1", FCVAR_NONE, "[EN] The creation of the menu.^nIf not created, then participation will take place immediately.^n[RU] Создание меню.^nЕсли не создавать, то участие будет происходить сразу же.", true, 0.0, true, 1.0);
	bind_pcvar_num(cvar_pointer, settings[Create_Menu]);

	AutoExecConfig(true, "lottery");
}

public OnAutoConfigsBuffered()
{
	new buffer_ly_cmds[MAX_FMT_LENGTH];
	get_cvar_string(cvar_name_lottery_commands, buffer_ly_cmds, charsmax(buffer_ly_cmds));

	new left_cmd[MAX_FMT_LENGTH], right_cmd[MAX_FMT_LENGTH];

	for(new i; i < strlen(buffer_ly_cmds); i++) // best way?
	{
		if(buffer_ly_cmds[i] == ';')
		{
			strtok2(buffer_ly_cmds, left_cmd, charsmax(left_cmd), right_cmd, charsmax(right_cmd), ';');
			replace(buffer_ly_cmds, charsmax(buffer_ly_cmds), fmt("%s;", left_cmd), "");

			if(left_cmd[0] != EOS)
			{
				register_clcmd(left_cmd, "Lottery_Menu");
				register_clcmd(fmt("say /%s", left_cmd), "Lottery_Menu");
				register_clcmd(fmt("say_team /%s", left_cmd), "Lottery_Menu");
			}

			i -= (strlen(left_cmd) - 1);
		}
	}

	if(right_cmd[0] != EOS)
	{
		register_clcmd(right_cmd, "Lottery_Menu");
		register_clcmd(fmt("say /%s", right_cmd), "Lottery_Menu");
		register_clcmd(fmt("say_team /%s", right_cmd), "Lottery_Menu");
	}
}

public Lottery_Menu(id)
	return PLUGIN_HANDLED;