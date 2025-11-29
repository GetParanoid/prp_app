# HOF Skills System

HOF’s skill framework is built for the Qbox Framework. It focuses on being straightforward to integrate and flexible enough for custom content.

## Requirements

- **qbx_core** (Qbox Framework)
- **ox_lib** (for UI and utils)

## Highlights

- Built on native Qbox character metadata, so replication and persistence just work.
- Server side hooks fire before XP or level changes land, letting you integrate custom content, rules, unlocks, or deny the change.
- Most things are configurable: skill lists, hidden skills, category groupings, level caps, XP scaling curves, and more.
- Logging feeds into Loki and/or your database, tracking the XP source for every change.
- Skills and categories can stay hidden until a player earns their first XP in the skill, keeping skills hidden until unlocked.
- Performance Oriented: async database writes, batched persistence, and low server overhead.

## Configuration

There are three files you need to touch to tailor the system:

- `config/server.lua` controls server-facing concerns (XP scaling toggles, logging, queue intervals).
- `config/client.lua` customize XP notfications
- `config/shared.lua` defines every skill, its category, and how levels are named or capped.

## XP System Overview

### Dynamic XP Table Generation

By default the XP table is generated at runtime rather than being hard-coded. You can still drop in a static table if you prefer, but the dynamic version follows a polynomial curve with a logarithmic dampener:

```
f(L) = BASE_XP × CURRENT_LEVEL^(XP_TABLE_EXPONENT + logarithmic_dampening)
```


### XP Scaling System (Optional)

An optional scaling pass applies diminishing returns to slow down power leveling at high tiers:

**Formula:** `scaledXP = baseXP × (1 / (1 + (level / MAX_LEVEL) × SCALING_FACTOR))`

**Scaling Examples (100 base XP):**
```
Level 1:  100 XP (0% reduction)   |  Level 15: 72 XP (28% reduction)
Level 5:   88 XP (12% reduction)  |  Level 20: 66 XP (34% reduction)
Level 10:  80 XP (20% reduction)  |
```

## Usage Examples

See `hof-skills-API-reference.md` for the full list of exports, hooks, and commands.
