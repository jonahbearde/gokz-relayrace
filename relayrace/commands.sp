void RegisterCommands()
{
	RegConsoleCmd("sm_setuprace", CommandSetupRace, "initiate a race");
	RegConsoleCmd("sm_str", CommandSetupRace, "abbr for sm_setuprace");
	RegConsoleCmd("sm_startrace", CommandStartRace, "start a race");
	RegConsoleCmd("sm_sr", CommandStartRace, "abbr for sm_startrace");
	RegConsoleCmd("sm_endrace", CommandEndRace, "end a running race");
	RegConsoleCmd("sm_er", CommandEndRace, "abbr for sm_endrace");
	RegConsoleCmd("sm_joinrace", CommandJoinRace, "open menu to join a race");
	RegConsoleCmd("sm_jr", CommandJoinRace, "abbr for sm_joinrace");
}

public Action CommandSetupRace(int client, int args)
{
	// only for operators
	if (IsValidClient(client) && GetUserAdmin(client) != INVALID_ADMIN_ID)
	{
		if (GOKZ_Relayrace_GetCurrentRaceStatus() == RaceStatus_Running)
		{
			GOKZ_PrintToChat(client, true, "%s比赛进行中, 无法发起比赛", gC_Colors[Color_DarkRed]);
		}
		else if (GOKZ_Relayrace_GetCurrentRaceStatus() == RaceStatus_Waiting)
		{
			GOKZ_PrintToChat(client, true, "%s比赛已发起", gC_Colors[Color_DarkRed]);
		}
		else
		{
			// set up a race
			GOKZ_Relayrace_SetupRace(client);
		}
		
	}
	return Plugin_Handled;
}

public Action CommandStartRace(int client, int args)
{
	// only for operators
	if (IsValidClient(client) && GetUserAdmin(client) != INVALID_ADMIN_ID)
	{
		// start a race
		GOKZ_Relayrace_StartRace(client);
	}
	return Plugin_Handled;
}

public Action CommandEndRace(int client, int args)
{
	// only for operators
	if (IsValidClient(client) && GetUserAdmin(client) != INVALID_ADMIN_ID)
	{
		if (GOKZ_Relayrace_GetCurrentRaceStatus() == RaceStatus_End)
		{
			GOKZ_PrintToChat(client, true, "%s比赛尚未开始", gC_Colors[Color_DarkRed]);
		}
		else
		{
			// end a running race forcefully
			GOKZ_Relayrace_EndRace(client);
		}
	}
	return Plugin_Handled;
}

public Action CommandJoinRace(int client, int args)
{
	if (IsValidClient(client))
	{
		if (GOKZ_Relayrace_GetCurrentRaceStatus() == RaceStatus_Running)
		{
			GOKZ_PrintToChat(client, true, "%s比赛进行中, 无法加入", gC_Colors[Color_DarkRed]);
		}
		else if (GOKZ_Relayrace_GetCurrentRaceStatus() == RaceStatus_End)
		{
			GOKZ_PrintToChat(client, true, "%s比赛还未发起", gC_Colors[Color_DarkRed]);
		}
		else
		{
			// open menu to select teams and slots
			Showmenu_JoinRace(client);
		}
	}
	return Plugin_Handled;
}