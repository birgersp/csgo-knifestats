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
    knifingPlayerVictims = new StringMap();
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    event.GetString("weapon", weaponString, 31, "");
    if (StrEqual(weaponString, "knife", true) || StrEqual(weaponString, "knife_t", true))
    {
        int victim_id = event.GetInt("userid");
        int attacker_id = event.GetInt("attacker");
        int victim = GetClientOfUserId(victim_id);
        int attacker = GetClientOfUserId(attacker_id);
        PlayerKnifedBy(victim, attacker);
    }
}

public void PlayerKnifedBy(int victim, int attacker)
{
    decl String:nameOfVictim[64];
    GetClientName(victim, nameOfVictim, sizeof(nameOfVictim));

    decl String:nameOfAttacker[64];
    GetClientName(attacker, nameOfAttacker, sizeof(nameOfAttacker));

    new StringMap:victims;
    if (!knifingPlayerVictims.GetValue(nameOfAttacker, victims))
    {
        victims = new StringMap();
    }

    new numberOfIncidents;
    victims.GetValue(nameOfVictim, numberOfIncidents);

    numberOfIncidents += 1;
    victims.SetValue(nameOfVictim, numberOfIncidents);
    knifingPlayerVictims.SetValue(nameOfAttacker, victims);

    PrintToChatAll("%s has knifed %s %d times", nameOfAttacker, nameOfVictim, numberOfIncidents);
}
