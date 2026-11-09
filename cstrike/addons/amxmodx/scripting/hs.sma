#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <cstrike>

#define PLUGIN "Super Headshot"
#define VERSION "1.0"
#define AUTHOR "Phantomas"

#define head_parts_velocity_min 8
#define head_parts_velocity_max 14
#define head_parts_min 20
#define head_parts_max 25

new mdl_head_parts
new spr_blood

public plugin_precache()
{
	precache_model("models/player/arctic_shs/arctic_shs.mdl")
	precache_model("models/player/gign_shs/gign_shs.mdl")
	precache_model("models/player/gsg9_shs/gsg9_shs.mdl")
	precache_model("models/player/guerilla_shs/guerilla_shs.mdl")
	precache_model("models/player/leet_shs/leet_shs.mdl")
	precache_model("models/player/sas_shs/sas_shs.mdl")
	precache_model("models/player/terror_shs/terror_shs.mdl")
	precache_model("models/player/urban_shs/urban_shs.mdl")
	precache_model("models/player/vip_shs/vip_shs.mdl")
	mdl_head_parts = precache_model("models/headgibs.mdl")
	spr_blood = precache_model("sprites/blood.spr")
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_SetClientKeyValue, "SetClientKeyValue")
}

public set_model(const id, const szSetModel[])
{
	new szModel[16]
	get_user_info(id, "model", szModel, charsmax(szModel))
	if(!equal(szModel, szSetModel))
	{
		set_user_info(id, "model", szSetModel)
	}
	return FMRES_SUPERCEDE
}

public SetClientKeyValue(const id, const szInfoBuffer[], const szKey[], const szValue[])
{
	if(equal(szKey, "model"))
	{
		if(equal(szValue, "arctic"))
		{
			return set_model(id, "arctic_shs")
		} else if(equal(szValue, "gign")) {
			return set_model(id, "gign_shs")
		} else if(equal(szValue, "gsg9")) {
			return set_model(id, "gsg9_shs")
		} else if(equal(szValue, "guerilla")) {
			return set_model(id, "guerilla_shs")
		} else if(equal(szValue, "leet")) {
			return set_model(id, "leet_shs")
		} else if(equal(szValue, "sas")) {
			return set_model(id, "sas_shs")
		} else if(equal(szValue, "terror")) {
			return set_model(id, "terror_shs")
		} else if(equal(szValue, "urban")) {
			return set_model(id, "urban_shs")
		} else if(equal(szValue, "vip")) {
			return set_model(id, "vip_shs")
		}
	}
	return FMRES_IGNORED
}

public spawn_blood(const id)
{
	if(is_user_alive(id))
	{
		return PLUGIN_HANDLED
	}
	
	new const Float:origin[3]
	new const Float:angles[3]
	engfunc(EngFunc_GetBonePosition, id, 8, origin, angles)
	
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BLOODSPRITE)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_short(spr_blood)
	write_short(spr_blood)
	write_byte(248)
	write_byte(15)
	message_end()
	
	return PLUGIN_CONTINUE
}

public spawn_head_parts(const id)
{
	new const Float:origin[3]
	new const Float:angles[3]
	engfunc(EngFunc_GetBonePosition, id, 8, origin, angles)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_BREAKMODEL)
	engfunc(EngFunc_WriteCoord, origin[0])
	engfunc(EngFunc_WriteCoord, origin[1])
	engfunc(EngFunc_WriteCoord, origin[2])
	write_coord(0)
	write_coord(0)
	write_coord(0)
	write_coord(0)
	write_coord(0)
	write_coord(50)
	write_byte(random_num(head_parts_velocity_min, head_parts_velocity_max))
	write_short(mdl_head_parts)
	write_byte(random_num(head_parts_min, head_parts_max))
	write_byte(50)
	write_byte(0)
	message_end()
}

public super_headshot(const id)
{
	set_pev(id, pev_body, 2)
	spawn_head_parts(id)
	set_task(0.5, "spawn_blood", id)
	set_task(1.2, "spawn_blood", id)
}

public client_death(killer, victim, wpnindex, hitplace, TK)
{
	if(hitplace == HIT_HEAD)
	{
		if(wpnindex == CSW_AWP || wpnindex == CSW_M3 || wpnindex == CSW_DEAGLE || wpnindex == CSW_XM1014 || wpnindex == CSW_SCOUT || wpnindex == CSW_G3SG1 || wpnindex == CSW_SG550)
		{
			new CsArmorType:armor 
			cs_get_user_armor(victim, armor)
			if(armor != CS_ARMOR_VESTHELM)
			{
				super_headshot(victim)
			}
		}
	}
}