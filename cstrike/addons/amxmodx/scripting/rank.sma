#include <amxmodx>
#include <csstats>

#define IME "Frags, HS, Rank"
#define VERZIJA "1.1"
#define AUTOR "FreeStyLe | Malli Bojan / Fix"

new g_MsgSync;
new g_iMsgScreenFade;
new FRAGS[33], HS[33];
new CT_SCORE, TERRORIST_SCORE;
new cvar_red, cvar_green, cvar_blue, cvar_x, cvar_y;

public plugin_init() {
    register_plugin(IME, VERZIJA, AUTOR);
   
    register_event("DeathMsg", "fw_PlayerDeath", "a");
    register_event("TeamScore", "skor", "a");
    register_event("DeathMsg", "EventDeath", "a", "1>0", "3=1");
   
    g_MsgSync = CreateHudSyncObj();
    g_iMsgScreenFade = get_user_msgid("ScreenFade");
   
    cvar_red = register_cvar("hud_red", "0");
    cvar_green = register_cvar("hud_green", "255");
    cvar_blue = register_cvar("hud_blue", "255");
    cvar_x = register_cvar("hud_x", "0.02");
    cvar_y = register_cvar("hud_y", "-1.0");
}

public client_connect(id) {
    FRAGS[id] = 0;
    HS[id] = 0;
    set_task(1.0, "fw_ShowHud", id, _, _, "b");
}

public client_disconnected(id) {
    // Fontos: Kilépéskor leállítjuk a frissítést, hogy ne spammelje a konzolt
    remove_task(id);
}

public skor() {
    new team[32];
    read_data(1, team, 31);
    if (equal(team, "CT")) {
        CT_SCORE = read_data(2);
    }
    else if (equal(team, "TERRORIST")) {
        TERRORIST_SCORE = read_data(2);
    }
}

public fw_PlayerDeath() {
    new killer = read_data(1);
    new victim = read_data(2);
    new headshot = read_data(3);
   
    if (killer == victim || get_user_team(killer) == get_user_team(victim))
        return PLUGIN_HANDLED;
   
    if (headshot) {
        HS[killer]++;
    }
    FRAGS[killer]++;
   
    FRAGS[victim] = 0;
    HS[victim] = 0;
   
    return PLUGIN_HANDLED;
}

public fw_ShowHud(id) {
    // Ha valamiért lefutna egy nem létezõ játékosra, megállítjuk
    if (!is_user_connected(id)) return;

    new stats[8], bodyhits[8];
    new RANK = get_user_stats(id, stats, bodyhits);
   
    // Személyes statisztika
    set_hudmessage(get_pcvar_num(cvar_red), get_pcvar_num(cvar_green), get_pcvar_num(cvar_blue), get_pcvar_float(cvar_x), get_pcvar_float(cvar_y));
    ShowSyncHudMsg(id, g_MsgSync, "%i ÖLÉS ( %i HS )^nRank: %i/%i", FRAGS[id], HS[id], RANK, get_statsnum());
   
    // CT Pontszám (Csatorna: 1)
    set_hudmessage(0, 70, 200, -1.0, 0.03, 0, 0.5, 2.0, 0.08, 2.0, 1);
    show_hudmessage(id, "[CT] Csapat %d      |  |", CT_SCORE);
     
    // Terror Pontszám (Csatorna: 2)
    set_hudmessage(200, 0, 0, -1.0, 0.03, 0, 0.5, 2.0, 0.08, 2.0, 2);
    show_hudmessage(id, "                                          |  |     %d [T] Csapat", TERRORIST_SCORE);
}

public EventDeath() {
    message_begin(MSG_ONE_UNRELIABLE, g_iMsgScreenFade, _, read_data(1));
    write_short(1 << 10);
    write_short(1 << 10);
    write_short(0x0000);
    write_byte(0);
    write_byte(0);
    write_byte(255);
    write_byte(255);
    message_end();
}