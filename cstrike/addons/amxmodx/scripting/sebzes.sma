#include <amxmodx>

#define PLUGIN "Bullet Damage"
#define AUTHOR "ConnorMcLeod"
#define VERSION "1.0"

#define MAX_PLAYERS	32

new const Float:g_flCoords[][] = 
{
	{0.30, 0.55}, 
	{0.35, 0.52}, 
	{0.40, 0.48}, 
	{0.45, 0.45}, 
	{0.50, 0.42}, 
	{0.55, 0.45}, 
	{0.60, 0.49}, 
	{0.65, 0.54}
}

new g_iPlayerPos[MAX_PLAYERS+1]

new g_iMaxPlayers
new g_pCvarEnabled

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	g_pCvarEnabled = register_cvar("bullet_damage", "1")

	register_event("Damage", "Event_Damage", "b", "2>0", "3=0")

	g_iMaxPlayers = get_maxplayers()
}

public Event_Damage( iVictim )
{
	if( get_pcvar_num(g_pCvarEnabled) && (read_data(4) || read_data(5) || read_data(6)) )
	{
		new id = get_user_attacker(iVictim)
		if( (1 <= id <= g_iMaxPlayers) && is_user_connected(id) )
		{
			new iPos = ++g_iPlayerPos[id]
			if( iPos == sizeof(g_flCoords) )
			{
				iPos = g_iPlayerPos[id] = 0
			}
			set_hudmessage(0, 40, 80, Float:g_flCoords[iPos][0], Float:g_flCoords[iPos][1], 0, 0.1, 2.5, 0.02, 0.02, -1)
			show_hudmessage(id, "|-%d HP|", read_data(2))
		}
	}
}
