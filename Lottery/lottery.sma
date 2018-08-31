#include <amxmodx>
#include <reapi>

new const PLUGIN_NAME[] = "Lottery";
new const PLUGIN_VERSION[] = "3.0";
new const PLUGIN_AUTHOR[] = "MakapoH.";

new const settings_text[][] =
{
	"[Settings]^n",
	"# Основные настройки плагина.^n^n",

	"# Команды вызова плагина.^n",
	"# Символ разделения команд ;^n",
	"# Команда будет добавлена в консоль, чат и командный чат.^n",
	"CALLBACK_COMMANDS = ^"lottery;lo^"^n^n",

	"# Стоимость ($) участия.^n",
	"PARTICIPATION_COST = 1500^n^n",

	"# Меню доступно только живым игрокам.^n",
	"#	0 - выключено^n",
	"#	1 - включено^n",
	"ONLY_FOR_ALIVE = 0^n^n",

	"# Раунд с которого доступно меню.^n",
	"#	0 - без ограничений^n",
	"ROUND_ACCESS = 3^n^n",

	"# Сколько раз игрок может сыграть в раунд.^n",
	"#	0 - без ограничений^n",
	"AVAILABLE_ATTEMPTS = 5^n^n",

	"[Prizes]^n",
	"# Список призов.^n^n",

	"# ^"выигрыш в $^" ^"шанс получения^" ^"сообщение в чате^" ^"получатель сообщения^"^n",
	"#	Получатели сообщения: 0 - все игроки / 1 - выигравший игрок^n^n",

	"# Тэги для подстановки:^n",
	"#	$prize$ - ^"выигрыш в $^"^n",
	"#	$drop_chance$ - ^"шанс получения^"^n",
	"#	$name$ - ник выигравшего игрока^n^n",

	"# Цвета сообщений:^n",
	"#	!n - стандартный^n",
	"#	!g - зелёный^n",
	"#	!t - цвет команды игрока (синий/красный)^n^n",

	"100 	100 ^"!g[Лотерея] Вы выиграли !t$$prize$!g!^"									1^n",
	"300 	70 	^"!g[Лотерея] Вы выиграли !t$$prize$!g!^"									1^n",
	"500 	30 	^"!g[Лотерея] Вы выиграли !t$$prize$!g!^"									1^n",
	"1000 	10 	^"!g[Лотерея] Вы выиграли !t$$prize$!g!^"									1^n",
	"5000 	3 	^"!g[Лотерея] !t$name$ выиграл $$prize$! Шанс выпадения: $drop_chance$!^"	0^n",
	"16000 	1 	^"!g[Лотерея] !t$name$ выиграл $$prize$! Шанс выпадения: $drop_chance$!^"	0^n^n",

	"[Messages]^n",
	"# Тэги для подстановки:^n",
	"#	$round$ - значение ROUND_ACCESS^n",
	"#	$cost$ - значение PARTICIPATION_COST^n",
	"#	$attempts$ - значение AVAILABLE_ATTEMPTS^n^n",

	"# Цвета сообщений:^n",
	"#	!n - стандартный^n",
	"#	!g - зелёный^n",
	"#	!t - цвет команды игрока (синий/красный)^n^n",

	"MSG_NOT_ENOUGH_MONEY = ^"!g[Лотерея] Для участия необходимо !t$$cost$!g.^"^n",
	"MSG_ONLY_FOR_ALIVE = ^"!g[Лотерея] Доступно только живым игрокам.^"^n",
	"MSG_ROUND_ERROR = ^"!g[Лотерея] Доступно с !t$round$ !gраунда.^"^n",
	"MSG_ATTEMPTS_ENDED = ^"!g[Лотерея] Вы потратили все свои попытки... Подождите !tследующего !gраунда.^"^n^n",

	"[Menu]^n",
	"# Настройки меню.^n^n",

	"# Создание меню.^n",
	"# Если меню не создано, то участие будет происходить сразу^n",
	"# после вызова команды (CALLBACK_COMMANDS).^n",
	"#	0 - не создавать^n",
	"#	1 - создавать^n",
	"CREATE_MENU = 1^n^n",

	"# Цвета:^n",
	"#	\d - серый^n",
	"#	\y - жёлтый^n",
	"#	\r - красный^n",
	"#	\w - белый^n",
	"# Перенос строки - \n^n^n",

	"# Тэги для подстановки:^n",
	"#	$cost$ - значение PARTICIPATION_COST^n",
	"#	$attempts$ - значение AVAILABLE_ATTEMPTS^n^n",

	"MENU_FORMAT_TITLE = ^"\yЛотерея\n\rСтоимость участия: \d$$cost$^"^n",
	"MENU_FORMAT_TRY_LUCK = ^"Испытать удачу^"^n",
	"MENU_FORMAT_EXIT = ^"Выход^"^n^n",

	"# Цвет цифр.^n",
	"MENU_FORMAT_NUMBER_COLOR = ^"\r^""
};

