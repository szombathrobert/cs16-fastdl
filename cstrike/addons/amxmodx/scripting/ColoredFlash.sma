#include <amxmodx>

public plugin_init() {
    register_plugin("Colored Flashbang", "1.0", "AMXX")
    // Elkapjuk a képernyő elhalványítás (vakítás) üzenetét
    register_message(get_user_msgid("ScreenFade"), "Message_ScreenFade")
}

public Message_ScreenFade(msg_id, msg_dest, msg_entity) {
    // Ellenőrizzük, hogy a kapott szín tiszta fehér-e (255, 255, 255), azaz flashbang
    if (get_msg_arg_int(4) != 255 || get_msg_arg_int(5) != 255 || get_msg_arg_int(6) != 255)
        return PLUGIN_CONTINUE;

    // Ha vakítás, sorsolunk egy új színt, és felülírjuk az RGB értékeket
    new color = random_num(0, 5);
    switch(color) {
        case 0: { set_msg_arg_int(4, ARG_BYTE, 255); set_msg_arg_int(5, ARG_BYTE, 0);   set_msg_arg_int(6, ARG_BYTE, 0);   } // Piros
        case 1: { set_msg_arg_int(4, ARG_BYTE, 0);   set_msg_arg_int(5, ARG_BYTE, 255); set_msg_arg_int(6, ARG_BYTE, 0);   } // Zöld
        case 2: { set_msg_arg_int(4, ARG_BYTE, 0);   set_msg_arg_int(5, ARG_BYTE, 0);   set_msg_arg_int(6, ARG_BYTE, 255); } // Kék
        case 3: { set_msg_arg_int(4, ARG_BYTE, 255); set_msg_arg_int(5, ARG_BYTE, 255); set_msg_arg_int(6, ARG_BYTE, 0);   } // Sárga
        case 4: { set_msg_arg_int(4, ARG_BYTE, 255); set_msg_arg_int(5, ARG_BYTE, 0);   set_msg_arg_int(6, ARG_BYTE, 255); } // Lila
        case 5: { set_msg_arg_int(4, ARG_BYTE, 0);   set_msg_arg_int(5, ARG_BYTE, 255); set_msg_arg_int(6, ARG_BYTE, 255); } // Cián
    }
    return PLUGIN_CONTINUE;
}