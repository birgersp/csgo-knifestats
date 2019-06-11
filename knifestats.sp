#include <sourcemod>

StringMap knifingPlayerVictims;
bool printKnifeIncidents;

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
	knifingPlayerVictims = new StringMap();
	printKnifeIncidents = true;
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("round_start", Event_RoundStart);
	HookEvent("round_end", Event_RoundEnd);
	RegServerCmd("knifestats", Cmd_Knifestats);
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	char weaponString[32];
	event.GetString("weapon", weaponString, sizeof(weaponString), "");
	if (StrEqual(weaponString, "knife", true) || StrEqual(weaponString, "knife_t", true))
	{
		int victim_id = event.GetInt("userid");
		int attacker_id = event.GetInt("attacker");
		int victim = GetClientOfUserId(victim_id);
		int attacker = GetClientOfUserId(attacker_id);
		char nameOfVictim[64];
		GetClientName(victim, nameOfVictim, sizeof(nameOfVictim));
		char nameOfAttacker[64];
		GetClientName(attacker, nameOfAttacker, sizeof(nameOfAttacker));
		PlayerKnifedBy(nameOfVictim, nameOfAttacker);
	}
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	knifingPlayerVictims = new StringMap();
}

public void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	PrintAttackersAndVictims();
}

public Action Cmd_Knifestats(int args)
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
		PrintAttackersAndVictims();
	}
	else if (StrEqual(argument, "toggle_counter", true))
	{
		printKnifeIncidents = !printKnifeIncidents;
		PrintToServer("toggling printKnifeIncidents");
	}
}

public PlayerKnifedBy(char[] nameOfVictim, char[] nameOfAttacker)
{
	StringMap victims;
	if (!knifingPlayerVictims.GetValue(nameOfAttacker, victims))
	{
		victims = new StringMap();
	}

	int numberOfIncidents;
	if (!victims.GetValue(nameOfVictim, numberOfIncidents))
	{
		numberOfIncidents = 0;
	}

	numberOfIncidents += 1;
	victims.SetValue(nameOfVictim, numberOfIncidents);
	knifingPlayerVictims.SetValue(nameOfAttacker, victims);

	if (printKnifeIncidents)
	{
		char pluralBuffer[] = "s";
		if (numberOfIncidents == 1)
			pluralBuffer[0] = '\0';
		PrintToChatAll("%s has knifed %s %d time%s!", nameOfAttacker, nameOfVictim, numberOfIncidents, pluralBuffer);
	}
}

public void PrintAttackersAndVictims()
{
	StringMapSnapshot playerVictimsSS = knifingPlayerVictims.Snapshot();
	char nameOfAttacker[64];
	for (new i = 0; i < playerVictimsSS.Length; i++)
	{
		playerVictimsSS.GetKey(i, nameOfAttacker, sizeof(nameOfAttacker));
		PrintVictimsOf(nameOfAttacker);
	}
}

public void PrintVictimsOf(const char[] nameOfAttacker)
{
	char string[256];
	Format(string, sizeof(string), "%s knife kills:", nameOfAttacker);

	StringMap victims;
	knifingPlayerVictims.GetValue(nameOfAttacker, victims);

	char nameOfVictim[64];

	StringMapSnapshot victimsSS = victims.Snapshot();
	for (new i = 0; i < victimsSS.Length; i++)
	{
		victimsSS.GetKey(i, nameOfVictim, sizeof(nameOfVictim));
		int incidents;
		victims.GetValue(nameOfVictim, incidents);
		if (i > 0)
			Format(string, sizeof(string), "%s,", string);
		Format(string, sizeof(string), "%s %s(%d)", string, nameOfVictim, incidents);
	}
	PrintToChatAll(string);
}
