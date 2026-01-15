return {
	EXP = 0,
	Level = 1,
	Rebirths = 0,
	Wins = 0,
	EquipType = 1, -- Carsuit visual equipado (solo visual, no afecta EXP)
	ExpBase = 1, -- Valor de EXP ganada por tick (comprable con Wins)
	ExpBaseLevel = 1, -- Nivel actual de ExpBase (1-8)
	UnlockedCarsuits = {1}, -- Lista de carsuits desbloqueados
	Multiplier = 1,
	CustomSpeed = 0, -- 0 significa "usar máximo", cualquier otro valor es la velocidad personalizada
	TotalEXP = 0, -- EXP acumulada total (nunca se resta)
	GroupRewardClaimed = false, -- true si ya reclamó la recompensa por unirse al grupo

	-- Potions
	SpeedPotionCount = 0,
	WinsPotionCount = 0,
	SpeedPotionEndTime = 0,
	WinsPotionEndTime = 0,

	-- Configuraciones de UI (guardadas persistentemente)
	Settings = {
		Sound = 1, -- Volumen de sonido (0-1)
		Music = 1, -- Volumen de música (0-1)
		OtherPlayersVolume = 0.65, -- Volumen de otros jugadores (0-1)
		UIScale = "Auto", -- Modo de escala: "Auto", "Mobile", "Desktop"
		ThemeColor = "Cyan", -- Color del tema
		FontName = "GothamBlack", -- Nombre de la fuente
		FontWeight = "Black", -- Peso de la fuente
	}
}
