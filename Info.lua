g_PluginInfo = {
	Name = "iControlU",
	Version = "1",
	Date = "2017-11-27",
	SourceLocation = "https://github.com/mathiascode/iControlU",
	Description = [[Plugin for Cuberite that allows players to control the movements, inventory and chat of other players.]],

	Commands =
	{
		["/icu"] =
		{
			HelpString = "Control another player's movements, inventory and chat",
			Permission = "icu.command",
			Subcommands =
			{
				control =
				{
					Alias = "c",
					Permission = "icu.control",
					Handler = HandleControlCommand,
					HelpString = "Start controlling a player"
				},
				stop =
				{
					Alias = "s",
					Permission = "icu.stop",
					Handler = HandleStopCommand,
					HelpString = "Stop controlling a player"
				},
			},
		},
	},
	Permissions =
	{
		["icu.exempt"] =
		{
			Description = "Players with this permission cannot be controlled",
			RecommendedGroups = "players",
		},
	},
}
