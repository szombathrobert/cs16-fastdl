#include <amxmodx>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <fakemeta_util>
#include <engine>
#include <hamsandwich>
 
#define PLUGIN "Weapon Case 1.2"
#define VERSION "1.2"
#define AUTHOR "6almasok / Fix"
 
#define AWPNUMBER 2
 
new bool:choosedGun[33][2], cVars[7], tUseWP, ctUseWP, bEnt = -1, doNotShowHud, leftSec
 
new const case_model[] = "models/weap_case/case.mdl"
new const case_sound[] = "weap_case/case_spawn.wav"
new const prefix[] = "[Weapon Case]"
 
new const WeaponCSW[][2] = {
    {CSW_AK47, 90}, {CSW_M4A1, 90}, {CSW_AWP, 30}, {CSW_FAMAS, 90},
    {CSW_GALIL, 90}, {CSW_AUG, 90}, {CSW_SG552, 90}, {CSW_SCOUT, 90},
    {CSW_M249, 200}, {CSW_M3, 32}, {CSW_XM1014, 32}, {CSW_TMP, 120},
    {CSW_MAC10, 100}, {CSW_MP5NAVY, 120}, {CSW_UMP45, 100}, {CSW_P90, 100}
}
new const PistolCSW[][2] = {
    {CSW_GLOCK18, 120}, {CSW_USP, 100}, {CSW_P228, 52},
    {CSW_DEAGLE, 35}, {CSW_FIVESEVEN, 100}, {CSW_ELITE, 120}
}
 
new const WeaponNames[][] = {
    "Ak-47", "M4A1", "AWP Magnum", "Famas", "Galil-AR", "AUG Bullpup",
    "SG552", "SCHMIDT Scout", "M249", "Shutgun", "Auto-Shotgun", "TMP",
    "MAC-10", "KM MP5-Navy", "KM UMP45", "P90-ES"
}
new const WeaponEnts[][] = {
    "weapon_ak47", "weapon_m4a1", "weapon_awp", "weapon_famas", "weapon_galil", "weapon_aug",
    "weapon_sg552", "weapon_scout", "weapon_m249", "weapon_m3", "weapon_xm1014", "weapon_tmp",
    "weapon_mac10", "weapon_mp5navy", "weapon_ump45", "weapon_p90"
}
 
new const PistolNames[][] = {
    "Glock 18", "HK USP", "P228", "Desert Eagle", "Five-Seven", "Dual Elites"
}
new const PistolEnts[][] = {
    "weapon_glock18", "weapon_usp", "weapon_p228", "weapon_deagle", "weapon_fiveseven", "weapon_elite"
}
 
