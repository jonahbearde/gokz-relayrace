int gI_tempTeam[MAXCLIENTS];

void OnPluginStart_Menus()
{
	for (int client = 0; client < MAXCLIENTS; client++)
	{
		gI_tempTeam[client] = -1;
	}
}

void Showmenu_JoinRace(int client)
{
	Menu menu       = new Menu(Menu_JoinRace);
	menu.Pagination = MENU_NO_PAGINATION;
	menu.SetTitle("Join Race");
	menu.AddItem("0", "Join Team");
	// TODO: client index -3?
	menu.AddItem("1", "Quit Team", GOKZ_Relayrace_IsRacer(client) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED);
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

void Showmenu_SelectTeam(int client)
{
	Menu menu       = new Menu(Menu_JoinTeam);
	menu.Pagination = MENU_NO_PAGINATION;
	menu.SetTitle("Join a team");
	int teamCount = gCV_teamCount.IntValue;
	for (int team = 0; team < teamCount; team++)
	{
		char szTeam[16];
		IntToString(team, szTeam, sizeof(szTeam));
		menu.AddItem(szTeam, gC_Teams[team]);
	}
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

void Showmenu_SelectSlot(int client)
{
	Menu menu       = new Menu(Menu_JoinSlot);
	menu.Pagination = MENU_NO_PAGINATION;
	menu.SetTitle("Select a stage");
	int slotCount = gCV_slotCount.IntValue;
	for (int slot = 0; slot < slotCount; slot++)
	{
		char szSlot[16];
		IntToString(slot, szSlot, sizeof(szSlot));
		menu.AddItem(szSlot, gC_Slots[slot]);
	}
	menu.ExitButton = true;
	menu.Display(client, MENU_TIME_FOREVER);
}

public int Menu_JoinSlot(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char szInfo[16];
			menu.GetItem(param2, szInfo, sizeof(szInfo));
			int tempSlot = StringToInt(szInfo);
			int tempTeam = gI_tempTeam[param1];
			if (gI_racers[tempTeam][tempSlot] > 0 && gI_racers[tempTeam][tempSlot] != param1)
			{
				// TODO: test multiplayer
				GOKZ_PrintToChat(param1, true, "%s该位置已被注册, 请选择其他位置", gC_Colors[Color_DarkRed]);
				GOKZ_PlayErrorSound(param1);
			}
			else
			{
				GOKZ_Relayrace_AddRacer(param1, tempTeam, tempSlot);
			}
		}
		case MenuAction_End:
		{
			delete menu;
			Showmenu_SelectTeam(param1);
		}
	}
}

public int Menu_JoinTeam(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char szInfo[16];
			menu.GetItem(param2, szInfo, sizeof(szInfo));
			int team            = StringToInt(szInfo);
			gI_tempTeam[param1] = team;
			Showmenu_SelectSlot(param1);
		}
		case MenuAction_End:
		{
			delete menu;
			Showmenu_JoinRace(param1);
		}
	}
}

public int Menu_JoinRace(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			// get information string
			char szInfo[16];
			menu.GetItem(param2, szInfo, sizeof(szInfo));
			int iInfo = StringToInt(szInfo);
			switch (iInfo)
			{
				// Join a team
				case 0:
				{
					Showmenu_SelectTeam(param1);
				}
				// Quit team
				case 1:
				{
					int team               = gI_teamOfRacer[param1];
					int slot               = gI_slotOfRacer[param1];
					gB_isRacer[param1]     = false;
					gI_racers[team][slot]  = 0;
					gI_teamOfRacer[param1] = -1;
					gI_slotOfRacer[param1] = -1;
				}
			}
		}
		case MenuAction_End:
		{
			delete menu;
		}
	}
}
