# Progression System Guide

## Overview

This document explains the complete progression system implemented in the game, including formulas, breakpoints, and expected player experience.

---

## 1. EXP Requirements (Sistema de 3 Fases)

### Fórmulas por Fase

El juego utiliza **tres fases distintas** de progresión:

#### **FASE 1: Tutorial (Niveles 0-25) - Crecimiento LINEAL**
```lua
EXP_Required = 51 + (Level × 13)
```
- **Sensación:** Muy fluida, enganche inicial
- **Incremento:** ~13 puntos por nivel
- **Propósito:** Aprender mecánicas sin frustración

#### **FASE 2: Transición (Niveles 26-75) - Crecimiento EXPONENCIAL SUAVE**

**Fase 2A (26-50):** Ratio 1.05
```lua
EXP_Required = 373 × (1.05 ^ (Level - 25))
```

**Fase 2B (51-75):** Ratio 1.10
```lua
EXP_Required = 2,120 × (1.10 ^ (Level - 50))
```
- **Sensación:** La curva empieza a empinarse
- **Propósito:** Transición gradual al grind

#### **FASE 3: Muro Exponencial (Niveles 76+) - Ratio 1.15**
```lua
EXP_Required = 35,650 × (1.15 ^ (Level - 75))
```
- **Sensación:** Cada 5 niveles la EXP se DUPLICA
- **Nivel 100:** 1.17M EXP
- **Nivel 105:** 2.36M EXP ⭐
- **Hard cap:** Nivel 375

### Key Breakpoints (Sistema de 3 Fases)

| Nivel | Fase | EXP Requerida | Incremento vs Anterior | Notas |
| ----- | ---- | ------------- | ---------------------- | ----- |
| **FASE 1: Tutorial (Lineal)** |||||
| 0     | 1    | 51            | Base                   | Inicio del juego |
| 5     | 1    | 116           | +13/nivel              | Early tutorial |
| 10    | 1    | 181           | +13/nivel              | Mid tutorial |
| 20    | 1    | 311           | +13/nivel              | Late tutorial |
| 25    | 1    | 376           | +13/nivel              | 🔄 **1er Rebirth** |
| **FASE 2A: Transición (Ratio 1.05)** |||||
| 30    | 2A   | 476           | +20 aprox              | Empieza transición |
| 40    | 2A   | 774           | +45 aprox              | Crecimiento visible |
| 50    | 2A   | 1.26k         | +97 aprox              | 🔄 **2do Rebirth** |
| **FASE 2B: Transición (Ratio 1.10)** |||||
| 60    | 2B   | 5.5k          | 4x más                 | Curva se empina |
| 70    | 2B   | 14.3k         | 2.6x más               | Entrando al grind |
| 75    | 2B   | 23.2k         | 1.6x más               | 🔄 **3er Rebirth** |
| **FASE 3: Muro Exponencial (Ratio 1.15)** |||||
| 80    | 3    | 72.2k         | 3x más                 | ⚠️ Muro empieza |
| 88    | 3    | 209k          | 2.9x en 8 niveles      | Exponencial clara |
| 90    | 3    | 269k          | 2x cada 5 niveles      | Patrón establecido |
| 95    | 3    | 541k          | 2x confirmado          | Grind intenso |
| 100   | 3    | **1.17M**     | 2x cada 5 niveles      | 🔄 **4to Rebirth** - Cruce del millón |
| **105** | **3** | **2.36M** ⭐ | **2x cada 5 niveles** | 🔄 **TARGET** - El gran muro |
| 110   | 3    | 4.75M         | 2x cada 5 niveles      | Post-muro |
| 125   | 3    | 24.4M         | 5x en 15 niveles       | 🔄 **5to Rebirth** |
| 150   | 3    | 315M          | ~13x en 25 niveles     | 🔄 **6to Rebirth** |
| 175   | 3    | 4.1B          | ~13x en 25 niveles     | 🔄 **7mo Rebirth** |
| 200   | 3    | 52.9B         | ~13x en 25 niveles     | 🔄 **8vo Rebirth** |
| 250   | 3    | 8.8T          | ~166x en 50 niveles    | 🔄 **10mo Rebirth** |
| 275   | 3    | 114T          | ~13x en 25 niveles     | 🔄 **11vo Rebirth** |
| 300   | 3    | 1.48Qa        | ~13x en 25 niveles     | 🔄 **12vo Rebirth** |
| 350   | 3    | 254Qa         | ~172x en 50 niveles    | 🔄 **14vo Rebirth** |
| **375** | **3** | **3.29Qi**   | ~13x en 25 niveles     | 🔄 **HARD CAP (Rebirth 15)** |

