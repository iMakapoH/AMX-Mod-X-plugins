/**
*	Plugin: 	Lottery
*	Version: 	3.0.4 (dev)
*	Author: 	MakapoH.
*
*	Requirements: AMX Mod X 1.8.3 or higher
*/

#include <amxmodx>

#define PLUGIN_NAME 	"Lottery"
#define PLUGIN_VERSION 	"3.0.4 dev"
#define PLUGIN_AUTHOR 	"MakapoH."

enum Lang_Sections
{
	Lang_Key[MAX_FMT_LENGTH],
	Lang_Text[MAX_FMT_LENGTH]
};

stock const lang_text[][Lang_Sections] =
{
	{ "en", "" },
	{ "MSG_TEST", "Simple text" },

	{ "ru", "" },
	{ "MSG_TEST2", "Simple text 2" }
};

new const lang_name[] = "lottery.txt";

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

new menu_index;

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

	if(!lang_exists(lang_name))
		Create_Lang_Function();

	if(settings[Create_Menu])
		Create_Menu_Function();
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
{
	if(settings[Only_Alive] && !is_user_alive(id))
	{
		client_print_color(id, print_team_default, "You dead...");
		return PLUGIN_HANDLED;
	}

	menu_display(id, menu_index);
	return PLUGIN_HANDLED;
}

public Menu_Handler(id, menu, item)
{
	if(item == MENU_EXIT)
		return PLUGIN_HANDLED;

	client_print(id, print_chat, "Hmm...");
	return PLUGIN_HANDLED;
}

stock Create_Menu_Function()
{
	menu_index = menu_create("Lottery", "Menu_Handler");
	menu_additem(menu_index, "Принять участие");
	menu_setprop(menu_index, MPROP_EXITNAME, "Выход");
}

stock Create_Lang_Function()
{
	new data_dir[MAX_FMT_LENGTH];
	get_localinfo("amxx_datadir", data_dir, charsmax(data_dir));

	new lang_file_path[MAX_FMT_LENGTH]
	formatex(lang_file_path, charsmax(lang_file_path), "%s/lang/%s", data_dir, lang_name);

	new file_pointer = fopen(lang_file_path, "wt");

	for(new i, cur_key[3]; i < sizeof(lang_text); i++)
	{
		if(lang_text[i][Lang_Text] == EOS)
		{
			fputs(file_pointer, fmt("[%s]^n", lang_text[i][Lang_Key]));

			copy(cur_key, charsmax(cur_key), lang_text[i][Lang_Key]);
			continue;
		}
		AddTranslation(cur_key, CreateLangKey(lang_text[i][Lang_Key]), lang_text[i][Lang_Text]);

		fputs(file_pointer, fmt("%s = %s^n", lang_text[i][Lang_Key], lang_text[i][Lang_Text]));
	}

	fclose(file_pointer);
}