Config = {}

Config.FarmZones = {
    AramidFarm = {
        Name = "Aramid Farm",
        Item = "aramidfasern", -- The item name in your ESX items database
        ItemLabel = "Aramidfasern",
        Amount = 1, -- Amount of item to give per harvest
        HarvestTime = 1500, -- Time in milliseconds, adjusted for pickup animation

        -- Set to true if a tool is required for farming
        ToolRequired = true,
        -- The item name from your items database that is required.
        RequiredTool = "knife",

        Blip = {
            Pos = { x = 1959.28, y = 4794.43, z = 43.46 },
            Sprite = 478, -- A different sprite, e.g., a cannabis leaf, often used for farms
            Display = 4,
            Scale = 0.8,
            Colour = 2,
            Name = "Aramid Farm"
        },

        -- A static list of points. This replaces the old grid generation.
        -- Points are now more spread out and extend to the right.
        StaticPoints = {
            vector3(1948.3, 4786.1, 43.5), vector3(1952.1, 4785.4, 43.5), vector3(1956.7, 4784.2, 43.5),
            vector3(1961.5, 4783.1, 43.5), vector3(1966.8, 4782.5, 43.5), vector3(1971.9, 4781.9, 43.5),
            vector3(1946.5, 4790.8, 43.5), vector3(1950.9, 4790.2, 43.5), vector3(1955.3, 4789.5, 43.5),
            vector3(1960.1, 4788.7, 43.5), vector3(1965.4, 4788.0, 43.5), vector3(1970.7, 4787.2, 43.5),
            vector3(1975.8, 4786.5, 43.5), vector3(1944.2, 4795.9, 43.5), vector3(1948.8, 4795.1, 43.5),
            vector3(1953.6, 4794.3, 43.5), vector3(1958.7, 4793.5, 43.5), vector3(1964.0, 4792.6, 43.5),
            vector3(1969.3, 4791.8, 43.5), vector3(1974.5, 4790.9, 43.5), vector3(1979.9, 4790.0, 43.5),
            vector3(1942.0, 4801.2, 43.5), vector3(1947.1, 4800.3, 43.5), vector3(1952.0, 4799.4, 43.5),
            vector3(1957.2, 4798.5, 43.5), vector3(1962.5, 4797.6, 43.5), vector3(1967.8, 4796.7, 43.5),
            vector3(1973.1, 4795.8, 43.5), vector3(1978.4, 4794.9, 43.5), vector3(1983.5, 4794.1, 43.5),
            vector3(1940.1, 4806.5, 43.5), vector3(1945.3, 4805.6, 43.5), vector3(1950.5, 4804.7, 43.5),
            vector3(1955.8, 4803.8, 43.5), vector3(1961.1, 4802.9, 43.5), vector3(1966.4, 4802.0, 43.5),
            vector3(1971.7, 4801.1, 43.5), vector3(1977.0, 4800.2, 43.5), vector3(1982.3, 4799.3, 43.5),
            vector3(1987.1, 4798.5, 43.5), vector3(1938.5, 4811.8, 43.5), vector3(1943.7, 4810.9, 43.5),
            vector3(1949.0, 4810.0, 43.5), vector3(1954.3, 4809.1, 43.5), vector3(1959.6, 4808.2, 43.5),
            vector3(1964.9, 4807.3, 43.5), vector3(1970.2, 4806.4, 43.5), vector3(1975.5, 4805.5, 43.5),
            vector3(1980.8, 4804.6, 43.5), vector3(1986.0, 4803.7, 43.5)
        }
    }
}
