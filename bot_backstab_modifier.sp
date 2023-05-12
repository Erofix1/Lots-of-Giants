#define PLUGIN_NAME "Bot Backstab Modifier"
#define PLUGIN_DESCRIPTION "Giant Player RobotBackstab modifier"
#define PLUGIN_AUTHOR "Heavy Is GPS"
#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_URL "Balancemod.tf"

#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <tf_ontakedamage>


#pragma newdecls required
#pragma semicolon 1

enum //Convar names
{
    CV_flSpyBackStabModifier,
    CV_flSpyBackStabModifierBoss,
    CV_bDebugMode,
    CV_PluginVersion
}
/* Global Variables */

/* Global Handles */

//Handle g_hGameConf;

/* Dhooks */

/* Convar Handles */

ConVar g_cvCvarList[CV_PluginVersion + 1];

/* Convar related global variables */

bool g_cv_bDebugMode;


float g_CV_flSpyBackStabModifier;
float g_CV_flSpyBackStabModifierBoss;


public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_URL
};
public void OnPluginStart()
{
    /* Convars */


    g_cvCvarList[CV_PluginVersion] = CreateConVar("sm_robot_backstab_version", PLUGIN_VERSION, "Plugin Version.", FCVAR_NOTIFY | FCVAR_DONTRECORD | FCVAR_CHEAT);
    g_cvCvarList[CV_bDebugMode] = CreateConVar("sm_robot_backstab_debug", "0", "Enable Debugging for Market Garden and Reserve Shooter damage", FCVAR_NOTIFY, true, 0.0, true, 1.0);
    g_cvCvarList[CV_flSpyBackStabModifier] = CreateConVar("sm_robot_backstab_damage_miniboss", "500.0", "Override the Backstab damage");
    g_cvCvarList[CV_flSpyBackStabModifierBoss] = CreateConVar("sm_robot_backstab_damage_boss", "5000.0", "Override the Backstab damage");

    /* Convar global variables init */

    g_cv_bDebugMode = GetConVarBool(g_cvCvarList[CV_bDebugMode]);
    g_CV_flSpyBackStabModifier = GetConVarFloat(g_cvCvarList[CV_flSpyBackStabModifier]);


    /* Convar Change Hooks */

    g_cvCvarList[CV_bDebugMode].AddChangeHook(CvarChangeHook);
    g_cvCvarList[CV_flSpyBackStabModifier].AddChangeHook(CvarChangeHook);
    g_cvCvarList[CV_flSpyBackStabModifierBoss].AddChangeHook(CvarChangeHook);

}
/* Publics */
public void CvarChangeHook(ConVar convar, const char[] sOldValue, const char[] sNewValue)
{
    if(convar == g_cvCvarList[CV_bDebugMode])
        g_cv_bDebugMode = view_as<bool>(StringToInt(sNewValue));
    if(convar == g_cvCvarList[CV_flSpyBackStabModifier])
        g_CV_flSpyBackStabModifier = StringToFloat(sNewValue);
    if(convar == g_cvCvarList[CV_flSpyBackStabModifierBoss])
      g_CV_flSpyBackStabModifierBoss = StringToFloat(sNewValue);
}

/* Plugin Exclusive Functions */
public Action TF2_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom, CritType &critType)
{
    if(IsValidClient(victim))
    {
        if(IsValidClient(attacker))
        {
            TFClassType iClass = TF2_GetPlayerClass(attacker);
            if(iClass == TFClass_Spy)
            {
                // Checks if boss is on
                if(g_cv_bDebugMode)
                    
                    if(isMiniBoss(victim) && damagecustom == TF_CUSTOM_BACKSTAB)
                    {
                        damage = g_CV_flSpyBackStabModifier;
                        if(g_cv_bDebugMode)PrintToChatAll("Set damage to %f", damage);
                            return Plugin_Changed;
                    }

                    if(isBoss(victim) && damagecustom == TF_CUSTOM_BACKSTAB)
                    {
                        damage = g_CV_flSpyBackStabModifierBoss;
                        if(g_cv_bDebugMode)PrintToChatAll("Set damage to %f", damage);
                            return Plugin_Changed;
                    }
            }
        }
    }
    return Plugin_Continue;
}



bool isMiniBoss(int client)
{

    if(IsValidClient(client))
    {

        if(GetEntProp(client, Prop_Send, "m_bIsMiniBoss") == 1)
        {
            if(g_cv_bDebugMode)
                //     PrintToChatAll("Was mini boss");
                return true;
        }
        else
        {
            if(g_cv_bDebugMode)
                //    PrintToChatAll("Was not mini boss");
                return false;
        }
    }
    return false;
}

bool isBoss(int client)
{

    if(IsValidClient(client))
    {
            //Not sure what netprop you use to set boss, but you can change that here unless you set miniboss to something else.
        if(GetEntProp(client, Prop_Send, "m_bIsMiniBoss") == 2)
        {
            if(g_cv_bDebugMode) PrintToChatAll("Was a boss");
                return true;
        }
        else
        {
            if(g_cv_bDebugMode)PrintToChatAll("Was not a boss");
                return false;
        }
    }
    return false;
}


/* Stocks */
stock bool IsValidClient(int client, bool replaycheck = true)
{
    if(client <= 0 || client > MaxClients)
        return false;
    if(!IsClientInGame(client))
        return false;
    if(GetEntProp(client, Prop_Send, "m_bIsCoaching"))
        return false;
    if(replaycheck)
    {
        if(IsClientSourceTV(client) || IsClientReplay(client))
            return false;
    }
    return true;
}