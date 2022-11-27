-- i just put them here so they arent always in my face

for i = 1, 5 do
	local SND =  {
		name = "saber_idle"..i,
		channel = CHAN_VOICE_BASE,
		volume = 1,
		level = 75,
		pitch = 100,
		sound = "lscs/saber/saberhum"..i..".wav",
	}
	sound.Add( SND )
end

sound.Add( {
	name = "saber_hup",
	channel = CHAN_STATIC,
	volume = 0.4,
	level = 100,
	pitch = 100,
	sound = {
		"lscs/saber/saberhup1.mp3",
		"lscs/saber/saberhup2.mp3",
		"lscs/saber/saberhup3.mp3",
		"lscs/saber/saberhup5.mp3",
		"lscs/saber/saberhup6.mp3",
		"lscs/saber/saberhup7.mp3",
		"lscs/saber/saberhup8.mp3",
		"lscs/saber/saberhup9.mp3",
	}
} )

sound.Add( {
	name = "saber_spin1",
	channel = CHAN_STATIC,
	volume = 0.8,
	level = 100,
	pitch = 100,
	sound = "lscs/saber/saberspin1.wav"
} )
sound.Add( {
	name = "saber_spin2",
	channel = CHAN_STATIC,
	volume = 0.8,
	level = 100,
	pitch = 100,
	sound = "lscs/saber/saberspin2.wav"
} )
sound.Add( {
	name = "saber_spin3",
	channel = CHAN_STATIC,
	volume = 0.8,
	level = 100,
	pitch = 100,
	sound = "lscs/saber/saberspin3.wav"
} )

sound.Add( {
	name = "saber_block",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 100,
	pitch = 100,
	sound = {
		"lscs/saber/saberblock1.mp3",
		"lscs/saber/saberblock2.mp3",
		"lscs/saber/saberblock3.mp3",
		"lscs/saber/saberblock4.mp3",
		"lscs/saber/saberblock5.mp3",
		"lscs/saber/saberblock6.mp3",
		"lscs/saber/saberblock7.mp3",
		"lscs/saber/saberblock8.mp3",
		"lscs/saber/saberblock9.mp3",
	}
} )

sound.Add( {
	name = "saber_pblock",
	channel = CHAN_STATIC,
	volume = 0.5,
	level = 100,
	pitch = { 100, 100 },
	sound = {
		"lscs/saber/saberbounce1.mp3",
		"lscs/saber/saberbounce2.mp3",
		"lscs/saber/saberbounce3.mp3",
	}
} )

sound.Add( {
	name = "saber_turnon",
	channel = CHAN_STATIC,
	volume = 0.3,
	level = 75,
	pitch = { 100, 100 },
	sound = "lscs/saber/saberon.mp3",
} )

sound.Add( {
	name = "saber_turnoff",
	channel = CHAN_STATIC,
	volume = 0.3,
	level = 75,
	pitch = { 100, 100 },
	sound = "lscs/saber/saberoff.mp3",
} )

sound.Add( {
	name = "saber_hit",
	channel = CHAN_STATIC,
	volume = 1,
	level = 125,
	pitch = 100,
	sound = {
		"lscs/saber/saberhit1.mp3",
		"lscs/saber/saberhit2.mp3",
		"lscs/saber/saberhit3.mp3",
	}
} )

sound.Add( {
	name = "saber_deflect_bullet",
	channel = CHAN_STATIC,
	volume = 0.35,
	level = 100,
	pitch = 100,
	sound = {
		"lscs/saber/reflect1.mp3",
		"lscs/saber/reflect2.mp3",
		"lscs/saber/reflect3.mp3",
	}
} )

sound.Add( {
	name = "saber_lighthit",
	channel = CHAN_STATIC,
	volume = 0.75,
	level = 100,
	pitch = 100,
	sound = {
		"lscs/saber/lighthit1.wav",
		"lscs/saber/lighthit2.wav",
		"lscs/saber/lighthit3.wav",
		"lscs/saber/lighthit4.wav",
		"lscs/saber/lighthit5.wav",
	}
} )

sound.Add( {
	name = "saber_hitwall",
	channel = CHAN_STATIC,
	volume = 0.3,
	level = 100,
	pitch = { 95, 105 },
	sound = {
		"lscs/saber/saberhitwall1.mp3",
		"lscs/saber/saberhitwall2.mp3",
		"lscs/saber/saberhitwall3.mp3",
	}
} )

sound.Add( {
	name = "saber_hitwall_spark",
	channel = CHAN_STATIC,
	volume = 0.75,
	level = 100,
	pitch = { 95, 105 },
	sound = {
		"lscs/saber/spark1.wav",
		"lscs/saber/spark2.wav",
		"lscs/saber/spark3.wav",
		"lscs/saber/spark4.wav",
		"lscs/saber/spark5.wav",
		"lscs/saber/spark6.wav",
	}
} )

sound.Add( {
	name = "nanosword_hup",
	channel = CHAN_STATIC,
	volume = 1,
	level = 110,
	pitch = { 120, 130 },
	sound = {
		"weapons/stunstick/stunstick_swing1.wav",
		"weapons/stunstick/stunstick_swing2.wav",
	}
} )

sound.Add( {
	name = "nanosword_turnon",
	channel = CHAN_STATIC,
	volume = 0.1,
	level = 75,
	pitch = 100,
	sound = "lscs/nanosword/activate.ogg",
} )

sound.Add( {
	name = "nanosword_turnoff",
	channel = CHAN_STATIC,
	volume = 0.3,
	level = 75,
	pitch = 80,
	sound = {
		"weapons/stunstick/spark1.wav",
		"weapons/stunstick/spark2.wav",
		"weapons/stunstick/spark3.wav",
	}
} )

sound.Add( {
	name = "nanosword_idle",
	channel = CHAN_STATIC,
	volume = 0.15,
	level = 75,
	pitch = 75,
	sound = "ambient/energy/electric_loop.wav",
} )
