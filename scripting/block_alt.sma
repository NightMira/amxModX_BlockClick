#include <amxmodx>
#include <fakemeta>

#define PLUGIN_NAME "[MG] Block ALT"
#define PLUGIN_VERSION "1.6"
#define PLUGIN_AUTHOR "NightMira"

new g_LastButtons[33];

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
    register_forward(FM_PlayerPreThink, "fwdPlayerPreThink");
}

public fwdPlayerPreThink(id)
{
    if (!is_user_connected(id) || !is_user_alive(id))
        return FMRES_IGNORED;
    
    new button = pev(id, pev_button);
    new oldbuttons = pev(id, pev_oldbuttons);
    
    if ((button & IN_ALT1) && !(g_LastButtons[id] & IN_ALT1))
    {
        client_print(id, print_chat, "[MG] ALT Strafe mode blocked!");
    }
    
    if (button & IN_ALT1)
    {
        button &= ~IN_ALT1;
        oldbuttons &= ~IN_ALT1;
        
        set_pev(id, pev_button, button);
        set_pev(id, pev_oldbuttons, oldbuttons);
        
        client_print(id, print_center, "ALT Strafe blocked!");
        return FMRES_SUPERCEDE;
    }
    
    g_LastButtons[id] = button;
    
    return FMRES_IGNORED;
}