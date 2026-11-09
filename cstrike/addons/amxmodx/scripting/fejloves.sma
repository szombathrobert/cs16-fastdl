#include <amxmodx>

new toggle_sound, toggle_fade, toggle_blood, toggle_msg

public plugin_init() 
{
	register_plugin("cfg_hse", "1.0", "alphaa")
	register_cvar("CFG HeadShot Effect", "1.0/alphaa", FCVAR_SERVER)
	register_event("DeathMsg", "head", "a")

	toggle_sound = register_cvar( "cfg_hs_sound", "1" );
	toggle_fade = register_cvar( "cfg_hs_fade", "1" );
	toggle_blood = register_cvar( "cfg_hs_blood", "1" );
	toggle_msg = register_cvar( "cfg_hs_msg", "1");
}

public head() 
{
	new iOrigin[3]
	new victim = read_data(2) 

	if(read_data(3))
	{
		if (get_pcvar_num(toggle_sound) != 0)
			client_cmd(victim,"spk fvox/flatline.wav")
 
		if (get_pcvar_num(toggle_fade) != 0)
		{
			message_begin(MSG_ONE_UNRELIABLE,get_user_msgid("ScreenFade"),{0,0,0},victim)
			write_short( 10<<12 )
			write_short( 10<<16 )
			write_short( 1<<1 )
			write_byte( 255 )
			write_byte( 0 )
			write_byte( 0 )
			write_byte( 255 )
			message_end()
		}

		if (get_pcvar_num(toggle_blood) != 0)
		{
			get_user_origin(victim,iOrigin)
			fx_headshot(iOrigin)
		}

		if (get_pcvar_num(toggle_msg) != 0)
			client_print(0, print_center, ">>Brutalis Gyilkossag!<<")
	}
}

fx_headshot(origin[3])
{
	message_begin(MSG_PVS, SVC_TEMPENTITY, origin)
	write_byte(TE_BLOODSTREAM)
	write_coord(origin[0])
	write_coord(origin[1])
	write_coord(origin[2]+30)
	write_coord(random_num(-20,20))
	write_coord(random_num(-20,20))
	write_coord(random_num(50,300))
	write_byte(70)
	write_byte(random_num(100,200))
	message_end()
}
