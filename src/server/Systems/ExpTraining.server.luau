--[[
	═══════════════════════════════════════════════════════════════════════
	INSTRUCCIONES DE CONFIGURACIÓN DEL WORKSPACE
	═══════════════════════════════════════════════════════════════════════
	
	Para que este sistema funcione correctamente, necesitas configurar las
	zonas de entrenamiento en el Workspace de Roblox Studio:
	
	1. CREAR CARPETA DE ZONAS:
	   - En Workspace, crea una carpeta llamada "ZonasEXP"
	
	2. CREAR ZONAS DE ENTRENAMIENTO:
	   - Dentro de "ZonasEXP", crea Parts (partes) con estas propiedades:
	     * Transparency = 1 (para que sean invisibles)
	     * CanCollide = false (para que los jugadores puedan atravesarlas)
	     * Anchored = true (para que no caigan)
	     * Size = Ajusta el tamaño según el área que quieras cubrir
	   
	3. CONFIGURAR ATRIBUTOS DE EXP:
	   - A cada Part, agrégale un Attribute (Atributo) numérico:
	     * Nombre del atributo: "ExpBase"
	     * Tipo: Number
	     * Valor: La cantidad de EXP base que otorga por segundo
	   
	   Ejemplos de valores sugeridos:
	     - Zona Principiante: ExpBase = 10
	     - Zona Intermedia: ExpBase = 25
	     - Zona Avanzada: ExpBase = 50
	     - Zona Experta: ExpBase = 100
	   
	4. POSICIONAR LAS ZONAS:
	   - Coloca las zonas en diferentes áreas del mapa
	   - Las zonas con más ExpBase deberían estar más lejos del spawn
	   
	EJEMPLO DE ESTRUCTURA EN WORKSPACE:
	Workspace
	├── Baseplate
	└── ZonasEXP
	    ├── ZonaPrincipiante (Part con ExpBase = 10)
	    ├── ZonaIntermedia (Part con ExpBase = 25)
	    ├── ZonaAvanzada (Part con ExpBase = 50)
	    └── ZonaExperta (Part con ExpBase = 100)
	
	═══════════════════════════════════════════════════════════════════════
]]

-- Services
local Players = game:GetService("Players")

-- Modules
local DataManager = require(script.Parent.Parent.Data.DataManager)

-- Loop principal de entrenamiento
while true do
	task.wait(1) -- Pulso de entrenamiento cada segundo
	
	-- Verificar si existe la carpeta ZonasEXP
	local zonasEXP = workspace:FindFirstChild("ZonasEXP")
	if not zonasEXP then
		warn("[ExpTraining] ⚠️ No se encontró la carpeta 'ZonasEXP' en Workspace. Por favor créala siguiendo las instrucciones del script.")
		task.wait(10) -- Esperar 10 segundos antes de volver a intentar
		continue
	end
	
	-- Iterar por cada zona de entrenamiento
	for _, zona in pairs(zonasEXP:GetChildren()) do
		if not zona:IsA("BasePart") then continue end
		
		-- Obtener partes dentro de la zona
		local parts = workspace:GetPartsInPart(zona)
		local procesados = {}

		for _, part in pairs(parts) do
			-- Verificar si la parte pertenece a un personaje de jugador
			local player = Players:GetPlayerFromCharacter(part.Parent)
			if player and not procesados[player.Name] then
				procesados[player.Name] = true
				
				local stats = player:FindFirstChild("leaderstats")
				if stats then
					local level = stats:FindFirstChild("Level")
					local rebirths = stats:FindFirstChild("Rebirths")
					
					if level and rebirths then
						-- Calcular nivel máximo según rebirths
						local maxLevel = 20 + (rebirths.Value * 10)
						
						-- Solo otorgar EXP si no ha alcanzado el nivel máximo
						if level.Value < maxLevel then
							-- Calcular multiplicador por Rebirth
							local multRebirth = rebirths.Value + 1
							
							-- Calcular EXP ganada
							local expBase = zona:GetAttribute("ExpBase") or 10
							local expGanada = expBase * multRebirth
							
							-- Otorgar EXP
							DataManager.AddStat(player, "EXP", expGanada)
							
							-- Verificar si puede subir de nivel (puede subir múltiples niveles)
							local _levelsGained = DataManager.CheckLevelUp(player)
							
							-- En el futuro aquí se pueden ejecutar animaciones de level up
							-- basadas en la cantidad de niveles ganados (_levelsGained)
						end
					end
				end
			end
		end
	end
end
