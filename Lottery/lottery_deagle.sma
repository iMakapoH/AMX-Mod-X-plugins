#include <amxmodx>
#include <reapi>
#include <lottery>

new const PLUGIN_NAME[] = "Lottery: Deagle";
new const PLUGIN_VERSION[] = "1.0";
new const PLUGIN_AUTHOR[] = "MakapoH.";

const DROP_CHANCE = 10; // Шанс выпадения Deagle

new bool:wait_spawn[MAX_CLIENTS + 1];

public plugin_init()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	register_lottery_prize(DROP_CHANCE, "lottery_prize");

	RegisterHookChain(RG_CBasePlayer_Spawn, "CBasePlayer_Spawn_Post", 1);
}

public client_putinserver(id)
	wait_spawn[id] = false;

public CBasePlayer_Spawn_Post(const id)
{
	if(wait_spawn[id])
	{
		rg_give_item(id, "weapon_deagle", GT_REPLACE);
		rg_set_user_bpammo(id, WEAPON_DEAGLE, 35);

		wait_spawn[id] = false;
	}
}

public lottery_prize(id)
{
	client_print_color(id, print_team_default, "^4[Лотерея] Вы выиграли ^3Deagle^4!");

	if(is_user_alive(id))
	{
		rg_give_item(id, "weapon_deagle", GT_REPLACE);
		rg_set_user_bpammo(id, WEAPON_DEAGLE, 35);
	}
	else
	{
		wait_spawn[id] = true;
		client_print_color(id, print_team_default, "^4[Лотерея] Вы получите его как только будете живы :)");
	}
}