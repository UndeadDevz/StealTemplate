# 🎉 Sistema de Efectos de Nivel

Sistema completo de efectos visuales cuando un jugador sube de nivel, visible para **todos los jugadores** en el servidor.

## 📋 Archivos Creados

### Servidor

- `src/server/Data/RemoteEventsInit.server.luau` - Crea el RemoteEvent
- `src/server/Data/DataManager.luau` - Modificado para disparar el evento

### Cliente

- `src/client/LevelUpEffect.client.luau` - Muestra las partículas

### Utilidades

- `ConfigurarEfectosNivel.luau` - Script de configuración rápida

## 🚀 Configuración en Roblox Studio

### Paso 1: Ejecutar Script de Configuración

1. Abre tu juego en Roblox Studio
2. Abre el Command Bar (View > Command Bar)
3. Abre el archivo `ConfigurarEfectosNivel.luau`
4. Copia **TODO** el contenido
5. Pega en el Command Bar y presiona Enter

Esto creará automáticamente:

- `ReplicatedStorage/Effects/` (carpeta)
- `ReplicatedStorage/Effects/LevelUpEffect` (Part con 5 partículas)

### Paso 2: Personalizar las Partículas (Opcional)

Ve a `ReplicatedStorage > Effects > LevelUpEffect` y personaliza:

**Partículas del Attachment:**

- `Particle1`, `Particle2`, `Particle3`, `Particle4`
- Están dentro del Attachment "ParticleAttachment"
- Puedes cambiar: color, tamaño, velocidad, textura, etc.

**Partícula Extra:**

- `ParticleExtra`
- Está directamente en LevelUpEffect
- Representa el efecto central o adicional

### Paso 3: Sincronizar con Rojo

Después de configurar en Studio:

```bash
rojo build -o StealTemplate.rbxl
```

## 🎮 Cómo Funciona

### Flujo del Sistema

1. **Servidor detecta nivel**: El jugador gana EXP y sube de nivel
2. **Servidor dispara evento**: `EfectoLvlUp:FireAllClients(character, newLevel)`
3. **Todos los clientes reciben**: Cada jugador ve el efecto
4. **Cliente muestra partículas**: Se clonan y emiten las 5 partículas
5. **Auto-limpieza**: El efecto se elimina después de 3 segundos

### Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                    SERVIDOR (DataManager)                   │
│  Jugador sube de nivel → FireAllClients(character, level)   │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           │ RemoteEvent: EfectoLvlUp
                           │
              ┌────────────┴────────────┐
              │                         │
              ▼                         ▼
    ┌─────────────────┐       ┌─────────────────┐
    │   Cliente 1     │       │   Cliente 2     │
    │ (Ve el efecto)  │       │ (Ve el efecto)  │
    └─────────────────┘       └─────────────────┘
```

## ⚙️ Configuración de Partículas

### Propiedades Recomendadas

```lua
-- Partículas brillantes (estrellas)
Texture = "rbxasset://textures/particles/sparkles_main.dds"
Color = Color3.fromRGB(255, 255, 0) -- Amarillo
LightEmission = 1 -- Brilla completamente
Size = NumberSequence.new(0.5)
Speed = NumberRange.new(5, 10)
Lifetime = NumberRange.new(1, 2)

-- Partícula de fuego (efecto central)
Texture = "rbxasset://textures/particles/fire_main.dds"
Color = Color3.fromRGB(255, 200, 50) -- Naranja
LightEmission = 0.8
Size = NumberSequence.new(1)
Speed = NumberRange.new(3, 6)
Lifetime = NumberRange.new(0.5, 1)
```

### Texturas Disponibles

- `sparkles_main.dds` - Brillos/estrellas
- `fire_main.dds` - Fuego
- `smoke_main.dds` - Humo
- `explosion.dds` - Explosión
- Asset IDs personalizados

## 🔧 Solución de Problemas

### Las partículas no aparecen

1. Verifica que `ReplicatedStorage/Effects/LevelUpEffect` existe
2. Asegúrate de que tiene partículas como hijos
3. Revisa la consola del cliente para errores

### Solo yo veo el efecto

- Esto es normal, el sistema usa `FireAllClients`
- Para probarlo, únete con 2 ventanas o con un amigo

### El efecto no se mueve con el personaje

- Verifica que el `WeldConstraint` se creó correctamente
- El script automáticamente ancla el efecto al HumanoidRootPart

### Múltiples niveles a la vez

- Si subes varios niveles rápidamente, verás varios efectos
- Cada subida de nivel dispara su propio efecto

## 🎨 Personalización Avanzada

### Cambiar número de partículas emitidas

En `LevelUpEffect.client.luau`:

```lua
particula:Emit(30) -- Cambia 30 al número que desees
```

### Cambiar duración del efecto

```lua
Debris:AddItem(clon, 3) -- Cambia 3 a los segundos que desees
```

### Agregar sonido

Agrega un Sound al LevelUpEffect y modifica el cliente:

```lua
local sound = clon:FindFirstChild("LevelUpSound")
if sound then
    sound:Play()
end
```

## 📊 Integración con el Sistema

El sistema se integra automáticamente con:

- ✅ `DataManager.CheckLevelUp()` - Detecta subidas de nivel
- ✅ `ExpTraining.server.luau` - Sistema de entrenamiento
- ✅ `RebirthSystem.server.luau` - Sistema de renacimiento
- ✅ Barras de progreso del cliente (tus LocalScripts)

## 🔄 Actualización del default.project.json

Asegúrate de que tu configuración de Rojo incluya:

```json
{
  "$className": "DataModel",
  "ReplicatedStorage": {
    "$path": "src/shared",
    "RemoteEvents": {
      "$className": "Folder"
    },
    "Effects": {
      "$className": "Folder"
    }
  },
  "StarterPlayer": {
    "StarterPlayerScripts": {
      "$path": "src/client"
    }
  }
}
```

---

**¡Todo listo!** 🎊 Ahora cuando un jugador suba de nivel, todos verán el efecto visual.
