#include <sourcemod>

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
    int victim_id = event.GetInt("userid");
    int attacker_id = event.GetInt("attacker");
 
    int victim = GetClientOfUserId(victim_id);
    int attacker = GetClientOfUserId(attacker_id);

    new String:weaponString[32] = event.GetString("weapon");
    
}
