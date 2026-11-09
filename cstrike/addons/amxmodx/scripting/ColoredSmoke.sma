#include <amxmodx>
#include <fakemeta>

new g_iSmokeSprites[6]

public plugin_init() {
    register_plugin("Thick Colored Smoke", "1.4", "AMXX")
    register_forward(FM_EmitSound, "FwdEmitSound")
}

public plugin_precache() {
    g_iSmokeSprites[0] = precache_model("sprites/gas_puff_01y.spr")
    g_iSmokeSprites[1] = precache_model("sprites/gas_puff_01r.spr")
    g_iSmokeSprites[2] = precache_model("sprites/gas_puff_01b.spr")
    g_iSmokeSprites[3] = precache_model("sprites/gas_puff_01g.spr")
    g_iSmokeSprites[4] = precache_model("sprites/gas_puff_01m.spr")
    g_iSmokeSprites[5] = precache_model("sprites/gas_puff_01o.spr")
}

public FwdEmitSound(ent, channel, const sample[]) {
    if(!pev_valid(ent)) return FMRES_IGNORED;
    
    if(equal(sample, "weapons/sg_explode.wav")) {
        new Float:origin[3]
        pev(ent, pev_origin, origin)
        
        new color = random_num(0, 5)
        
        // 1. Eltüntetjük az eredeti gránátot, hogy NE legyen szürke füst
        set_pev(ent, pev_origin, Float:{8192.0, 8192.0, 8192.0})
        set_pev(ent, pev_flags, pev(ent, pev_flags) | FL_KILLME)
        
        // 2. Létrehozzuk a tiszta, sűrű színes füstöt az eredeti helyen
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
        write_byte(TE_FIREFIELD)
        engfunc(EngFunc_WriteCoord, origin[0])
        engfunc(EngFunc_WriteCoord, origin[1])
        engfunc(EngFunc_WriteCoord, origin[2] + 50.0)
        write_short(100)
        write_short(g_iSmokeSprites[color])
        write_byte(100)
        write_byte(TEFIRE_FLAG_ALPHA)
        write_byte(1000)
        message_end()
        
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
        write_byte(TE_FIREFIELD)
        engfunc(EngFunc_WriteCoord, origin[0])
        engfunc(EngFunc_WriteCoord, origin[1])
        engfunc(EngFunc_WriteCoord, origin[2] + 50.0)
        write_short(150)
        write_short(g_iSmokeSprites[color])
        write_byte(10)
        write_byte(TEFIRE_FLAG_ALPHA | TEFIRE_FLAG_SOMEFLOAT)
        write_byte(1000)
        message_end()
        
        // 3. Visszajátsszuk a robbanás hangját, mivel a gránátot eltüntettük
        engfunc(EngFunc_EmitAmbientSound, 0, origin, sample, 1.0, ATTN_NORM, 0, PITCH_NORM)
        
        return FMRES_SUPERCEDE;
    }
    return FMRES_IGNORED;
}