return {
    Logging = {
        --! Discord is not a logging service, please switch to loki/grafana, datadog, fivemanage, etc for production.
        backend = 'discord', -- options: 'discord', 'loki'
        discord = {
            webhook = 'https://discord.com/api/'
        },
        --! Loki configuration uses ox_lib logger and it's configuration for endpoint/auth (https://coxdocs.dev/ox_lib/Modules/Logger/Server#grafana-loki)
        loki = {
            enabled = false,
            labels = {
                app = GetCurrentResourceName()
            }
        },
    }
}