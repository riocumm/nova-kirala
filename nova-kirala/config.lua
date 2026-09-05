Config = {}

-- Vale (NPC) Ayarları
Config.Ped = {
    model = "s_m_y_valet_01",
    coords = vector4(-1039.17, -2730.94, 20.21, 240.09)
}

-- Araç Doğma Noktası
Config.VehicleSpawn = vector4(-1032.57, -2728.82, 20.16, 235.92)

-- Kiralama Ayarları
Config.MaxTime = 60 -- Maksimum kiralama süresi (dakika)
Config.FreeTime = 10 -- Ücretsiz kiralama süresi (dakika)

-- Araçlar
Config.Vehicles = {
    {
        model = "blista",
        name = "Blista (Otomobil)",
        icon = "fas fa-car",
        pricePerMinute = 50 -- 10 dakikadan sonraki her dakika için ücret
    },
    {
        model = "faggio", -- Scooter tarzı 2. araç
        name = "Faggio (Motor)",
        icon = "fas fa-motorcycle",
        pricePerMinute = 30
    }
}
