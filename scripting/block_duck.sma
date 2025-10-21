#include <amxmodx>
#include <fakemeta>

#define PLUGIN_NAME "[MG] Block Crouch"
#define PLUGIN_VERSION "1.4"
#define PLUGIN_AUTHOR "NightMira"

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
    register_forward(FM_PlayerPreThink, "fwdPlayerPreThink");
    register_forward(FM_PlayerPostThink, "fwdPlayerPostThink");
}

public fwdPlayerPreThink(id)
{
    if (!is_user_connected(id) || !is_user_alive(id))
        return FMRES_IGNORED;
    
    new button = pev(id, pev_button);
    new oldbuttons = pev(id, pev_oldbuttons);
    
    if (button & IN_DUCK)
    {
        button &= ~IN_DUCK;
        oldbuttons &= ~IN_DUCK;
        
        set_pev(id, pev_button, button);
        set_pev(id, pev_oldbuttons, oldbuttons);
        
        return FMRES_SUPERCEDE;
    }
    
    return FMRES_IGNORED;
}

public fwdPlayerPostThink(id)
{
    if (!is_user_connected(id) || !is_user_alive(id))
        return FMRES_IGNORED;
    
    if (pev(id, pev_flags) & FL_DUCKING)
    {
        set_pev(id, pev_flags, pev(id, pev_flags) & ~FL_DUCKING);
        set_pev(id, pev_bInDuck, 0);
        set_pev(id, pev_flDuckTime, 0.0);
        
        // Восстанавливаем нормальный размер
        set_pev(id, pev_mins, Float:{-16.0, -16.0, -36.0});
        set_pev(id, pev_maxs, Float:{16.0, 16.0, 36.0});
        
        client_print(id, print_center, "Crouch is blocked!");
    }
    
    return FMRES_IGNORED;
}