enum List_Settings
{
	CALLBACK_COMMANDS[192],
	PARTICIPATION_COST,
	ROUND_ACCESS,
	AVAILABLE_ATTEMPTS,
	bool:ONLY_FOR_ALIVE,
	bool:CREATE_MENU
};

enum _:List_PrizeData
{
	GET_PRIZE,
	DROP_CHANCE,
	MESSAGE[192],
	bool:MESSAGE_STATUS,
	FORWARD_ID
};

enum List_Messages
{
	MSG_NOT_ENOUGH_MONEY[192],
	MSG_ONLY_FOR_ALIVE[192],
	MSG_ROUND_ERROR[192],
	MSG_ATTEMPTS_ENDED[192]
};

enum List_Menu
{
	MENU_FORMAT_TITLE[512],
	MENU_FORMAT_TRY_LUCK[128],
	MENU_FORMAT_EXIT[64],
	MENU_FORMAT_NUMBER_COLOR[3]
};

new HookChain:hc_restart_round;

new prize[List_PrizeData];
new settings[List_Settings];
new messages[List_Messages];
new menu[List_Menu];

new Array:array_prizes;

new total_drop_chance_sum;
new menu_id;

new current_round;

new player_attempts[MAX_CLIENTS + 1];

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

	hc_restart_round = RegisterHookChain(RG_CSGameRules_RestartRound, "CSGameRules_RestartRound_Pre");

	ReadSettingsFile();

	if(settings[CREATE_MENU])
		CreateMenu();
	if(!settings[ROUND_ACCESS] && !settings[AVAILABLE_ATTEMPTS])
		DisableHookChain(hc_restart_round);
}

public plugin_natives()
	register_native("register_lottery_prize", "native_register_lottery_prize");

public native_register_lottery_prize(plugin)
{
	new callback[64];
	get_string(2, callback, charsmax(callback));

	total_drop_chance_sum += (prize[DROP_CHANCE] = get_param(1));
	prize[FORWARD_ID] = CreateOneForward(plugin, callback, FP_CELL);

	ArrayPushArray(array_prizes, prize);

	return prize[FORWARD_ID];
}

public plugin_end()
	ArrayDestroy(array_prizes);

public client_putinserver(id)
	player_attempts[id] = settings[AVAILABLE_ATTEMPTS];

public CSGameRules_RestartRound_Pre()
{
	if(get_member_game(m_bCompleteReset))
		current_round = 0;
	current_round++;

	arrayset(player_attempts, settings[AVAILABLE_ATTEMPTS], sizeof(player_attempts));
}

public ClientCommand_Lottery(id)
{
	if(settings[ROUND_ACCESS] && current_round < settings[ROUND_ACCESS])
	{
		if(messages[MSG_ROUND_ERROR])
			client_print_color(id, print_team_default, messages[MSG_ROUND_ERROR]);

		return PLUGIN_HANDLED;
	}

	if(settings[AVAILABLE_ATTEMPTS] && player_attempts[id] <= 0)
	{
		if(messages[MSG_ATTEMPTS_ENDED])
			client_print_color(id, print_team_default, messages[MSG_ATTEMPTS_ENDED]);

		return PLUGIN_HANDLED;
	}

	if(settings[ONLY_FOR_ALIVE] && !is_user_alive(id))
	{
		if(messages[MSG_ONLY_FOR_ALIVE])
			client_print_color(id, print_team_default, messages[MSG_ONLY_FOR_ALIVE]);

		return PLUGIN_HANDLED;
	}

	if(settings[CREATE_MENU])
		menu_display(id, menu_id);
	else
	{
		if(get_member(id, m_iAccount) < settings[PARTICIPATION_COST])
		{
			if(messages[MSG_NOT_ENOUGH_MONEY])
				client_print_color(id, print_team_default, messages[MSG_NOT_ENOUGH_MONEY]);

			return PLUGIN_HANDLED;
		}

		DefinitionPrize(id);
	}

	return PLUGIN_HANDLED;
}

public Menu_Handler(id, menu, item)
{
	if(item == MENU_EXIT)
		return PLUGIN_HANDLED;

	if(get_member(id, m_iAccount) < settings[PARTICIPATION_COST])
	{
		if(messages[MSG_NOT_ENOUGH_MONEY])
			client_print_color(id, print_team_default, messages[MSG_NOT_ENOUGH_MONEY]);

		return PLUGIN_HANDLED;
	}

	DefinitionPrize(id);
	ClientCommand_Lottery(id);

	return PLUGIN_HANDLED;
}

