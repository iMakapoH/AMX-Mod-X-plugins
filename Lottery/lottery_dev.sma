/**
*	Plugin: 	Lottery
*	Version: 	3.0.2 (dev)
*	Author: 	MakapoH.
*
*	Requirements: AMX Mod X 1.8.3 or higher
*/

#include <amxmodx>

#define PLUGIN_NAME 	"Lottery"
#define PLUGIN_VERSION 	"3.0.2 dev"
#define PLUGIN_AUTHOR 	"MakapoH."

new const cvar_name_lottery_commands[] = "lottery_commands";
new const cvar_name_lottery_participation_cost[] = "lottery_participation_cost";
new const cvar_name_lottery_only_alive[] = "lottery_only_alive";

new participation_cost;
new only_alive;

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	new cvar_pointer;

	create_cvar(cvar_name_lottery_commands, "lottery;ly", FCVAR_NONE, "[EN] Client commands for call the lottery game.^nAutomatic adds say and say_team.^n^n[RU] Клиентские команды для вызова игры в лотерею.^nАвтоматический добавляет say и say_team.");

	cvar_pointer = create_cvar(cvar_name_lottery_participation_cost, "1500", FCVAR_NONE, "[EN] The cost of participation in the lottery.^n[RU] Стоимость участия в лотерее.", true, 1.0);
	bind_pcvar_num(cvar_pointer, participation_cost);

	cvar_pointer = create_cvar(cvar_name_lottery_only_alive, "0", FCVAR_NONE, "[EN] The lottery game is only available to live players.^n[RU] Игра в лотерею доступна только для живых игроков.", true, 0.0, true, 1.0);
	bind_pcvar_num(cvar_pointer, only_alive);

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