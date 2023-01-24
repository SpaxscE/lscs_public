
local DATA = {}
DATA.Name = "[LSCS] HoldType Butterfly"
DATA.HoldType = "lscs_butterfly"
DATA.BaseHoldType = "melee"
DATA.Translations = {} 
DATA.Translations[ ACT_MP_STAND_IDLE ] = "vanguard_f_idle"
DATA.Translations[ ACT_MP_WALK ] = "walk_knife"
DATA.Translations[ ACT_MP_RUN ] = "run_knife"
wOS.AnimExtension:RegisterHoldtype( DATA )
