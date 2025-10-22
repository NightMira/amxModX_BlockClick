#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <engine>

#define PLUGIN "StrafeHack Blocker"
#define VERSION "1.0"
#define AUTHOR "NightMira"

#pragma semicolon 1

#define TASK_TIME 0.2
#define MAX_STRAFES 14
#define MAX_ANGLEDIFF 25.0

#define FL_ONGROUND2 (FL_ONGROUND|FL_PARTIALGROUND|FL_INWATER|FL_CONVEYOR|FL_FLOAT)

new Float:g_fOldAngles[33][3];
new Float:g_fOldUCVAngles[33][3];
new g_iStrafes[33];
new bool:g_bTurningLeft[33], bool:g_bTurningRight[33], g_iOldTurning[33];
new bool:g_bIgnore[33];
new g_iTaskEnt, g_iMaxPlayers;

public plugin_init()
{
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_forward(FM_CmdStart, "FM_CmdStart_Pre", 0);
    RegisterHam(Ham_Spawn, "player", "Ham_PlayerSpawn_Post", true);
    
    CreateTask();
    g_iMaxPlayers = get_maxplayers();
}

public client_putinserver(id)
{
    reset_player_data(id);
}

public Ham_PlayerSpawn_Post(id)
{
    reset_player_data(id);
}

reset_player_data(id)
{
    g_iStrafes[id] = 0;
    g_bTurningLeft[id] = false;
    g_bTurningRight[id] = false;
    g_iOldTurning[id] = 0;
    g_bIgnore[id] = false;
}

CreateTask()
{
    register_think("task_ent", "Task_StrafesCheck");
    g_iTaskEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"));
    set_pev(g_iTaskEnt, pev_classname, "task_ent");
    set_pev(g_iTaskEnt, pev_nextthink, get_gametime() + 1.01);
}

public Task_StrafesCheck(ent)
{
    set_pev(ent, pev_nextthink, get_gametime() + TASK_TIME);
    
    for(new id = 1; id <= g_iMaxPlayers; id++)
    {
        if(!is_user_alive(id))
        {
            g_iStrafes[id] = 0;
            continue;
        }
        
        if(g_iStrafes[id] >= MAX_STRAFES)
        {
            new Float:fVelocity[3];
            pev(id, pev_velocity, fVelocity);
            fVelocity[0] *= 0.5;
            fVelocity[1] *= 0.5;
            set_pev(id, pev_velocity, fVelocity);
            
            client_print(id, print_center, "Too fast strafing! Slowed down.");
            g_iStrafes[id] = 0;
        }
        g_iStrafes[id] = 0;
    }
}

public FM_CmdStart_Pre(id, uc_handle, seed)
{
    if(!is_user_alive(id) || g_bIgnore[id]) 
        return FMRES_IGNORED;		
    
    new iFlags = pev(id, pev_flags);
    new Float:fVelocity[3]; 
    pev(id, pev_velocity, fVelocity);
    
    if(iFlags & FL_FROZEN || vector_length(fVelocity) < 100.0) 
        return FMRES_IGNORED;
    
    new iButtons = get_uc(uc_handle, UC_Buttons);
    new Float:fForwardMove; 
    get_uc(uc_handle, UC_ForwardMove, fForwardMove);
    new Float:fSideMove; 
    get_uc(uc_handle, UC_SideMove, fSideMove);
    new Float:fViewAngles[3]; 
    get_uc(uc_handle, UC_ViewAngles, fViewAngles);
    
    // Проверяем движение без нажатия клавиш
    if(~iFlags & FL_ONGROUND2)
    {
        new bool:bBlockSpeed = false;
        
        if((fForwardMove > 0.0 && ~iButtons & IN_FORWARD) || (fForwardMove < 0.0 && ~iButtons & IN_BACK))
        {
            bBlockSpeed = true;
        }
        if((fSideMove > 0.0 && ~iButtons & IN_MOVERIGHT) || (fSideMove < 0.0 && ~iButtons & IN_MOVELEFT))
        {
            bBlockSpeed = true;
        }
        
        if(bBlockSpeed)
        {
            fVelocity[0] *= 0.3;
            fVelocity[1] *= 0.3;
            set_pev(id, pev_velocity, fVelocity);
            client_print(id, print_center, "Invalid movement detected!");
        }
    }
    
    // Считаем страфы
    static Float:fAngles[3]; 
    pev(id, pev_angles, fAngles);
    static Float:fAnglesDiff[3]; 
    vec_diff(fAnglesDiff, fAngles, g_fOldAngles[id]);
    
    g_bTurningRight[id] = false;
    g_bTurningLeft[id] = false;
    
    if(fAngles[1] < g_fOldAngles[id][1])
    {
        g_bTurningRight[id] = true;
        if(g_iOldTurning[id] == 1) g_iStrafes[id]++; // LEFT
    }
    else if(fAngles[1] > g_fOldAngles[id][1])
    {
        g_bTurningLeft[id] = true;
        if(g_iOldTurning[id] == 2) g_iStrafes[id]++; // RIGHT
    }
    
    if(g_bTurningRight[id]) 
        g_iOldTurning[id] = 2;
    else if(g_bTurningLeft[id]) 
        g_iOldTurning[id] = 1;
    
    g_fOldAngles[id] = fAngles;
    g_fOldUCVAngles[id] = fViewAngles;
    
    return FMRES_IGNORED;
}

// Вспомогательные функции
vec_diff(Float:vec[3], Float:new_vec[3], Float:old_vec[3])
{
    vec[0] = floatabs(new_vec[0] - old_vec[0]);
    vec[1] = floatabs(new_vec[1] - old_vec[1]);
    vec[2] = floatabs(new_vec[2] - old_vec[2]);
}