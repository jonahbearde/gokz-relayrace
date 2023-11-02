#define Countdown_SOUND_START 7

Handle gH_CountdownSynchronizer;     // 倒计时HUD
float  gF_RaceStartCountdownTime;    // 比赛开始倒计时的时间戳
int    gI_Countdown;                 // 比赛倒计时时长

bool gB_SoundPlayed[Countdown_SOUND_START];

void OnPluginStart_Countdown()
{
	gH_CountdownSynchronizer = CreateHudSynchronizer();
}

void StartCountdown(int Countdown)
{
	ResetCountdown();
	gF_RaceStartCountdownTime = GetGameTime();
	gI_Countdown              = Countdown;
	CreateTimer(0.1, Task_Countdown, 0, TIMER_REPEAT);
}

void ResetCountdown()
{
	gF_RaceStartCountdownTime = 0.0;
	gI_Countdown              = 0;
	for (int i = 0; i < Countdown_SOUND_START; i++)
	{
		gB_SoundPlayed[i] = false;
	}
}

float GetCountdownRemain()
{
	return gI_Countdown > 0 ? gI_Countdown - (GetGameTime() - gF_RaceStartCountdownTime) : 0.0;
}

void ShowCountdown(int client, int Countdown)
{
	// 显示倒计时HUD
	SetHudTextParams(-1.0, 0.4, 1.0, Clamp(Countdown * 15, 0, 255), Clamp(255 - Countdown * 15, 0, 255), 30, 0, 0, 0.0, 0.0, 0.0);
	if (Countdown == 0)
	{
		ShowSyncHudText(client, gH_CountdownSynchronizer, "比赛开始!");
	}
	else
	{
		ShowSyncHudText(client, gH_CountdownSynchronizer, "%d", Countdown);
	}
}

void PlayCountdownSound(int client, int Countdown)
{
	if (Countdown == Countdown_SOUND_START - 1)
	{
		EmitSoundToClientAny(client, gC_CountdownReadySound);
	}
	else if (Countdown == 0)
	{
		// TODO: test multiplayer
		if (gI_slotOfRacer[client] == 0)
		{
			EmitSoundToClientAny(client, gC_OnFreePlayerSound);
		}
		else
		{
			EmitSoundToClientAny(client, gC_CountdownZeroSound);			
		}
	}
	else
	{
		EmitSoundToClientAny(client, gC_CountdownSound);
	}
}

// 倒计时定时任务
public Action:Task_Countdown(Handle timer)
{
	// 比赛取消则取消倒计时
	if (GOKZ_Relayrace_GetCurrentRaceStatus() != RaceStatus_Running || GetCountdownRemain() <= 0.0)
	{
		ResetCountdown();
		// 结束倒计时
		return Plugin_Stop;
	}

	int  Countdown = RoundToFloor(GetCountdownRemain());
	bool playSound = false;
	if (Countdown < Countdown_SOUND_START && !gB_SoundPlayed[Countdown])
	{
		playSound                 = true;
		gB_SoundPlayed[Countdown] = true;
	}
	// 遍历玩家
	for (int client = 1; client < MAXCLIENTS; client++)
	{
		if (IsValidClient(client))
		{
			// only racers and those who spectate them will see countdown
			if (GOKZ_Relayrace_IsRacer(client) || (IsClientObserver(client) && GetObserverTarget(client) != -1 && GOKZ_Relayrace_IsRacer(GetObserverTarget(client))))
			{
				ShowCountdown(client, Countdown);

				if (playSound)
				{
					PlayCountdownSound(client, Countdown);
				}
				if (Countdown == 0)
				{
					// free players previously freezed at the start of first section
					int teamCount = gCV_teamCount.IntValue;
					for (int team = 0; team < teamCount; team++)
					{
						GOKZ_Relayrace_FreePlayer(gI_racers[team][0]);
					}
				}
			}
		}
	}

	// 继续倒计时
	return Plugin_Continue;
}
