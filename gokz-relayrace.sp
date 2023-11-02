#include <emitsoundany>
#include <gokz-relayrace>
#include <gokz/core>
#include <sdkhooks>
#include <sdktools>
#include <sourcemod>
#include <strings>

RaceStatus gI_raceStatus;

// ConVars
ConVar gCV_teamCount;
ConVar gCV_slotCount;

// team stuff
bool gB_isTeamFinished[8];
int  gI_teamFinishCount;
int  gI_teamRank[8];
char gC_teamTime[8][16];

// racer stuff
bool  gB_isRacer[MAXCLIENTS];
int   gI_teamOfRacer[MAXCLIENTS];
int   gI_slotOfRacer[MAXCLIENTS];
int   gI_racers[8][8];
float gF_racerStartTime[MAXCLIENTS];
float gF_racerEndTime[MAXCLIENTS];
float gF_racerTime[MAXCLIENTS];

//Handle gH_notifySychronizer;

#include "relayrace/commands.sp"
#include "relayrace/Countdown.sp"
#include "relayrace/menus.sp"
#include "relayrace/natives.sp"
#include "relayrace/sections.sp"

public Plugin:myinfo = {
	name        = "GOKZ Relay Race",
	author      = "Reeed",
	description = "Made for relay racing in kreedz mode",
	version     = "1.0",
	url         = "https://gokz.cn"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNatives();
	return APLRes_Success;
}

public OnMapStart()
{
	PrecacheSounds();
	GOKZ_Relayrace_ResetRaceStatus();
}

void PrecacheSounds()
{
	PrecacheSoundAny(gC_CountdownSound);
	PrecacheSoundAny(gC_CountdownZeroSound);
	PrecacheSoundAny(gC_OnFreePlayerSound);
	PrecacheSoundAny(gC_CountdownReadySound);
	PrecacheSound(gC_ErrorSound);
}

public void OnPluginStart()
{
	gCV_teamCount = CreateConVar("sm_relayrace_team", "1", "the number of teams in a race", FCVAR_NOTIFY);
	gCV_slotCount = CreateConVar("sm_relayrace_slot", "1", "the number of slots each team should have", FCVAR_NOTIFY);

	gCV_teamCount.AddChangeHook(OnTeamCountChange);
	gCV_slotCount.AddChangeHook(OnSlotCountChange);

	GOKZ_Relayrace_ResetRaceStatus();
	RegisterCommands();
	OnPluginStart_Countdown();
	OnPluginStart_Sections();
	OnPluginStart_Menus();

	GOKZ_PrintToChatAll(true, "%s[GOKZ Relay Race] {default}reloaded successfully", gC_Colors[Color_Yellow]);
	
	RegConsoleCmd("sm_test", test, "debug stuff");
}

public Action test(int client, int args)
{
	GOKZ_PlayErrorSound(client);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	SDKHook(entity, SDKHook_Spawn, OnEntitySpawned);
}

public void OnEntitySpawned(int entity)
{
	OnEntitySpawned_SectionZones(entity);
	OnEntitySpawned_SectionTeleports(entity);
}

public OnTeamCountChange(ConVar convar, char[] oldVal, char[] newVal)
{
	GOKZ_Relayrace_ResetRaceStatus();
}

public OnSlotCountChange(ConVar convar, char[] oldVal, char[] newVal)
{
	GOKZ_Relayrace_ResetRaceStatus();
}