**Leyenda:**
- ⭐ = Objetivo de diseño alcanzado
- 🔄 = Rebirth disponible
- ⚠️ = Cambio significativo en dificultad

---

## 2. Rebirth System

### Requirements

- Rebirth happens every **25 levels**
- Maximum level is **375** (hard cap)

| Rebirth # | Level Required | Total Rebirths Possible |
| --------- | -------------- | ----------------------- |
| 0 → 1     | 25             | 15 rebirths total       |
| 1 → 2     | 50             | (375 / 25 = 15)         |
| 2 → 3     | 75             |                         |
| ...       | ...            |                         |
| 14 → 15   | 375            | MAXIMUM                 |

### Effects

- **Resets:** Level → 1, EXP → 0, Walk Speed → 16
- **Keeps:** Rebirth count, Wins, Equipment, Purchased multipliers
- **Grants:** EXP multiplier increases

### Rebirth Multiplier Formula

```lua
Rebirth_Multiplier = (Rebirths × 0.5) + 1
```

| Rebirths | Multiplier | Gain  |
| -------- | ---------- | ----- |
| 0        | 1.0x       | Base  |
| 1        | 1.5x       | +50%  |
| 2        | 2.0x       | +100% |
| 5        | 3.5x       | +250% |
| 10       | 6.0x       | +500% |
| 15       | 8.5x       | +750% |

---

## 3. Multiplier System (Hybrid Formula)

### The Formula

```lua
Final_EXP = (Base × Zone × Rebirth) × (1 + Sum_of_Boosts)
```

**Components:**

- **Base:** EquipType stat (equipment multiplier)
- **Zone:** Zone's ExpBase attribute (training zone bonus)
- **Rebirth:** Rebirth multiplier (see above)
- **Boosts:** Speed multiplier and future items (additive)

### Speed Boost Conversion

Speed multipliers are converted to additive boosts:

```lua
Speed_Boost = Speed_Multiplier - 1
```

| Speed Multiplier | Boost Value | Final Multiplier |
| ---------------- | ----------- | ---------------- |
| 1x (default)     | +0          | 1x               |
| 2x               | +1          | 2x               |
| 4x               | +3          | 4x               |
| 8x               | +7          | 8x               |
| 16x              | +15         | 16x              |

### Example Calculation

**Scenario:**

- Base EXP: 100 (EquipType 1, Zone 1x)
- Rebirths: 2 (2.0x multiplier)
- Speed: 4x multiplier

**Calculation:**

```
Base Value = 100 × 1 × 2.0 = 200
Speed Boost = 4 - 1 = 3
Final EXP = 200 × (1 + 3) = 800 EXP per tick
```

### Multi-Rebirth Examples

| Rebirth | Base | Speed | Calculation | EXP/tick | Total Mult |
| ------- | ---- | ----- | ----------- | -------- | ---------- |
| 0       | 100  | 1x    | 100×1.0×1   | 100      | 1.0x       |
| 0       | 100  | 16x   | 100×1.0×16  | 1,600    | 16.0x      |
| 5       | 100  | 1x    | 100×3.5×1   | 350      | 3.5x       |
| 5       | 100  | 16x   | 100×3.5×16  | 5,600    | 56.0x      |
| 10      | 100  | 16x   | 100×6.0×16  | 9,600    | 96.0x      |

**Key Insight:** The hybrid formula prevents exponential explosion while still rewarding players significantly for purchasing boosts and doing rebirths.