DefinitionPrize(id)
{
	for(new i, current_sum, random = random_num(0, total_drop_chance_sum), player_name[MAX_NAME_LENGTH]; i < ArraySize(array_prizes); i++)
	{
		ArrayGetArray(array_prizes, i, prize);

		if(current_sum <= random && random < current_sum + prize[DROP_CHANCE])
		{
			player_attempts[id]--;

			rg_add_account(id, -settings[PARTICIPATION_COST]);

			if(prize[FORWARD_ID])
			{
				new ret;
				ExecuteForward(prize[FORWARD_ID], ret, id);

				break;
			}

			rg_add_account(id, prize[GET_PRIZE]);

			if(prize[MESSAGE])
			{
				if(containi(prize[MESSAGE], "$name$") != -1)
				{
					get_user_name(id, player_name, charsmax(player_name));
					replace_string(prize[MESSAGE], charsmax(prize[MESSAGE]), "$name$", player_name);
				}

				client_print_color(prize[MESSAGE_STATUS] ? id : 0, print_team_default, prize[MESSAGE]);
			}

			break;
		}

		current_sum += prize[DROP_CHANCE];
	}
}

ReadSettingsFile()
{
	new configs_dir[256], file_path[256];
	get_localinfo("amxx_configsdir", configs_dir, charsmax(configs_dir));
	formatex(file_path, charsmax(file_path), "%s/lottery.ini", configs_dir);

	new file_pointer = fopen(file_path, "rt");
	if(!file_pointer)
	{
		fclose(file_pointer);

		file_pointer = fopen(file_path, "at");

		for(new i; i < sizeof(settings_text); i++)
			fputs(file_pointer, settings_text[i]);

		fclose(file_pointer);

		file_pointer = fopen(file_path, "rt");
	}

	array_prizes = ArrayCreate(List_PrizeData);

	new buffer[512], key[32], value[192];
	new parse_get_prize[7], parse_prize_drop_chance[5], parse_message_status[2];

	enum
	{
		NONE,
		SETTINGS,
		PRIZES,
		MESSAGES,
		MENU
	};
	new section;

	while(!feof(file_pointer))
	{
		fgets(file_pointer, buffer, charsmax(buffer));
		trim(buffer);

		switch(buffer[0])
		{
			case EOS, ';', '/', '#': continue;
			case '[':
			{
				if(!strcmp(buffer, "[Settings]"))
					section = SETTINGS;
				else if(!strcmp(buffer, "[Prizes]"))
					section = PRIZES;
				else if(!strcmp(buffer, "[Messages]"))
					section = MESSAGES;
				else if(!strcmp(buffer, "[Menu]"))
					section = MENU;
				else section = NONE;

				continue;
			}
			default:
			{
				strtok2(buffer, key, charsmax(key), value, charsmax(value), '=');
				trim(key); trim(value);
				remove_quotes(value);

				switch(section)
				{
					case SETTINGS:
					{
						if(!strcmp(key, "CALLBACK_COMMANDS"))
						{
							copy(settings[CALLBACK_COMMANDS], charsmax(settings[CALLBACK_COMMANDS]), value);

							while(value[0] && strtok2(value, key, charsmax(key), value, charsmax(value), ';'))
							{
								trim(key); trim(value);

								register_clcmd(key, "ClientCommand_Lottery");
								register_clcmd(fmt("say /%s", key), "ClientCommand_Lottery");
								register_clcmd(fmt("say_team /%s", key), "ClientCommand_Lottery");
							}
						}
						else if(!strcmp(key, "PARTICIPATION_COST"))
							settings[PARTICIPATION_COST] = str_to_num(value);
						else if(!strcmp(key, "ONLY_FOR_ALIVE"))
							settings[ONLY_FOR_ALIVE] = bool:clamp(str_to_num(value), false, true);
						else if(!strcmp(key, "AVAILABLE_ATTEMPTS"))
							settings[AVAILABLE_ATTEMPTS] = str_to_num(value);
						else if(!strcmp(key, "ROUND_ACCESS"))
							settings[ROUND_ACCESS] = str_to_num(value);
					}
					case PRIZES:
					{
						parse(buffer, parse_get_prize, charsmax(parse_get_prize), parse_prize_drop_chance, charsmax(parse_prize_drop_chance), prize[MESSAGE], charsmax(prize[MESSAGE]), parse_message_status, charsmax(parse_message_status));

						prize[GET_PRIZE] = str_to_num(parse_get_prize);
						prize[MESSAGE_STATUS] = bool:clamp(str_to_num(parse_message_status), false, true);

						total_drop_chance_sum += (prize[DROP_CHANCE] = str_to_num(parse_prize_drop_chance));

						if(containi(prize[MESSAGE], "$prize$") != -1)
							replace_string(prize[MESSAGE], charsmax(prize[MESSAGE]), "$prize$", fmt("%d", prize[GET_PRIZE]));
						if(containi(prize[MESSAGE], "$drop_chance$") != -1)
							replace_string(prize[MESSAGE], charsmax(prize[MESSAGE]), "$drop_chance$", fmt("%d", prize[DROP_CHANCE]));

						if(containi(prize[MESSAGE], "!t") != -1)
							replace_string(prize[MESSAGE], charsmax(prize[MESSAGE]), "!t", "^3");
						if(containi(prize[MESSAGE], "!g") != -1)
							replace_string(prize[MESSAGE], charsmax(prize[MESSAGE]), "!g", "^4");
						if(containi(prize[MESSAGE], "!n") != -1)
							replace_string(prize[MESSAGE], charsmax(prize[MESSAGE]), "!n", "^1");

						ArrayPushArray(array_prizes, prize);
						prize[MESSAGE] = EOS;
					}
					case MESSAGES:
					{
						if(containi(value, "$cost$") != -1)
							replace_string(value, charsmax(value), "$cost$", fmt("%d", settings[PARTICIPATION_COST]));
						if(containi(value, "$round$") != -1)
							replace_string(value, charsmax(value), "$round$", fmt("%d", settings[ROUND_ACCESS]));
						if(containi(value, "$attempts$") != -1)
							replace_string(value, charsmax(value), "$attempts$", fmt("%d", settings[AVAILABLE_ATTEMPTS]));

						if(containi(value, "!t") != -1)
							replace_string(value, charsmax(value), "!t", "^3");
						if(containi(value, "!g") != -1)
							replace_string(value, charsmax(value), "!g", "^4");
						if(containi(value, "!n") != -1)
							replace_string(value, charsmax(value), "!n", "^1");

						if(!strcmp(key, "MSG_NOT_ENOUGH_MONEY"))
							copy(messages[MSG_NOT_ENOUGH_MONEY], charsmax(messages[MSG_NOT_ENOUGH_MONEY]), value);
						else if(!strcmp(key, "MSG_ONLY_FOR_ALIVE"))
							copy(messages[MSG_ONLY_FOR_ALIVE], charsmax(messages[MSG_ONLY_FOR_ALIVE]), value);
						else if(!strcmp(key, "MSG_ROUND_ERROR"))
							copy(messages[MSG_ROUND_ERROR], charsmax(messages[MSG_ROUND_ERROR]), value);
						else if(!strcmp(key, "MSG_ATTEMPTS_ENDED"))
							copy(messages[MSG_ATTEMPTS_ENDED], charsmax(messages[MSG_ATTEMPTS_ENDED]), value);
					}
					case MENU:
					{
						if(!strcmp(key, "CREATE_MENU"))
						{
							settings[CREATE_MENU] = bool:clamp(str_to_num(value), false, true);
							continue;
						}

						if(containi(value, "\n") != -1)
							replace_string(value, charsmax(value), "\n", "^n");
						if(containi(value, "$cost$") != -1)
							replace_string(value, charsmax(value), "$cost$", fmt("%d", settings[PARTICIPATION_COST]));
						if(containi(value, "$attempts$") != -1)
							replace_string(value, charsmax(value), "$attempts$", fmt("%d", settings[AVAILABLE_ATTEMPTS]));

						if(!strcmp(key, "MENU_FORMAT_TITLE"))
							copy(menu[MENU_FORMAT_TITLE], charsmax(menu[MENU_FORMAT_TITLE]), value);
						else if(!strcmp(key, "MENU_FORMAT_TRY_LUCK"))
							copy(menu[MENU_FORMAT_TRY_LUCK], charsmax(menu[MENU_FORMAT_TRY_LUCK]), value);
						else if(!strcmp(key, "MENU_FORMAT_EXIT"))
							copy(menu[MENU_FORMAT_EXIT], charsmax(menu[MENU_FORMAT_EXIT]), value);
						else if(!strcmp(key, "MENU_FORMAT_NUMBER_COLOR"))
							copy(menu[MENU_FORMAT_NUMBER_COLOR], charsmax(menu[MENU_FORMAT_NUMBER_COLOR]), value);
					}
				}
			}
		}
	}

	fclose(file_pointer);
}

stock CreateMenu()
{
	menu_id = menu_create(menu[MENU_FORMAT_TITLE], "Menu_Handler");

	menu_additem(menu_id, menu[MENU_FORMAT_TRY_LUCK]);
	menu_setprop(menu_id, MPROP_EXITNAME, menu[MENU_FORMAT_EXIT]);
	menu_setprop(menu_id, MPROP_NUMBER_COLOR, menu[MENU_FORMAT_NUMBER_COLOR]);
}