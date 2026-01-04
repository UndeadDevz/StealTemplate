# Progression System Guide

## Overview

This document explains the complete progression system implemented in the game, including formulas, breakpoints, and expected player experience.

---

## 1. EXP Requirements (The Curve)

### Formula

```lua
EXP_Required = 51 × (Ratio ^ Level)
```

### Ratio by Level Blocks

| Level Range | Block Size | Ratio | Difficulty            |
| ----------- | ---------- | ----- | --------------------- |
| 1 - 25      | 25 levels  | 1.05  | Tutorial (Very fluid) |
| 26 - 50     | 25 levels  | 1.10  | Early challenge       |
| 51 - 125    | 75 levels  | 1.15  | Mid-game grind        |
| 126 - 175   | 50 levels  | 1.20  | First wall            |
| 176 - 275   | 100 levels | 1.25  | Late-game wall        |
| 276 - 375   | 100 levels | 1.30  | Endgame (Hard cap)    |

### Key Breakpoints (Approximate EXP Required)

| Level | Ratio | EXP for This Level | Cumulative EXP | Notes                   |
| ----- | ----- | ------------------ | -------------- | ----------------------- |
| 1     | 1.05  | 51                 | 0              | Starting point          |
| 10    | 1.05  | 81                 | 626            | Early game              |
| 25    | 1.05  | 173                | 2,635          | First rebirth available |
| 26    | 1.10  | 294                | 2,929          | Ratio increases!        |
| 50    | 1.10  | 6,178              | 56,253         | Second rebirth          |
| 51    | 1.15  | 11,716             | 67,969         | Ratio increases!        |
| 75    | 1.15  | 205,419            | 2.05M          | Current "wall" zone     |
| 100   | 1.15  | 3.6M               | ~40M           | Deep mid-game           |
| 125   | 1.15  | 63M                | ~700M          | Third rebirth           |
| 126   | 1.20  | 151M               | ~850M          | Ratio increases!        |
| 175   | 1.20  | ~1.5Qa             | ~15Qa          | Quadrillion territory   |
| 275   | 1.25  | Astronomical       | Astronomical   | Endgame                 |
| 375   | 1.30  | Maximum            | Maximum        | **HARD CAP**            |

**Note:** Values beyond level 100 become extremely large due to exponential growth.

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