---

## 4. Number Formatting

### Supported Suffixes

| Suffix | Name         | Value | Example Display |
| ------ | ------------ | ----- | --------------- |
| (none) | Ones         | 1     | 500             |
| k      | Thousands    | 10³   | 1.5k            |
| M      | Millions     | 10⁶   | 123.45M         |
| B      | Billions     | 10⁹   | 6.9B            |
| T      | Trillions    | 10¹²  | 2.05T           |
| Qa     | Quadrillions | 10¹⁵  | 6.9Qa           |
| Qi     | Quintillions | 10¹⁸  | 1.2Qi           |
| Sx     | Sextillions  | 10²¹  | 500Sx           |
| Sp     | Septillions  | 10²⁴  | 99.9Sp          |
| Oc     | Octillions   | 10²⁷  | 7.5Oc           |
| No     | Nonillions   | 10³⁰  | 3.14No          |
| Dc     | Decillions   | 10³³  | 1Dc             |

### Usage

The `NumberFormatter` module is located at:

```
src/Utils/NumberFormatter.luau
```

**Functions:**

- `Format(number, decimals?)` - Formats with suffix
- `FormatProgress(current, max)` - Progress bar format
- `FormatWithCommas(number)` - Adds commas (no suffix)
- `Parse(string)` - Converts formatted string back to number

---

## 5. Data Storage

### Current Limits

- **Storage:** Standard Lua numbers (double precision)
- **Safe Range:** Up to ~9 quadrillion (9 × 10¹⁵)
- **Current Max:** Level 375 requires far more than this

### Future Considerations

If players approach the safe integer limit, consider:

1. String-based storage for EXP values
2. BigNumber library implementation
3. Scientific notation for display

---

## 6. Player Experience Guide

### Early Game (Levels 1-25)

- **Feel:** Very fast, rewarding
- **Time:** Minutes to first rebirth
- **Strategy:** Learn mechanics, explore zones

### Mid Game (Levels 26-125)

- **Feel:** Steady progression, strategic
- **Time:** Hours per rebirth tier
- **Strategy:** Optimize multipliers, equipment upgrades

### Late Game (Levels 126-275)

- **Feel:** Grind intensifies, prestige matters
- **Time:** Days per rebirth
- **Strategy:** Max speed multipliers, zone optimization

### Endgame (Levels 276-375)

- **Feel:** Ultimate challenge, slow grind
- **Time:** Weeks to cap
- **Strategy:** Full optimization, max rebirths

---

## 7. Implementation Files

### Server

- `src/server/Data/DataManager.luau` - Core EXP/level logic
- `src/server/Systems/RebirthSystem.server.luau` - Rebirth handling
- `src/server/Systems/ExpTraining.server.luau` - Zone training EXP
- `src/server/Systems/WalkTraining.server.luau` - Walking EXP

### Client

- `src/client/ExpBarUpdater.client.luau` - EXP bar UI
- `src/client/RebirthProgressBarUpdater.client.luau` - Rebirth progress
- `src/client/MultiTextUpdater.client.luau` - Multiplier display

### Shared

- `src/Utils/NumberFormatter.luau` - Number formatting utility

---

## 8. Testing Checklist

- [ ] Level 1 → 25: Verify fast progression
- [ ] Level 25: Confirm first rebirth available
- [ ] Level 26: Check ratio change (should feel harder)
- [ ] Level 50: Second rebirth
- [ ] Level 75: Verify "2.05M wall" mentioned in design
- [ ] Level 125+: Confirm quadrillion-scale numbers display correctly
- [ ] Level 375: Hard cap - cannot level beyond
- [ ] Rebirth: Stats reset correctly
- [ ] Multipliers: Hybrid formula applies correctly
- [ ] UI: All numbers formatted with proper suffixes

---

## Notes

- This is a **testing environment** - player data will be reset
- Progression curve is intentionally aggressive at higher levels
- The hybrid multiplier system prevents runaway exponential growth
- All formulas are synchronized between client and server

---

**Last Updated:** 2026-01-04
**Version:** 1.0
