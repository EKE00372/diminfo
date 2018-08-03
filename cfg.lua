local addon, ns = ...
local cfg = CreateFrame("Frame")

cfg.Positions = true
cfg.PositionsPoint = {"TOP", Minimap, 0, 15}

cfg.Time = true
cfg.TimePoint = {"TOPLEFT", Minimap, "TOPRIGHT", 30, 15}

cfg.Friends = true
cfg.FriendsPoint =  {"TOPLEFT", "diminfo_Time", "TOPRIGHT", 20, 0}

cfg.Guild = true
cfg.GuildPoint = {"LEFT", "diminfo_Friends", "RIGHT", 10, 0}

cfg.Durability = true
cfg.DurabilityPoint = {"LEFT", "diminfo_Guild", "RIGHT", 10, 0}

cfg.Bags = true
cfg.BagsPoint = {"BOTTOMRIGHT", UIParent, -15, 8}

cfg.Spec = true
cfg.SpecPoint = {"RIGHT", "diminfo_Bag", "LEFT", -70, 0}

cfg.Memory = true
cfg.MemoryPoint = {"RIGHT", "diminfo_Loot", "LEFT", -70, 0}
cfg.MaxAddOns = 30

cfg.System = true
cfg.SystemPoint = {"RIGHT", "diminfo_Memory", "LEFT", -20, 0}

cfg.Currency = false
cfg.CurrencyPoint = {"TOPRIGHT", UIParent, -600, 16}

cfg.Fonts = {STANDARD_TEXT_FONT, 16, "OUTLINE"}
cfg.ColorClass = true

ns.cfg = cfg