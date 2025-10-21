#include <amxmodx>
#include <version>

#define PLUGIN_NAME "[MG] Block Click"
#define PLUGIN_VERSION "0.0.1"

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PROJECT_AUTHOR);
    
    register_clcmd("say +duck", "cmd_duck");
}

public cmd_duck(id)
{
    client_print(id, print_chat, "Duck is Blocked", PLUGIN_NAME, PLUGIN_VERSION);
    return PLUGIN_HANDLED;
}
