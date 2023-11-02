void CreateNatives()
{
	CreateNative("GOKZ_Relayrace_GetCurrentRaceStatus", Native_Relayrace_GetCurrentRaceStatus);
	CreateNative("GOKZ_Relayrace_ResetRaceStatus", Native_Relayrace_ResetRaceStatus);
	CreateNative("GOKZ_Relayrace_SetupRace", Native_Relayrace_SetupRace);
	CreateNative("GOKZ_Relayrace_StartRace", Native_Relayrace_StartRace);
	CreateNative("GOKZ_Relayrace_EndRace", Native_Relayrace_EndRace);
	CreateNative("GOKZ_Relayrace_IsRacer", Native_Relayrace_IsRacer);
	CreateNative("GOKZ_Relayrace_AddRacer", Native_Relayrace_AddRacer);
	CreateNative("GOKZ_Relayrace_IsTeamFull", Native_Relayrace_IsTeamFull);
	CreateNative("GOKZ_Relayrace_FreezePlayer", Native_Relayrace_FreezePlayer);
	CreateNative("GOKZ_Relayrace_FreePlayer", Native_Relayrace_FreePlayer);
	CreateNative("GOKZ_Relayrace_CanStartRace", Native_Relayrace_CanStartRace);
	CreateNative("GOKZ_Relayrace_CanEndRace", Native_Relayrace_CanEndRace);
	CreateNative("GOKZ_Relayrace_TeamFinished", Native_Relayrace_TeamFinished);
}

public any Native_Relayrace_GetCurrentRaceStatus(Handle plugin, int numParams)
{
	return gI_raceStatus;
}

public int Native_Relayrace_ResetRaceStatus(Handle plugin, int numParams)
{
	gI_raceStatus = RaceStatus_End;
	ResetCountdown();
	for (int client = 1; client < MAXCLIENTS; client++)
	{
		gI_teamOfRacer[client] = -1;
		gI_slotOfRacer[client] = -1;
		gF_racerTime[client]   = 0.0;
		gB_isRacer[client]     = false;
	}
	int teamCount = gCV_teamCount.IntValue;
	int slotCount = gCV_slotCount.IntValue;
	for (int team = 0; team < teamCount; team++)
	{
		gB_isTeamFinished[team] = false;
		gI_teamFinishCount      = 0;
		gI_teamRank[team]       = -1;
		gC_teamTime[team]       = "";
		for (int slot = 0; slot < slotCount; slot++)
		{
			gI_racers[team][slot] = 0;
		}
	}
}

public int Native_Relayrace_AddRacer(Handle plugin, int numParams)
{
	int client             = GetNativeCell(1);
	int team               = GetNativeCell(2);
	int slot               = GetNativeCell(3);
	gI_racers[team][slot]  = client;
	gI_teamOfRacer[client] = team;
	gI_slotOfRacer[client] = slot;
	gB_isRacer[client]     = true;
	GOKZ_PrintToChat(client, true, "你注册了 %s%s {default}- %s%s {default}位置", gC_Colors[Color_Purple], gC_Teams[team], gC_Colors[Color_Purple], gC_Slots[slot]);
}

public int Native_Relayrace_SetupRace(Handle plugin, int numParams)
{
	GOKZ_Relayrace_ResetRaceStatus();
	gI_raceStatus = RaceStatus_Waiting;
	int client    = GetNativeCell(1);
	GOKZ_PrintToChatAll(true, "管理员 %s%N {default}发起了比赛!", gC_Colors[Color_Purple], client);
	GOKZ_PrintToChatAll(true, "输入 %s!jr {default}参加比赛", gC_Colors[Color_Green]);
}

