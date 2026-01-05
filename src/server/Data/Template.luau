return {
	EXP = 0,
	Level = 1,
	Rebirths = 0,
	Wins = 0,
	EquipType = 1,
	Multiplier = 1,
	CustomSpeed = 0, -- 0 significa "usar máximo", cualquier otro valor es la velocidad personalizada
	TotalEXP = 0, -- EXP acumulada total (nunca se resta)
	Tracks = {}, -- Pistas desbloqueadas

	-- Configuraciones de UI (guardadas persistentemente)
	Settings = {
		Sound = 1, -- Volumen de sonido (0-1)
		Music = 1, -- Volumen de música (0-1)
		UIScale = "Auto", -- Modo de escala: "Auto", "Mobile", "Desktop"
		ThemeColor = "Cyan", -- Color del tema
		FontName = "GothamBlack", -- Nombre de la fuente
		FontWeight = "Black", -- Peso de la fuente
	}
}
