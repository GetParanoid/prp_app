local Settings = {
    Notifications = {
        Templates = {
            levelUp = {
                title = 'Level Up!',
                type = 'success',
                duration = 4000,
                icon = 'fas fa-arrow-up',
                position = 'bottom-right',
                iconAnimation = 'pulse',
                sound = {
                    -- https://gist.github.com/Sainan/021bd2f48f1c68d3eb002caab635b5a4
                    enabled = true,
                    set = 'DLC_Biker_Computer_Sounds',
                    name = 'Business_Shutdown',
                },

            },
            levelDown = {
                title = 'Level Down!',
                type = 'error',
                duration = 4000,
                icon = 'fas fa-arrow-down',
                position = 'bottom-right',
                iconAnimation = 'pulse',
                sound = {
                    enabled = true,
                    set = 'DLC_Biker_Computer_Sounds',
                    name = 'Business_Restart',
                },

            },
            xpGain = {
                title = 'XP Gained!',
                type = 'inform',
                duration = 5000,
                icon = 'fas fa-plus',
                position = 'bottom-right',
                iconAnimation = 'pulse',
                sound = {
                    enabled = true,
                    set = 'WEB_NAVIGATION_SOUNDS_PHONE',
                    name = 'CLICK_BACK',
                },

            },
            xpLoss = {
                title = 'XP Lost!',
                type = 'warning',
                duration = 5000,
                icon = 'fas fa-minus',
                position = 'bottom-right',
                iconAnimation = 'pulse',
                sound = {
                    enabled = true,
                    set = 'WEB_NAVIGATION_SOUNDS_PHONE',
                    name = 'Click_Fail',
                },
            }
        },
        Settings = {
            displayTime = 5000,
            maxVisible = 3,
            batchDelay = 1500, -- Time to wait for more notifications to batch
            debounceTime = 2000, -- Minimum time between same notifications
            maxQueueSize = 10,
            maxAccumulateTime = 5000, -- Check if we've been accumulating for too long - force flush to prevent indefinite delays
        }
        
    }
}

return {
    Settings = Settings
}