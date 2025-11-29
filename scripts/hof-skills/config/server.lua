local ServerSettings = {
    --! DANGER!!!
    --! DANGER!!!
    --! DANGER!!!
    --? Having `RemoveSkillsNotInConfig` as `true` will remove all skills not in the config from a player's metadata,
    --?     this can be destructive if you are not careful.
    RemoveSkillsNotInConfig = true,
    Logging = {
        Loki = {
            enabled = true,
        },
        Database = {
            enabled = true,
        }
    },
    XPSettings = {
        SCALING_ENABLED = true,         --? Optional, and can be enabled or disabled without issues. Can be disabled at runtime with command /staff:skills:toggleScaling
        XP_GAIN_SCALING_FACTOR = 0.5,  --? Multiplier for XP Scaling calculations. Want less scaling? Increase this value. Want more scaling? Decrease this value. Scaling = XP is less effective at higher levels.
        BASE_LEVEL_XP  = 100,          --? Starting XP for all skills. This probably shouldn't be changed.
        MAX_LEVEL  = 20,               --? Maximum achievable level. This effects the levels generated in the XP_TABLE. Individual skills have their own maxLevel that MUST be equal to or less than this value.
        BASE_XP = 100,                 --? Base XP for calculations (Level 1 starts at BASE_LEVEL_XP). This probably shouldn't be changed.
        XP_TABLE_EXPONENT = 1.55,      --? Polynomial exponent for XP curve. Want faster progression? Lower the exponent. Want slower progression? Raise the exponent.
    },

}


--! You probably shouldn't touch anything below here unless you know what you're doing.
ServerSettings.Functions = {
    -- Generate the XP Table dynamically
    GenerateXPTable = function()
        --[[
            dynamic polynomial progression with logarithmic dampening
            https://onlyagame.typepad.com/only_a_game/2006/08/mathematics_of_.html
            https://web.archive.org/web/20250910070908/https://onlyagame.typepad.com/only_a_game/2006/08/mathematics_of_.html

                https://www.desmos.com/calculator/j9zpuy508t
                f(L)=BASE_XP x CURRENT_LEVEL^XP_TABLE_EXPONENT
                f(L)=100 x CURRENT_LEVEL^1.357

                ServerFunctions.DebugFunctions.PrintXPDifferences()
                Level    XP Required     Difference from Previous
                -----    ----------      ------------------------
                1                100             N/A
                2                261             161
                3                463             202
                4                699             236
                5                965             266
                6                1259            294
                7                1579            320
                8                1924            345
                9                2292            368
                10               2683            391
                11               3096            413
                12               3530            434
                13               3984            454
                14               4458            474
                15               4952            494
                16               5465            513
                17               5996            531
                18               6546            550
                19               7114            568
                20               7700            586
        ]]--
        --? IF you want to have a hardset XP table, you can just hardcode it here as a list instead of generating it dynamically.
        --? I.e. local XP_TABLE = { [1] = ServerSettings.XPSettings.BASE_LEVEL_XP, [2] = 200, [3] = 300, ... }

        local XP_TABLE = {}
        for level = 1, ServerSettings.XPSettings.MAX_LEVEL do
            local dynamicExponent = ServerSettings.XPSettings.XP_TABLE_EXPONENT + (0.1 * math.log(level + 1) / math.log(ServerSettings.XPSettings.MAX_LEVEL + 1))
            XP_TABLE[level] = math.floor(ServerSettings.XPSettings.BASE_XP * (level ^ dynamicExponent))
        end
        return XP_TABLE
    end,
    CalcScaledXPGain = function(xpGain, level)
        if not ServerSettings.XPSettings.SCALING_ENABLED then return xpGain end
        --? Disables scaling if the player is level 1, just to be nice to new players.
        if level == 1 then return math.max(1, xpGain) end

        local scaling_multiplier = ServerSettings.SCALING_CACHE[level] or 1
        return math.max(1, math.floor(xpGain * scaling_multiplier))
    end,
    GenerateScalingCache = function()
        --[[
            --! XP Reduction Scaling Formula
            --?     This formula works as a diminishing returns multiplier,
            --?         reducing XP gain based on the player's level relative to the MAX_LEVEL.
            --?         This makes XP gain gradually slow down.

                ServerFunctions.DebugFunctions.CalculateScaledXPReduction()
                    Level    XP Reduction    Scaled XP (xpGain: 100)
                    1           ~0%           100 XP
                    2           ~5%           95 XP
                    3           ~7%           93 XP
                    4           ~10%          90 XP
                    5           ~12%          88 XP
                    6           ~14%          86 XP
                    7           ~15%          85 XP
                    8           ~17%          83 XP
                    9           ~19%          81 XP
                    10          ~20%          80 XP
                    11          ~22%          78 XP
                    12          ~24%          76 XP
                    13          ~25%          75 XP
                    14          ~26%          74 XP
                    15          ~28%          72 XP
                    16          ~29%          71 XP
                    17          ~30%          70 XP
                    18          ~32%          68 XP
                    19          ~33%          67 XP
                    20          ~34%          66 XP
        ]]--
        if ServerSettings.XPSettings.SCALING_ENABLED then
        local cache = {}
        for level = 1, ServerSettings.XPSettings.MAX_LEVEL do
            cache[level] = 1 / (1 + (level / ServerSettings.XPSettings.MAX_LEVEL) * ServerSettings.XPSettings.XP_GAIN_SCALING_FACTOR)
        end
        return cache
    end
    end,
    ToggleXPScaling = function()
        ServerSettings.XPSettings.SCALING_ENABLED = not ServerSettings.XPSettings.SCALING_ENABLED
        return true, ServerSettings.XPSettings.SCALING_ENABLED
    end,


}
ServerSettings.XP_TABLE = ServerSettings.Functions.GenerateXPTable()
ServerSettings.SCALING_CACHE = ServerSettings.Functions.GenerateScalingCache()

return ServerSettings
