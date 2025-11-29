# hof-skills API Reference

> All examples assume the call is made from another resource with a valid `source` (player server ID) and, where applicable, a valid skill or category identifier.

---

## Exports

### Reading Player Skill Data

#### `FetchPlayerSkillXP`
Get the current XP for a single skill.

```lua
exports['hof-skills']:FetchPlayerSkillXP(source, 'skill')
```

- `source`: Player server ID.
- `skill`: Skill name string.
- Returns: Number representing the player's current XP for the specified skill.

#### `FetchPlayerSkillLevel`
Get the current level for a single skill.

```lua
exports['hof-skills']:FetchPlayerSkillLevel(source, 'skill')
```

- `source`: Player server ID.
- `skill`: Skill name string.
- Returns: Number representing the player's current level for the specified skill.

#### `FetchPlayerTotalCategorySkillXP`
Get total XP for an entire skill category (Personal Skills, Gathering, Crafting, Crime).

```lua
exports['hof-skills']:FetchPlayerTotalCategorySkillXP(source, 'category')
```

- `source`: Player server ID.
- `category`: Category identifier string.
- Returns: Number representing the sum of XP for all skills within the category.

#### `FetchPlayerSkills`
Retrieve the complete XP table for all of a player's skills.

```lua
local skills = exports['hof-skills']:FetchPlayerSkills(source)
```

- Returns: Table shaped as `{ ['Skill Name'] = XP_VALUE, ... }`.

### Modifying Player Skill Data

#### `AddPlayerSkillXP`
Add XP to one or more skills in a single call.

```lua
local skillData = {
    xpSource = 'activity/source', -- i.e boosting, hacking, driving, shooting, lockpicking, etc, etc.
    {
        ['Skill Name'] = XP_VALUE,
        ['Skill Name'] = XP_VALUE,
    }
}

exports['hof-skills']:AddPlayerSkillXP(source, skillData)
```

- `xpSource`: String describing why XP is being awarded (for logging/auditing/metrics).
- Table entry `skillData[1]`: Mapping of skills to XP deltas to apply.

#### `RemovePlayerSkillXP`
Remove XP from one or more skills.

```lua
exports['hof-skills']:RemovePlayerSkillXP(source, skillData)
```

- Uses the same `skillData` structure shown for `AddPlayerSkillXP`.


### Events

#### Server Events:
- `_skills:sv:InitPlayerMetadata`

#### Client Events:
- `_skills:cl:OpenSkillsMenu`


### Hooks
Intercept and validate XP changes before they occur:

```lua
local hookExport = exports['hof-skills']
-- Register a hook to validate XP modifications
local xpValidation = hookExport:registerHook('xpModification', function(payload)
    -- Custom validation logic
    if payload.skills['Hacking'] and payload.skills['Hacking'] > 1000 then
        return false, "Too much hacking XP at once!"
    end
    return true -- Allow the XP change
end)

-- Handle level up events
local levelUpHandler = hookExport:registerHook('levelUp', function(payload)
    -- Send notifications, unlock features, etc.
    for skill, levelData in pairs(payload.skills) do
        -- levelData contains: oldLevel, newLevel, levelsGained
    end
end)
```

> **See `server/sv_hookExample.lua` and `server/sv_notifications.lua` for hook implementation examples**

### Global XP Table

#### `GlobalState.XP_TABLE`
Lookup table for level-to-XP thresholds. Keys represent the level, values represent the total XP required to reach that level.

```lua
local XP_TABLE = GlobalState.XP_TABLE
-- Example: XP_TABLE[1] = 100, XP_TABLE[2] = 200
```
---
### Commands

#### Player Commands
| Command | Description |
|---------|-------------|
| `/skills` | Open the skills menu |

#### Admin Commands
| Command | Parameters | Description |
|---------|------------|-------------|
| `/staff:skills:reinitialize` | `<player_id>` | Reinitialize player's skills metadata |
| `/staff:skills:toggleScaling` | - | Toggle XP scaling on/off (runtime only) |
| `/staff:skills:setlevel` | `<player_id> <skill> <level>` | Set specific skill level |
| `/staff:skills:setxp` | `<player_id> <skill> <xp>` | Set XP amount for skill |
| `/staff:skills:reset` | `<player_id> <skill>` | Reset specific skill XP |
| `/staff:skills:reset:all` | `<player_id> <confirm>` | Reset all skills (`yes`/`confirm`) |

> **Admin commands require `group.admin` permission**
