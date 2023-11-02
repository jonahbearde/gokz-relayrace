static Regex RE_SectionStartZone;
static Regex RE_SectionEndZone;
static Regex RE_SectionStartTeleport;
// static float lastStartSoundTime[MAXPLAYERS + 1];
static float startOrigins[8][3];
static float startAngles[8][3];

// compile regex
void OnPluginStart_Sections()
{
	RE_SectionStartZone     = CompileRegex(GOKZ_RELAYRACE_SECTION_START_REGEX);
	RE_SectionEndZone       = CompileRegex(GOKZ_RELAYRACE_SECTION_END_REGEX);
	RE_SectionStartTeleport = CompileRegex(GOKZ_RELAYRACE_SECTION_START_TELEPORT_REGEX);
}

void OnEntitySpawned_SectionZones(int entity)
{
	char buffer[32];
	GetEntityClassname(entity, buffer, sizeof(buffer));
	// if the entity is not a trigger_multiple
	if (!StrEqual("trigger_multiple", buffer, false))
	{
		return;
	}
	// if the entity has no name
	if (GetEntityName(entity, buffer, sizeof(buffer)) == 0)
	{
		return;
	}

	int section = -1;
	if ((section = GetSectionStartZoneSectionNumber(entity)) != -1)
	{
		// found a section startzone and hook events
		HookSingleEntityOutput(entity, "OnEndTouch", OnSectionStartZoneEndTouch);
	}
	else if ((section = GetSectionEndZoneSectionNumber(entity)) != -1)
	{
		// found a section endzone
		HookSingleEntityOutput(entity, "OnStartTouch", OnSectionEndZoneStartTouch);
	}
}

public void OnSectionStartZoneEndTouch(const char[] output, int caller, int activator, float delay)
{
	if (!IsValidEntity(caller) || !IsValidClient(activator))
	{
		return;
	}
	if (GOKZ_Relayrace_GetCurrentRaceStatus() == RaceStatus_Running)
	{
		// start timer
		gF_racerStartTime[activator] = GetGameTime();
		EmitSoundToClient(activator, gC_ModeStartSounds[GOKZ_GetCoreOption(activator, Option_Mode)]);
		EmitSoundToClientSpectators(activator, gC_ModeStartSounds[GOKZ_GetCoreOption(activator, Option_Mode)]);
	}
}

public void OnSectionEndZoneStartTouch(const char[] output, int caller, int activator, float delay)
{
	if (!IsValidEntity(caller) || !IsValidClient(activator))
	{
		return;
	}
	// end the timer only if start zone has been touched
	if (gF_racerStartTime[activator] > 0.0)
	{
		EmitSoundToClient(activator, gC_ModeEndSounds[GOKZ_GetCoreOption(activator, Option_Mode)]);
		EmitSoundToClientSpectators(activator, gC_ModeEndSounds[GOKZ_GetCoreOption(activator, Option_Mode)]);
		gF_racerEndTime[activator] = GetGameTime();
		OnTimerEnd(activator);
		int team = gI_teamOfRacer[activator];
		int slot = gI_slotOfRacer[activator];
		int slotCount = gCV_slotCount.IntValue;
		if (slot < (slotCount - 1))
		{
			int nextPlayer = gI_racers[team][slot + 1];
			// TODO: test multiplayer
			Movement_SetMovetype(nextPlayer, MOVETYPE_WALK);
			OnFreePlayer(nextPlayer);
			// TODO: move the observer camera onto the next player

		}
		// if this is the last player running and team is not finished
		if (slot == (slotCount - 1) && !gB_isTeamFinished[team])
		{
			GOKZ_Relayrace_TeamFinished(team);
			bool canEndRace = GOKZ_Relayrace_CanEndRace();
			if (canEndRace)
			{
				// natural end
				GOKZ_Relayrace_EndRace(-1);
			}
		}
	}
}

static int GetSectionStartZoneSectionNumber(int entity)
{
	return MatchIntFromEntityName(entity, RE_SectionStartZone, 1);
}

static int GetSectionEndZoneSectionNumber(int entity)
{
	return MatchIntFromEntityName(entity, RE_SectionEndZone, 1);
}

void ResetTimer(int client)
{
	gF_racerStartTime[client] = 0.0;
	gF_racerEndTime[client]   = 0.0;
}

void OnTimerEnd(int client)
{
	// calculate section run time
	gF_racerTime[client] = gF_racerEndTime[client] - gF_racerStartTime[client];
	char szTime[16];
	// format time by HHMMSS
	FormatTimeHHMMSS(gF_racerTime[client], szTime, sizeof(szTime), 3);
	GOKZ_PrintToChatAll(true, "%s%s {default}的选手 %s%N {default}完成了 %s%s {default}, 用时 %s%s", gC_Colors[Color_Purple], gC_Teams[gI_teamOfRacer[client]], gC_Colors[Color_Yellow], client, gC_Colors[Color_Purple], gC_Slots[gI_slotOfRacer[client]], gC_Colors[Color_Green], szTime);
	ResetTimer(client);
}

// search teleport destinations and stuff
void OnEntitySpawned_SectionTeleports(int entity)
{
	char buffer[32];
	GetEntityClassname(entity, buffer, sizeof(buffer));
	// if the entity is not an info_teleport_destination
	if (!StrEqual("info_teleport_destination", buffer, false))
	{
		return;
	}
	// if the entity has no name
	if (GetEntityName(entity, buffer, sizeof(buffer)) == 0)
	{
		return;
	}
	// get section number from its name
	int sectionNum = GetSectionStartTeleportSectionNumber(entity);
	if (sectionNum != -1)
	{
		// store origin and angles
		GetEntityAbsOrigin(entity, startOrigins[sectionNum - 1]);
		GetEntPropVector(entity, Prop_Data, "m_angAbsRotation", startAngles[sectionNum - 1]);
	}
}

void TeleportPlayerToSectionStart(int client)
{
	int section = gI_slotOfRacer[client];
	TeleportPlayer(client, startOrigins[section], startAngles[section]);
}

static int GetSectionStartTeleportSectionNumber(int entity)
{
	return MatchIntFromEntityName(entity, RE_SectionStartTeleport, 1);
}

static int MatchIntFromEntityName(int entity, Regex re, int substringID)
{
	int  num = -1;
	char buffer[32];
	GetEntityName(entity, buffer, sizeof(buffer));

	if (re.Match(buffer) > 0)
	{
		re.GetSubString(substringID, buffer, sizeof(buffer));
		num = StringToInt(buffer);
	}

	return num;
}

void OnFreePlayer(client)
{
	SetHudTextParams(-1.0, 0.4, 2.0, 0, 255, 0, 0, 0, 0.0, 0.0, 0.0);
	ShowHudText(client, 1, "Go! Go! Go!");
	EmitSoundToClientAny(client, gC_OnFreePlayerSound);
}