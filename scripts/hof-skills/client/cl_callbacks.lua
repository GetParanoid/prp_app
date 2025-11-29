local confirmData = {
    header = 'Reset Players Skills',
    content ='Resets a player\'s skills to level 1. \n #USE WITH CAUTION, THIS ACTION IS LOGGED.',
    centered = true,
    cancel = true,
    labels = {
        confirm = 'Reset Player Skills',
        cancel = 'Cancel'
    }
}

lib.callback.register('_skills:cl:confirmReset', function()
    -- TODO: Logging
    return lib.alertDialog(confirmData)
end)