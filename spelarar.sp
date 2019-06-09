#include <sourcemod>

new StringMap:knifingPlayerVictims;
new String:weaponString[32];

public Plugin myinfo =
{
    name = "My First Plugin",
	author = "Me",
	description = "My first plugin ever",
	version = "1.0",
	url = "http://www.sourcemod.net/"
};

public void OnPluginStart()
{
    HookEvent("player_death", Event_PlayerDeath);
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    event.GetString("weapon", weaponString, 31, "");
    PrintToChatAll(weaponString);
    if (StrEqual(weaponString, "knife", true))
    {
        int victim_id = event.GetInt("userid");
        int attacker_id = event.GetInt("attacker");
        int victim = GetClientOfUserId(victim_id);
        int attacker = GetClientOfUserId(attacker_id);
        PrintToChatAll("2");
        PlayerKnifedBy(victim, attacker);
    }
}

public void PlayerKnifedBy(int victim, int attacker)
{
    decl String:nameOfVictim[64];
    GetClientName(victim, nameOfVictim, sizeof(nameOfVictim));

    decl String:nameOfAttacker[64];
    GetClientName(victim, nameOfAttacker, sizeof(nameOfAttacker));

    // knifingPlayerVictims
    // "player1", StringMap

    new StringMap:victims;
    knifingPlayerVictims.GetValue(nameOfAttacker, victims)

    new numberOfIncidents;
    victims.GetValue(nameOfVictim, numberOfIncidents)

    numberOfIncidents += 1;

    PrintToChatAll("%d knifed %s", nameOfAttacker, nameOfVictim);

    PrintToChatAll("3");
}
