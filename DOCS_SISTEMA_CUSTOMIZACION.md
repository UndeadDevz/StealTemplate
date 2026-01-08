# Sistema Híbrido de Customización de Coches

## Índice
1. [Introducción](#introducción)
2. [Conceptos Clave](#conceptos-clave)
3. [Tipos de Configuración](#tipos-de-configuración)
4. [Propiedades Modificables](#propiedades-modificables)
5. [Estructura del Modelo](#estructura-del-modelo)
6. [Configuración Práctica](#configuración-práctica)
7. [Ejemplos](#ejemplos)
8. [Ampliación del Sistema](#ampliación-del-sistema)

---

## Introducción

Este sistema permite cambiar la apariencia de los coches de dos formas diferentes según el `EquipType`:

- **Cambios de Texturas/Colores**: Instantáneos, sin recargar el personaje (1-5ms)
- **Cambios de Modelo Completo**: Requieren recargar el personaje (1-2 segundos)

La decisión de cuál usar se hace **automáticamente** según la configuración en `CarConfigs.luau`.

---

## Conceptos Clave

### ¿Qué es un "Texture"?

**IMPORTANTE**: Cuando hablamos de "texturas" en este sistema, nos referimos a **asset IDs de Roblox** que contienen imágenes, NO solo colores.

- `BodyTextureID` = Asset ID de una imagen/textura de Roblox (ej: `"rbxassetid://123456789"`)
- `BodyColor` = Color RGB simple (ej: `Color3.fromRGB(255, 0, 0)`)
- `BodyMaterial` = Material de Roblox (ej: `Enum.Material.Neon`)

El sistema crea objetos `Texture` en los MeshParts y les asigna el `TextureID` que especifiques.

### Type="Texture" vs Type="Model"

| Aspecto | Type="Texture" | Type="Model" |
|---------|---------------|--------------|
| **Velocidad** | Instantáneo (~1-5ms) | Lento (1-2 segundos) |
| **Recarga personaje** | ❌ No | ✅ Sí |
| **Cambia geometría** | ❌ No | ✅ Sí |
| **Cambia colores** | ✅ Sí | ✅ Sí |
| **Cambia texturas** | ✅ Sí | ✅ Sí |
| **Cambia materiales** | ✅ Sí | ✅ Sí |
| **Requiere modelo en ReplicatedStorage** | ❌ No (usa el base) | ✅ Sí |

---

## Tipos de Configuración

### Type="Texture" - Cambios Visuales Instantáneos

```lua
[1] = {
    Type = "Texture",

    -- Carrocería (Body)
    BodyColor = Color3.fromRGB(220, 50, 50),          -- Color rojo
    BodyMaterial = Enum.Material.SmoothPlastic,       -- Material liso
    BodyTextureID = "rbxassetid://123456789",         -- Imagen/textura (OPCIONAL)
    BodyTransparency = 0,                             -- Opacidad (0-1)
    BodyReflectance = 0.2,                            -- Reflejo metálico (0-1)

    -- Neumáticos (Tire)
    TireColor = Color3.fromRGB(30, 30, 30),          -- Negro oscuro
    TireMaterial = Enum.Material.Plastic,
    TireTextureID = "rbxassetid://987654321",        -- Textura de neumático

    -- Rines (Rim)
    RimColor = Color3.fromRGB(180, 180, 180),        -- Plateado
    RimMaterial = Enum.Material.Metal,

    -- Volante (Steering Wheel)
    SteeringWheelColor = Color3.fromRGB(40, 40, 40),
    SteeringWheelMaterial = Enum.Material.Fabric,
}
```

### Type="Model" - Modelo Completamente Diferente

```lua
[2] = {
    Type = "Model",
    ModelName = "CocheMesh2",  -- Debe existir en ReplicatedStorage
}
```

Este tipo:
- Requiere que crees un modelo con nombre diferente en `ReplicatedStorage`
- Puede tener geometría completamente diferente
- Recarga el personaje para aplicar el cambio
- Útil para coches deportivos, camionetas, motos, etc.

---

## Propiedades Modificables

### Propiedades Disponibles

| Propiedad | Tipo | Descripción | Ejemplo |
|-----------|------|-------------|---------|
| `BodyColor` | Color3 | Color de la carrocería | `Color3.fromRGB(255, 0, 0)` |
| `BodyMaterial` | Enum.Material | Material de la carrocería | `Enum.Material.Neon` |
| `BodyTextureID` | string | Asset ID de textura para carrocería | `"rbxassetid://123456"` |
| `BodyTransparency` | number | Transparencia (0=opaco, 1=invisible) | `0.5` |
| `BodyReflectance` | number | Reflejo metálico (0-1) | `0.3` |
| `TireColor` | Color3 | Color de los neumáticos | `Color3.fromRGB(30, 30, 30)` |
| `TireMaterial` | Enum.Material | Material de los neumáticos | `Enum.Material.Plastic` |
| `TireTextureID` | string | Asset ID de textura para neumáticos | `"rbxassetid://789012"` |
| `RimColor` | Color3 | Color de los rines | `Color3.fromRGB(200, 200, 200)` |
| `RimMaterial` | Enum.Material | Material de los rines | `Enum.Material.Metal` |
| `SteeringWheelColor` | Color3 | Color del volante | `Color3.fromRGB(40, 40, 40)` |
| `SteeringWheelMaterial` | Enum.Material | Material del volante | `Enum.Material.Fabric` |

### Materiales Comunes de Roblox

```lua
-- Materiales populares:
Enum.Material.Plastic         -- Plástico básico
Enum.Material.SmoothPlastic   -- Plástico suave (recomendado para carrocería)
Enum.Material.Metal           -- Metálico (bueno para rines)
Enum.Material.Neon            -- Neón brillante (efectos especiales)
Enum.Material.Glass           -- Vidrio (para ventanas)
Enum.Material.Fabric          -- Tela (para interiores/volante)
Enum.Material.Concrete        -- Concreto (texturas ásperas)
Enum.Material.Wood            -- Madera
Enum.Material.DiamondPlate    -- Placa de diamante
```

---

## Estructura del Modelo

### Jerarquía Completa

```
CocheMesh
├── auto [Model]
│   ├── FrontLeftTire [Model]
│   │   ├── Brake [Model]
│   │   │   └── Object_1.002 [MeshPart]
│   │   └── Wheel [Model]
│   │       ├── Tire [Model]
│   │       │   └── Object_11.001 [Model]
│   │       │       └── Object_3.002 [MeshPart] ← Se customiza (TireColor, TireMaterial, TireTextureID)
│   │       └── Rim [Model]
│   │           └── Object_2.002 [MeshPart] ← Se customiza (RimColor, RimMaterial)
│   ├── FrontRightTire [Model] (misma estructura)
│   ├── BackRightTire [Model] (misma estructura)
│   ├── BackLelfTire [Model] (misma estructura - typo en nombre original)
│   ├── Body [Model]
│   │   └── Object_0.004 [MeshPart] ← Se customiza (BodyColor, BodyMaterial, BodyTextureID, etc.)
│   ├── glass [Model]
│   │   └── Object_61.001 [Model]
│   │       └── Object_28.001 [MeshPart] (NO se customiza actualmente - ver ampliación)
│   ├── rightdoor [Model] (NO se customiza actualmente)
│   ├── leftdoor [Model] (NO se customiza actualmente)
│   ├── fly [Model] (alerón/spoiler - NO se customiza actualmente)
│   ├── lightrear [Model] (luces traseras - NO se customiza actualmente)
│   ├── lights [Model] (luces delanteras - NO se customiza actualmente)
│   └── inside [Model] (interior - NO se customiza actualmente)
├── Volante [MeshPart] ← Se customiza (SteeringWheelColor, SteeringWheelMaterial)
└── Conductor [Model] (clonado del personaje del jugador)
```

### Partes Actualmente Personalizables

El sistema actual aplica texturas a:

1. **Body** (Carrocería principal)
   - MeshPart dentro de `auto > Body`
   - Propiedades: `BodyColor`, `BodyMaterial`, `BodyTextureID`, `BodyTransparency`, `BodyReflectance`

2. **Tires** (Neumáticos) - 4 ruedas
   - MeshParts dentro de `auto > [Nombre]Tire > Wheel > Tire`
   - Propiedades: `TireColor`, `TireMaterial`, `TireTextureID`

3. **Rims** (Rines) - 4 ruedas
   - MeshParts dentro de `auto > [Nombre]Tire > Wheel > Rim`
   - Propiedades: `RimColor`, `RimMaterial`

4. **Steering Wheel** (Volante)
   - MeshPart `Volante` (búsqueda recursiva)
   - Propiedades: `SteeringWheelColor`, `SteeringWheelMaterial`

---

## Configuración Práctica

### Archivo: `src/shared/CarConfigs.luau`

Este es el único archivo que necesitas editar para agregar/modificar EquipTypes.

```lua
local CarConfigs: { [number]: CarConfig } = {
    -- EquipType 1: Coche rojo básico (cambio instantáneo)
    [1] = {
        Type = "Texture",
        BodyColor = Color3.fromRGB(220, 50, 50),
        BodyMaterial = Enum.Material.SmoothPlastic,
        TireColor = Color3.fromRGB(30, 30, 30),
        RimColor = Color3.fromRGB(180, 180, 180),
        SteeringWheelColor = Color3.fromRGB(40, 40, 40),
    },

    -- EquipType 2: Modelo completamente diferente (con recarga)
    [2] = {
        Type = "Model",
        ModelName = "CocheMesh2",
    },

    -- EquipType 3: Coche verde brillante (cambio instantáneo)
    [3] = {
        Type = "Texture",
        BodyColor = Color3.fromRGB(50, 220, 50),
        BodyMaterial = Enum.Material.Neon,
        TireColor = Color3.fromRGB(10, 10, 10),
        RimColor = Color3.fromRGB(255, 215, 0),
        SteeringWheelColor = Color3.fromRGB(255, 215, 0),
    },
}
```

### Requisitos de EquipType

- Los números deben coincidir con los `EquipType` de tus zonas en Workspace
- Para `Type = "Model"`, el modelo debe existir en `ReplicatedStorage`
- Para `Type = "Texture"`, no necesitas modelos adicionales

---

## Ejemplos

### Ejemplo 1: Coche con Textura de Imagen

```lua
[4] = {
    Type = "Texture",
    BodyColor = Color3.fromRGB(255, 255, 255),  -- Blanco base
    BodyMaterial = Enum.Material.SmoothPlastic,
    BodyTextureID = "rbxassetid://123456789",  -- Tu textura personalizada
    TireColor = Color3.fromRGB(20, 20, 20),
    RimColor = Color3.fromRGB(255, 0, 0),  -- Rines rojos
}
```

**Cómo obtener un TextureID:**
1. Sube una imagen a Roblox como "Decal" o "Texture"
2. Copia el Asset ID (ejemplo: `123456789`)
3. Úsalo como `"rbxassetid://123456789"`

### Ejemplo 2: Coche Metálico con Reflejos

```lua
[5] = {
    Type = "Texture",
    BodyColor = Color3.fromRGB(50, 100, 255),  -- Azul
    BodyMaterial = Enum.Material.Metal,
    BodyReflectance = 0.5,  -- Muy reflectante
    TireColor = Color3.fromRGB(50, 50, 50),
    RimColor = Color3.fromRGB(200, 200, 255),
    RimMaterial = Enum.Material.DiamondPlate,
}
```

### Ejemplo 3: Coche Transparente/Fantasma

```lua
[6] = {
    Type = "Texture",
    BodyColor = Color3.fromRGB(200, 200, 255),  -- Azul claro
    BodyMaterial = Enum.Material.Glass,
    BodyTransparency = 0.5,  -- 50% transparente
    TireColor = Color3.fromRGB(100, 100, 255),
    TireMaterial = Enum.Material.Neon,
}
```

### Ejemplo 4: Modelo Deportivo Diferente

```lua
[7] = {
    Type = "Model",
    ModelName = "CocheDeportivo",  -- Debe estar en ReplicatedStorage
}
```

Para esto necesitas:
1. Crear/importar un modelo llamado `CocheDeportivo`
2. Colocarlo en `ReplicatedStorage`
3. Asegurarte que tenga la misma estructura básica (auto, Body, ruedas, etc.)

---

## Ampliación del Sistema

### Agregar Más Partes Personalizables

Actualmente el sistema solo modifica Body, Tires, Rims y Volante. Puedes extenderlo fácilmente.

#### 1. Agregar Personalización de Vidrios (Glass)

**En `CarConfigs.luau`, agregar nuevas propiedades:**

```lua
export type TextureConfig = {
    Type: "Texture",
    -- ... propiedades existentes ...

    -- NUEVO: Propiedades de vidrios
    GlassColor: Color3?,
    GlassMaterial: Enum.Material?,
    GlassTransparency: number?,
}
```

**En `CarCustomizationUtils.luau`, agregar sección:**

```lua
-- Después de la sección de volante (línea 180), agregar:

-- ═══════════════════════════════════════════════════════════════════
-- 4. APLICAR A VIDRIOS (GLASS)
-- ═══════════════════════════════════════════════════════════════════
local glassModel = auto:FindFirstChild("glass")
if glassModel then
    for _, child in pairs(glassModel:GetDescendants()) do
        if child:IsA("MeshPart") then
            local props = {}
            if config.GlassColor then
                props.Color = config.GlassColor
            end
            if config.GlassMaterial then
                props.Material = config.GlassMaterial
            end
            if config.GlassTransparency then
                props.Transparency = config.GlassTransparency
            end
            applyProperties(child, props)
        end
    end
end
```

**Uso:**

```lua
[8] = {
    Type = "Texture",
    BodyColor = Color3.fromRGB(0, 0, 0),  -- Negro
    GlassColor = Color3.fromRGB(100, 100, 255),  -- Vidrio azulado
    GlassMaterial = Enum.Material.Glass,
    GlassTransparency = 0.3,  -- Semi-transparente
}
```

#### 2. Agregar Personalización de Luces

Similar al anterior, agregar propiedades para `lightrear` y `lights`:

```lua
-- En tipos:
LightFrontColor: Color3?,
LightFrontMaterial: Enum.Material?,
LightRearColor: Color3?,
LightRearMaterial: Enum.Material?,

-- En utils:
local lightsModel = auto:FindFirstChild("lights")
if lightsModel then
    -- aplicar LightFrontColor, LightFrontMaterial
end

local lightRearModel = auto:FindFirstChild("lightrear")
if lightRearModel then
    -- aplicar LightRearColor, LightRearMaterial
end
```

#### 3. Agregar Personalización de Puertas

```lua
-- En tipos:
DoorColor: Color3?,
DoorMaterial: Enum.Material?,

-- En utils:
local rightDoor = auto:FindFirstChild("rightdoor")
local leftDoor = auto:FindFirstChild("leftdoor")
for _, door in ipairs({rightDoor, leftDoor}) do
    if door then
        for _, child in pairs(door:GetDescendants()) do
            if child:IsA("MeshPart") then
                -- aplicar DoorColor, DoorMaterial
            end
        end
    end
end
```

### Tips para Ampliación

1. **Mantén la consistencia**: Usa el patrón `[Parte]Color`, `[Parte]Material`, `[Parte]TextureID`
2. **Usa búsqueda recursiva**: `GetDescendants()` encuentra todos los MeshParts dentro
3. **Aplica a todos los MeshParts**: Itera sobre todos para asegurar cobertura completa
4. **Propiedades opcionales**: Usa `?` en los tipos para hacerlas opcionales
5. **Manejo de errores**: Usa `pcall()` en `applyProperties()` (ya implementado)

---

## Flujo de Datos

### Caso 1: Cambio de Texturas (EquipType 1 → 3)

```
Usuario toca zona EquipType 3
    ↓
Servidor: EquipmentZones.server.luau
    - Verifica wins suficientes
    - UpdateStat(player, "EquipType", 3)
    - FireAllClients(player, 3)
    ↓
Cliente Local: ChangeCarModel.client.luau
    - Recibe equipType = 3
    - RequiresModelChange(1, 3) = false (ambos Type="Texture")
    - Llama _G.ChangeCarTextures(3)
    ↓
CarSuit.client.luau
    - ApplyTextureConfig() modifica MeshParts directamente
    - ✓ CAMBIO INSTANTÁNEO (1-5ms)
    ↓
Otros Clientes: OtherPlayersCarSuit.client.luau
    - Reciben FireAllClients
    - RequiresModelChange(1, 3) = false
    - ApplyTextureConfig() en coche existente
    - ✓ CAMBIO INSTANTÁNEO
```

### Caso 2: Cambio de Modelo (EquipType 1 → 2)

```
Usuario toca zona EquipType 2
    ↓
Servidor: EquipmentZones.server.luau
    - Verifica wins suficientes
    - UpdateStat(player, "EquipType", 2)
    - FireAllClients(player, 2)
    ↓
Cliente Local: ChangeCarModel.client.luau
    - Recibe equipType = 2
    - RequiresModelChange(1, 2) = true (1=Texture, 2=Model)
    - Guarda posición en _G.RespawnPosition
    - Guarda equipType en _G.CurrentCarEquipType
    - player:LoadCharacter() → RECARGA (1-2s)
    ↓
CarSuit.client.luau (se ejecuta de nuevo)
    - Lee _G.CurrentCarEquipType = 2
    - GetModelName(2) = "CocheMesh2"
    - Clona "CocheMesh2"
    - Teleporta a _G.RespawnPosition
    - ✓ MODELO NUEVO CARGADO
    ↓
Otros Clientes: OtherPlayersCarSuit.client.luau
    - RequiresModelChange(1, 2) = true
    - Destruye coche viejo
    - Crea coche nuevo con "CocheMesh2"
    - ✓ SINCRONIZADO
```

---

## Preguntas Frecuentes

### ¿Puedo mezclar Type="Texture" y Type="Model"?

Sí, completamente. Ejemplo:

```lua
[1] = { Type = "Texture", BodyColor = ... },  -- Rojo instantáneo
[2] = { Type = "Model", ModelName = "CocheMesh2" },  -- Deportivo con recarga
[3] = { Type = "Texture", BodyColor = ... },  -- Azul instantáneo
[4] = { Type = "Model", ModelName = "Camioneta" },  -- Camioneta con recarga
```

### ¿Qué pasa si cambio de EquipType 1 (Texture) → 2 (Model) → 3 (Texture)?

- 1 → 2: Recarga personaje (porque cambia a Model)
- 2 → 3: Recarga personaje (porque cambia de Model a Texture)

### ¿Qué pasa si cambio entre dos EquipTypes Type="Model"?

Siempre recarga si los `ModelName` son diferentes. Si son el mismo nombre, no recarga (ya lo tiene).

### ¿Cómo subo texturas a Roblox?

1. Ve a [https://create.roblox.com/dashboard/creations](https://create.roblox.com/dashboard/creations)
2. Click en "Decals" o "Images"
3. Sube tu imagen (PNG/JPG recomendado)
4. Espera aprobación de moderación de Roblox
5. Copia el Asset ID
6. Úsalo como `"rbxassetid://TU_ID"`

### ¿El sistema funciona en multiplayer?

Sí, completamente sincronizado:
- Cuando un jugador cambia EquipType, todos los clientes lo ven
- Los cambios instantáneos son instantáneos para todos
- Los cambios de modelo recrean el coche en todos los clientes

---

## Archivos del Sistema

| Archivo | Propósito | Tipo |
|---------|-----------|------|
| `src/shared/CarConfigs.luau` | **Configuración principal** - Edita aquí | Shared Module |
| `src/shared/CarCustomizationUtils.luau` | Funciones utilitarias (no tocar) | Shared Module |
| `src/server/Systems/EquipmentZones.server.luau` | Maneja zonas de equipamiento | Server Script |
| `src/character/CarSuit.client.luau` | Crea coche del jugador local | LocalScript |
| `src/character/ChangeCarModel.client.luau` | Decide híbrido para jugador local | LocalScript |
| `src/client/OtherPlayersCarSuit.client.luau` | Renderiza coches de otros jugadores | LocalScript |

**Solo necesitas editar: `CarConfigs.luau`** ✅

---

## Resumen

✅ **Type="Texture"**: Cambios instantáneos (colores, materiales, texturas de imagen)
✅ **Type="Model"**: Modelos completamente diferentes (con recarga)
✅ **TextureID**: Asset IDs de imágenes de Roblox (`rbxassetid://...`)
✅ **Sincronizado**: Funciona en multiplayer automáticamente
✅ **Ampliable**: Puedes agregar más partes fácilmente

Para agregar un nuevo EquipType, simplemente edita `CarConfigs.luau` y el sistema hace el resto. 🚗💨
