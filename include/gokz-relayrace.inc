#if defined _gokz_relayrace_included_
#endinput
#endif
#define _gokz_relayrace_included


#define MAXCLIENTS 65
// #define TEAM_COUNT 1
// #define SLOT_COUNT 1
#define GOKZ_RELAYRACE_SECTION_START_REGEX "^section_start_(\\d+)$"
#define GOKZ_RELAYRACE_SECTION_END_REGEX "^section_end_(\\d+)$"
//#define GOKZ_RELAYRACE_SECTION_END_HANDLER_REGEX "^section_end_handler_(\\d+)$"
#define GOKZ_RELAYRACE_SECTION_START_TELEPORT_REGEX "^tp_start_(\\d+)$"


stock char gC_CountdownSound[64] = "ui/competitive_accept_beep.wav"; 
stock char gC_CountdownZeroSound[64] = "ui/mm_success_lets_roll.wav";
stock char gC_OnFreePlayerSound[64] = "player/vo/anarchist/radio_letsgo01.wav";
stock char gC_CountdownReadySound[64] = "ui/lobby_notification_matchready.wav";
stock char gC_ErrorSound[64] = "buttons/button10.wav";


enum RaceStatus:
{
	RaceStatus_End = 0,
	RaceStatus_Waiting, 
	RaceStatus_Running, 
	RACESTATUS_COUNT,
}

enum Color:
{
	Color_White = 0,
	Color_Red,
	Color_Purple,
	Color_Green,
	Color_GreenYellow,
	Color_DarkGreen,
	Color_DarkRed,
	Color_Grey,
	Color_Yellow,
	COLOR_COUNT,
}

stock char gC_Colors[COLOR_COUNT][5] = {"\x01", "\x02", "\x03", "\x04", "\x05", "\x06", "\x07", "\x08", "\x09"};
stock char gC_Teams[8][7] = {"Team A", "Team B", "Team C", "Team D", "Team E", "Team F", "Team G", "Team H"};
stock char gC_Slots[8][8] = {"Stage 1", "Stage 2", "Stage 3", "Stage 4", "Stage 5", "Stage 6", "Stage 7", "Stage 8"};
stock int Clamp(int target, int min, int max)
{
	return target > min ? (target < max ? target : max) : min;
}

native RaceStatus GOKZ_Relayrace_GetCurrentRaceStatus();

native void GOKZ_Relayrace_ResetRaceStatus();

 /**
	* set up a new race
	* @param client operator
	*/
native void GOKZ_Relayrace_SetupRace(int client);

native void GOKZ_Relayrace_StartRace(int client);

/**
	* end race
	* @param client if race ended naturally, pass -1, otherwise pass the index of operator
	*/
native void GOKZ_Relayrace_EndRace(int client);

native bool GOKZ_Relayrace_IsRacer(int client);

native void GOKZ_Relayrace_AddRacer(int client, int team, int slot);

native bool GOKZ_Relayrace_CanStartRace();

native bool GOKZ_Relayrace_CanEndRace();

 /**
	* do smth when a team is finished
	* @param team operator
	*/
native void GOKZ_Relayrace_TeamFinished(int team);

native bool GOKZ_Relayrace_IsTeamFull(int team);

native void GOKZ_Relayrace_FreezePlayer(int client);

native void GOKZ_Relayrace_FreePlayer(int client);