public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR)
   
    RegisterHam(Ham_Spawn, "player", "fw_player_spawn_post", 1)
    register_touch("weap_case" ,"player" ,"caseTouched")
   
    register_logevent("round_end", 2, "1=Round_End")
    register_logevent("round_start", 2, "1=Round_Start")
    register_event("Money", "setUserMoney", "b")
   
    cVars[0] = register_cvar("weapc_killentitysec", "30")
    cVars[1] = register_cvar("weapc_needplaytowp", "3")
    cVars[2] = register_cvar("weapc_allsniper", "3")
    cVars[3] = register_cvar("weapc_gotflash", "2")
    cVars[4] = register_cvar("weapc_gotheg", "1")
    cVars[5] = register_cvar("weapc_gotsmoke", "1")
    cVars[6] = register_cvar("weapc_usepistolmenu", "1")
   
    while((bEnt = find_ent_by_class(bEnt, "func_buyzone"))) {
        entity_set_int(bEnt, EV_INT_team, 3)
    }
}
public blockZone(id) {
    return PLUGIN_HANDLED
}
public setUserMoney(id) {
    if(is_user_connected(id)) {
        set_pdata_int(id, 115, 0)
        message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("Money"), _, id)
        write_long(0)
        write_byte(1)
        message_end()
    }
}
public fw_player_spawn_post(id) {
    choosedGun[id][0] = false
    choosedGun[id][1] = false
}
public caseTouched(ent, id) {
    open_WeapMENU(id)
    fm_strip_user_gun(id, 16, "weapon_usp")
    fm_strip_user_gun(id, 17, "weapon_glock18")
}
public plugin_precache() {
    precache_model(case_model)
    precache_sound(case_sound)
}
public round_end() {
    static id
    doNotShowHud = 1
    tUseWP = 0
    ctUseWP = 0
   
    for(id = 1; id <= get_playersnum(); id++) {
        if(is_user_connected(id)) strip_user_weapons(id)
    }
    killEntity()
}
public round_start() {
    CaseLoad()
    timeZone()
    doNotShowHud = 0
    client_cmd(0, "spk %s", case_sound)
}
public timeZone() {
    leftSec++
    if(leftSec < 30) {
        set_task(1.0, "timeZone")
    } else {
        killEntity()
    }
   
    set_hudmessage(0, 255, 0, -1.0, 0.16, 0, 6.0, 1.0)
    show_hudmessage(0, "A fegyveres lada megjelent!^nMeg %i mp-ig tudtok vasarolni azutan eltunik.", get_pcvar_num(cVars[0])-leftSec)
}
public killEntity() {
    new fm_Null = FM_NULLENT
    while((fm_Null = fm_find_ent_by_class(fm_Null, "weap_case"))) {
        engfunc(EngFunc_RemoveEntity, fm_Null)
    }
   
    if(doNotShowHud == 0){
        set_hudmessage(0, 255, 0, -1.0, 0.16, 2, 6.0, 5.0)
        show_hudmessage(0, "Letelt a fegyver vasarlasi ido!")
    }
    remove_task(0)
    leftSec = 0
    show_menu(0, 0, "^n", 1)
}
public CaseLoad() {
    new Float:pOrigin[3], Float:sOrigin[3]
    sOrigin[0] = -650.0
    sOrigin[1] = -771.0
    sOrigin[2] = 164.0
    
    pOrigin[0] = 325.0
    pOrigin[1] = 2305.0
    pOrigin[2] = -91.0
 
    new pEnt = create_entity("info_target")
    new sEnt = create_entity("info_target")
   
    set_pev(pEnt, pev_classname, "weap_case")
    engfunc(EngFunc_SetModel, pEnt, case_model)
    set_pev(pEnt,pev_solid, SOLID_BBOX)
    set_pev(pEnt, pev_movetype, MOVETYPE_TOSS)
    engfunc(EngFunc_SetOrigin, pEnt, pOrigin)
    engfunc(EngFunc_SetSize, pEnt, Float:{-10.0,-10.0,0.0}, Float:{10.0,10.0,25.0})
    engfunc(EngFunc_DropToFloor, pEnt)
   
    set_pev(sEnt, pev_classname, "weap_case")
    engfunc(EngFunc_SetModel, sEnt, case_model)
    set_pev(sEnt,pev_solid, SOLID_BBOX)
    set_pev(sEnt, pev_movetype, MOVETYPE_TOSS)
    engfunc(EngFunc_SetOrigin, sEnt, sOrigin)
    engfunc(EngFunc_SetSize, sEnt, Float:{-10.0,-10.0,0.0}, Float:{10.0,10.0,25.0})
    engfunc(EngFunc_DropToFloor, sEnt)
}
public open_WeapMENU(id) {
    if(choosedGun[id][0] && choosedGun[id][1]) return PLUGIN_HANDLED
    if(choosedGun[id][0] && !choosedGun[id][1]) {
        open_PistolMENU(id)
        return PLUGIN_HANDLED
    }
   
    new szMenu[121]
    formatex(szMenu, charsmax(szMenu), "\r%s \yValassz Fegyvert", prefix)
    new menu = menu_create(szMenu, "choose_Gun");
 
    for(new i = 0; i < sizeof(WeaponNames); i++){
        formatex(szMenu, charsmax(szMenu), "%s%s", WeaponNames[i], get_pcvar_num(cVars[6]) ? "" : " \yCsomag")
        menu_additem(menu, szMenu, "", 0)
    }
   
    menu_display(id, menu, 0)
    return PLUGIN_CONTINUE
}
public choose_Gun(id, menu, item) {
    if(item == MENU_EXIT) {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }
   
    if(item == AWPNUMBER) {
        new iPlayers[32], iNumCT , iNumT
        get_players(iPlayers, iNumCT, "e", "CT" )
        get_players(iPlayers, iNumT, "e", "TERRORIST")
       
        if(iNumCT < get_pcvar_num(cVars[1]) || iNumT < get_pcvar_num(cVars[1])) {
            client_print(id, print_chat, "%s Legalabb %iv%i kell legyen az AWP hasznalatahoz!", prefix, get_pcvar_num(cVars[1]), get_pcvar_num(cVars[1]))
            return PLUGIN_HANDLED
        }
       
        if(cs_get_user_team(id) == CS_TEAM_CT) {
            if(ctUseWP < get_pcvar_num(cVars[2])) ctUseWP++
            else {
                client_print(id, print_chat, "%s Csapatodba max csak %i hasznalhat AWP-t!", prefix, get_pcvar_num(cVars[2]))
                return PLUGIN_HANDLED
            }
        }
        else if(cs_get_user_team(id) == CS_TEAM_T) {
            if(tUseWP < get_pcvar_num(cVars[2])) tUseWP++
            else {
                client_print(id, print_chat, "%s Csapatodba max csak %i hasznalhat AWP-t!", prefix, get_pcvar_num(cVars[2]))
                return PLUGIN_HANDLED
            }
        }
    }
   
    give_item(id, WeaponEnts[item])
    cs_set_user_bpammo(id, WeaponCSW[item][0], WeaponCSW[item][1])
    client_print(id, print_chat, "%s %s%s sikeresen kivalasztva.", prefix, WeaponNames[item], get_pcvar_num(cVars[2]) ? "" : " Csomag")
    choosedGun[id][0] = true
   
    if(!get_pcvar_num(cVars[6])) {
        give_item(id, "weapon_deagle")
        cs_set_user_bpammo(id, CSW_DEAGLE, 35)
        addEquipMents(id)
    } else {
        open_PistolMENU(id)
    }
   
    menu_destroy(menu)
    return PLUGIN_HANDLED
}
public open_PistolMENU(id) {
    new szMenu[121]
    formatex(szMenu, charsmax(szMenu), "\r%s \yValassz Pisztolyt", prefix)
    new menu = menu_create(szMenu, "choose_Pistol")
 
    for(new i=0; i < sizeof(PistolNames); i++) {
        formatex(szMenu, charsmax(szMenu), "%s", PistolNames[i])
        menu_additem(menu, szMenu, "", 0)
    }
   
    menu_display(id, menu, 0)
}
public choose_Pistol(id, menu, item) {
    if(item == MENU_EXIT) {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }
 
    give_item(id, PistolEnts[item])
    cs_set_user_bpammo(id, PistolCSW[item][0], PistolCSW[item][1])
    client_print(id, print_chat, "%s %s pistoly sikeresen kivalasztva.", prefix, PistolNames[item])
    addEquipMents(id)
 
    menu_destroy(menu)
    return PLUGIN_HANDLED
}
public addEquipMents(id) {
    if(cs_get_user_team(id) == CS_TEAM_CT) give_item(id, "item_thighpack")
    give_item(id, "item_assaultsuit")
    give_item(id, "weapon_knife")
       
    if(get_pcvar_num(cVars[3])) {
        give_item(id, "weapon_flashbang")
        cs_set_user_bpammo(id, CSW_FLASHBANG, get_pcvar_num(cVars[3]))
    }
    if(get_pcvar_num(cVars[4])) {
        give_item(id, "weapon_hegrenade")
        cs_set_user_bpammo(id, CSW_HEGRENADE, get_pcvar_num(cVars[4]))
    }
    if(get_pcvar_num(cVars[5])) {
        give_item(id, "weapon_smokegrenade")
        cs_set_user_bpammo(id, CSW_SMOKEGRENADE, get_pcvar_num(cVars[5]))
    }
    choosedGun[id][1] = true
}