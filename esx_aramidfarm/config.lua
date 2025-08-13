Config = {}

Config.FarmZones = {
    AramidFarm = {
        Pos = { x = 1959.283570, y = 4794.435058, z = 43.467408 },
        Name = "Aramid Farm",
        Item = "aramid", -- The item name in your ESX items database
        ItemLabel = "Aramidfasern",
        Amount = 1, -- Amount of item to give per harvest
        HarvestTime = 2500, -- Time in milliseconds
        Marker = {
            Type = 1,
            Color = { r = 255, g = 0, b = 0, a = 100 },
            Size = { x = 1.0, y = 1.0, z = 1.0 }
        },
        Blip = {
            Sprite = 147,
            Display = 4,
            Scale = 1.0,
            Colour = 4,
            Name = "Aramid Farm"
        },
        FarmPoints = {
            Count = 50,
            Distance = 5.0 -- meters
        }
    }
}