public int Native_Relayrace_StartRace(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (GOKZ_Relayrace_GetCurrentRaceStatus() == RaceStatus_Running)
	{
		GOKZ_PrintToChat(client, true, "%s有比赛正在进行中", gC_Colors[Color_DarkRed]);
		return;
	}
	if (GOKZ_Relayrace_GetCurrentRaceStatus() == RaceStatus_End)
	{
		GOKZ_PrintToChat(client, true, "%s请先发起比赛", gC_Colors[Color_DarkRed]);
		return;
	}
	bool canStartRace = GOKZ_Relayrace_CanStartRace();
	// all teams should be full and ready
	if (canStartRace)
	{
		gI_raceStatus = RaceStatus_Running;
		int teamCount = gCV_teamCount.IntValue;
		int slotCount = gCV_slotCount.IntValue;
		for (int team = 0; team < teamCount; team++)
		{
			for (int slot = 0; slot < slotCount; slot++)
			{
				int player = gI_racers[team][slot];
				TeleportPlayerToSectionStart(player);
				GOKZ_Relayrace_FreezePlayer(player);
			}
		}
		StartCountdown(10);
	}
}

public int Native_Relayrace_EndRace(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	GOKZ_PrintToChatAll(true, "%s比赛结束!", gC_Colors[Color_Red]);
	if (IsValidClient(client))
	{
		GOKZ_PrintToChatAll(true, "管理员 %s%N {default}终止了比赛", gC_Colors[Color_Purple], client);
	}
	else
	{
		int teamCount = gCV_teamCount.IntValue;
		for (int team = 0; team < teamCount; team++)
		{
			GOKZ_PrintToChatAll(true, "%s#%d {default}- %s%s {default}- %s%s", gC_Colors[Color_Green], gI_teamRank[team], gC_Colors[Color_Purple], gC_Teams[team], gC_Colors[Color_Green], gC_teamTime[team]);
		}
	}
	GOKZ_Relayrace_ResetRaceStatus();
}

public int Native_Relayrace_IsRacer(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	return gB_isRacer[client];
}

public int Native_Relayrace_CanStartRace(Handle plugin, int numParams)
{
	bool canStartRace = true;
	int teamCount = gCV_teamCount.IntValue;
	for (int team = 0; team < teamCount; team++)
	{
		// check if this team is full and ready
		if (!GOKZ_Relayrace_IsTeamFull(team))
		{
			GOKZ_PrintToChatAll(true, "%s%s%s 人数未满, 请队员注册!", gC_Colors[Color_Purple], gC_Teams[team]);
			canStartRace = false;
			continue;
		}
	}
	return canStartRace;
}

public int Native_Relayrace_CanEndRace(Handle plugin, int numParams)
{
	int teamCount = gCV_teamCount.IntValue;
	for (int team = 0; team < teamCount; team++)
	{
		if (!gB_isTeamFinished[team])
		{
			return false;
		}
	}
	return true;
}

//
public int Native_Relayrace_IsTeamFull(Handle plugin, int numParams)
{
	int team = GetNativeCell(1);
	int slotCount = gCV_slotCount.IntValue;
	for (int slot = 0; slot < slotCount; slot++)
	{
		// if this slot is empty
		if (gI_racers[team][slot] == 0)
		{
			return false;
		}
	}
	return true;
}

public int Native_Relayrace_TeamFinished(Handle plugin, int numParams)
{
	int team                = GetNativeCell(1);
	gB_isTeamFinished[team] = true;
	gI_teamFinishCount++;
	gI_teamRank[team] = gI_teamFinishCount;
	float teamTime    = 0.0;
	int slotCount = gCV_slotCount.IntValue;
	for (int slot = 0; slot < slotCount; slot++)
	{
		teamTime += gF_racerTime[gI_racers[team][slot]];
	}
	char szTime[16];
	// format time by HHMMSS
	FormatTimeHHMMSS(teamTime, szTime, sizeof(szTime), 3);
	gC_teamTime[team] = szTime;
	GOKZ_PrintToChatAll(true, "%s%s {default}完成了比赛! [%s#%d {default}| %s%s{default}]", gC_Colors[Color_Purple], gC_Teams[team], gC_Colors[Color_Green], gI_teamRank[team], gC_Colors[Color_Green], szTime);
}

public int Native_Relayrace_FreezePlayer(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	Movement_SetVelocity(client, view_as<float>({ 0.0, 0.0, 0.0 }));
	Movement_SetMovetype(client, MOVETYPE_NONE);
}

public int Native_Relayrace_FreePlayer(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	Movement_SetMovetype(client, MOVETYPE_WALK);
}
