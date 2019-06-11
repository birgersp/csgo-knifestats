#include <sourcemod>

new StringMap:knifingPlayerVictims;

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
    HookEvent("player_death", Event_PlayerDeath);
    HookEvent("round_start", Event_RoundStart);
}

public void Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
    decl String:weaponString[32];
    event.GetString("weapon", weaponString, sizeof(weaponString), "");
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

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    knifingPlayerVictims = new StringMap();
}
