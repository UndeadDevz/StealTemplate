local Players = game:GetService("Players")
local DataManager = require(game:GetService("ServerScriptService").Server.Data.DataManager)

-- CONFIGURACIÓN
local REWARD_EXP = 10000

local function OnPlayerAdded(newPlayer)
    -- Obtenemos los datos de cómo entró el jugador
    local joinData = newPlayer:GetJoinData()
    
    -- "ReferredByPlayerId" es la magia nueva.
    -- Si es 0 o nil, nadie lo invitó específicamente con este sistema.
    local referrerId = joinData.ReferredByPlayerId
    
    if referrerId and referrerId > 0 then
        print(newPlayer.Name .. " entró gracias a la invitación de ID: " .. referrerId)
        
        -- Buscamos al jugador que invitó (puede estar offline o en otro server)
        -- NOTA: Para dar EXP, idealmente el jugador debe estar conectado, 
        -- o tendrías que usar DataStore directo si está offline.
        -- Para simplificar, aquí asumimos que queremos premiarlo si está en el juego:
        
        local referrerPlayer = Players:GetPlayerByUserId(referrerId)
        
        if referrerPlayer then
            local profile = DataManager:Get(referrerPlayer)
            
            if profile then
                -- Verificamos si ya cobró por este amigo (igual que antes, para evitar spam)
                local friendIdKey = tostring(newPlayer.UserId)
                
                if not profile.Data.RedeemedFriends[friendIdKey] then
                    -- 1. Dar Recompensa
                    profile.Data.TotalEXP += REWARD_EXP
                    
                    -- 2. Marcar como cobrado
                    profile.Data.RedeemedFriends[friendIdKey] = true
                    
                    -- 3. Feedback
                    print("¡Premio entregado a " .. referrerPlayer.Name .. "!")
                    -- Aquí podrías mandar un RemoteEvent para mostrar un UI de celebración
                else
                    warn("El jugador ya había cobrado recompensa por este amigo.")
                end
            end
        else
            -- Si el invitador NO está en el servidor, aquí es donde usarías
            -- un DataStore separado o MessagingService para avisarle, 
            -- pero eso es más avanzado. Por ahora, si no está, se pierde el bono inmediato.
            warn("El invitador no está en este servidor para recibir su premio.")
        end
    end
end

Players.PlayerAdded:Connect(OnPlayerAdded)