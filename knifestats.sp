#include <sourcemod>

StringMap victims_of_player;
bool print_knife_incidents;

public Plugin myinfo =
{
	name = "KnifeStats",
	author = "birgersp",
	description = "Display who knifed who",
	version = "1.0",
	url = "https://github.com/birgersp"
};

public void OnPluginStart()
{
	victims_of_player = new StringMap();
	print_knife_incidents = true;
	HookEvent("player_death", player_death_event);
	HookEvent("round_start", round_start_event);
	HookEvent("round_end", round_end_event);
	RegServerCmd("knifestats", knifestats_command);
}

public void player_death_event(Event event, const char[] name, bool do_not_broadcast)
{
	char weaponString[32];
	event.GetString("weapon", weaponString, sizeof(weaponString), "");
	if (StrEqual(weaponString, "knife", true) || StrEqual(weaponString, "knife_t", true))
	{
		int victim_id = event.GetInt("userid");
		int attacker_id = event.GetInt("attacker");
		int victim = GetClientOfUserId(victim_id);
		int attacker = GetClientOfUserId(attacker_id);
		char name_of_victim[64];
		GetClientName(victim, name_of_victim, sizeof(name_of_victim));
		char name_of_attacker[64];
		GetClientName(attacker, name_of_attacker, sizeof(name_of_attacker));
		PlayerKnifedBy(name_of_victim, name_of_attacker);
	}
}

public void round_start_event(Event event, const char[] name, bool do_not_broadcast)
{
	victims_of_player = new StringMap();
}

public void round_end_event(Event event, const char[] name, bool do_not_broadcast)
{
	print_attackers_and_victims();
}

public Action knifestats_command(int args)
{
	if (args < 1)
	{
		PrintToServer("test toggle_counter");
		return;
	}

	char argument[16];
	GetCmdArg(1, argument, sizeof(argument));

	if (StrEqual(argument, "test", true))
	{
		PlayerKnifedBy("Johnny", "Robert");
		print_attackers_and_victims();
	}
	else if (StrEqual(argument, "toggle_counter", true))
	{
		print_knife_incidents = !print_knife_incidents;
		PrintToServer("toggling print_knife_incidents");
	}
}

public PlayerKnifedBy(char[] name_of_victim, char[] name_of_attacker)
{
	StringMap victims;
	if (!victims_of_player.GetValue(name_of_attacker, victims))
	{
		victims = new StringMap();
	}

	int no_of_incidents;
	if (!victims.GetValue(name_of_victim, no_of_incidents))
	{
		no_of_incidents = 0;
	}

	no_of_incidents += 1;
	victims.SetValue(name_of_victim, no_of_incidents);
	victims_of_player.SetValue(name_of_attacker, victims);

	if (print_knife_incidents)
	{
		char plural_buffer[] = "s";
		if (no_of_incidents == 1)
			plural_buffer[0] = '\0';
		PrintToChatAll("%s has knifed %s %d time%s!", name_of_attacker, name_of_victim, no_of_incidents, plural_buffer);
	}
}

public void print_attackers_and_victims()
{
	int most_knife_kills = 0;
	char name_of_knifer[64];

	StringMapSnapshot victims_of_player_SS = victims_of_player.Snapshot();
	for (new i = 0; i < victims_of_player_SS.Length; i++)
	{
		int attacker_knife_kills = 0;

		char name_of_attacker[64];
		victims_of_player_SS.GetKey(i, name_of_attacker, sizeof(name_of_attacker));
		char string[256];
		Format(string, sizeof(string), "%s knife kills:", name_of_attacker);

		StringMap victims;
		victims_of_player.GetValue(name_of_attacker, victims);

		char name_of_victim[64];

		StringMapSnapshot victims_SS = victims.Snapshot();
		for (new i2 = 0; i2 < victims_SS.Length; i2++)
		{
			victims_SS.GetKey(i2, name_of_victim, sizeof(name_of_victim));
			int incidents;
			victims.GetValue(name_of_victim, incidents);
			if (i2 > 0)
				Format(string, sizeof(string), "%s,", string);
			Format(string, sizeof(string), "%s %s(%d)", string, name_of_victim, incidents);
			attacker_knife_kills += incidents;
		}
		PrintToChatAll(string);

		if (attacker_knife_kills > most_knife_kills)
		{
			strcopy(name_of_knifer, sizeof(name_of_knifer), name_of_attacker)
			most_knife_kills = attacker_knife_kills;
		}
	}

	if (most_knife_kills > 0)
	{
		PrintToChatAll("Knifer of the match: %s, with %d knife kills!", name_of_knifer, most_knife_kills);
	}
}
