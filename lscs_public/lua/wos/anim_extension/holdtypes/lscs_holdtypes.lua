
local DATA = {}
DATA.Name = "[LSCS] HoldType Butterfly"
DATA.HoldType = "lscs_butterfly"
DATA.BaseHoldType = "melee"
DATA.Translations = {} 
DATA.Translations[ ACT_MP_STAND_IDLE ] = "vanguard_f_idle"
wOS.AnimExtension:RegisterHoldtype( DATA )
