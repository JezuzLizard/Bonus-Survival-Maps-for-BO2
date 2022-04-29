#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/_visionset_mgr;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/_demo;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_power;
#include maps/mp/zombies/_zm_laststand;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_magicbox;

main()
{
	if(GetDvar("customMap") == "vanilla")
		return;
	replacefunc(maps/mp/zombies/_zm_perks::perks_register_clientfield, ::perks_register_clientfield); 
	replacefunc(maps/mp/zombies/_zm_perks::set_perk_clientfield, ::set_perk_clientfield);
	replacefunc(maps/mp/zombies/_zm_perks::perk_machine_spawn_init, ::perk_machine_spawn_init);
	replacefunc(maps/mp/zombies/_zm_perks::init, ::perks_init);
	if(GetDvar("customMap") != "rooftop")
	{
		level.zombiemode_using_marathon_perk = 1;
		level.zombiemode_using_revive_perk = 1;
	}
	level.zombiemode_using_additionalprimaryweapon_perk = 1;
	level.zombiemode_using_divetonuke_perk = 1;
	replacefunc(maps/mp/zombies/_zm_perk_divetonuke::enable_divetonuke_perk_for_level, scripts/zm/zm_prison/bsm_prison_perk_phd::enable_divetonuke_perk_for_level);
	maps/mp/zombies/_zm_perk_divetonuke::enable_divetonuke_perk_for_level();
	precacheShader( "specialty_additionalprimaryweapon_zombies" );
	precacheShader( "specialty_divetonuke_zombies" );
	precacheShader( "specialty_juggernaut_zombies" );
	precacheShader( "specialty_quickrevive_zombies" );
	precacheShader( "specialty_fastreload_zombies" );
	precacheShader( "specialty_doubletap_zombies" );
	precacheShader( "specialty_marathon_zombies" );
	precacheShader( "specialty_ads_zombies" );
	precacheShader( "specialty_electric_cherry_zombie" );
}

perks_init() //checked partially changed to match cerberus output
{
	level.additionalprimaryweapon_limit = 3;
	level.perk_purchase_limit = 4;
	if ( !level.createfx_enabled )
	{
		perks_register_clientfield(); //fixed
	}
	if ( !level.enable_magic )
	{
		return;
	}
	initialize_custom_perk_arrays();
	perk_machine_spawn_init();
	vending_weapon_upgrade_trigger = [];
	vending_triggers = getentarray( "zombie_vending", "targetname" );
	for ( i = 0; i < vending_triggers.size; i++ )
	{
		if ( isDefined( vending_triggers[ i ].script_noteworthy ) && vending_triggers[ i ].script_noteworthy == "specialty_weapupgrade" )
		{
			vending_weapon_upgrade_trigger[ vending_weapon_upgrade_trigger.size ] = vending_triggers[ i ];
			arrayremovevalue( vending_triggers, vending_triggers[ i ] );
		}
	}
	old_packs = getentarray( "zombie_vending_upgrade", "targetname" );
	i = 0;
	for ( i = 0; i < old_packs.size; i++ )
	{
		vending_weapon_upgrade_trigger[ vending_weapon_upgrade_trigger.size ] = old_packs[ i ];
	}
	flag_init( "pack_machine_in_use" );
	if ( vending_triggers.size < 1 )
	{
		return;
	}
	if ( vending_weapon_upgrade_trigger.size >= 1 )
	{
		array_thread( vending_weapon_upgrade_trigger, ::vending_weapon_upgrade );
	}
	level.machine_assets = [];
	custom_vending_precaching();
	if ( !isDefined( level.packapunch_timeout ) )
	{
		level.packapunch_timeout = 15;
	}
	set_zombie_var( "zombie_perk_cost", 2000 );
	set_zombie_var( "zombie_perk_juggernaut_health", 160 );
	set_zombie_var( "zombie_perk_juggernaut_health_upgrade", 190 );
	array_thread( vending_triggers, ::vending_trigger_think );
	array_thread( vending_triggers, ::electric_perks_dialog );

	if ( isDefined( level.zombiemode_using_doubletap_perk ) && level.zombiemode_using_doubletap_perk )
	{
		level thread turn_doubletap_on();
	}
	if ( isDefined( level.zombiemode_using_marathon_perk ) && level.zombiemode_using_marathon_perk )
	{
		level thread turn_marathon_on();
	}
	if ( isDefined( level.zombiemode_using_juggernaut_perk ) && level.zombiemode_using_juggernaut_perk )
	{
		level thread turn_jugger_on();
	}
	if ( isDefined( level.zombiemode_using_revive_perk ) && level.zombiemode_using_revive_perk )
	{
		level thread turn_revive_on();
	}
	if ( isDefined( level.zombiemode_using_sleightofhand_perk ) && level.zombiemode_using_sleightofhand_perk )
	{
		level thread turn_sleight_on();
	}
	if ( isDefined( level.zombiemode_using_deadshot_perk ) && level.zombiemode_using_deadshot_perk )
	{
		level thread turn_deadshot_on();
	}
	if ( isDefined( level.zombiemode_using_tombstone_perk ) && level.zombiemode_using_tombstone_perk )
	{
		level thread turn_tombstone_on();
	}
	if ( isDefined( level.zombiemode_using_additionalprimaryweapon_perk ) && level.zombiemode_using_additionalprimaryweapon_perk )
	{
		level thread turn_additionalprimaryweapon_on();
	}
	if ( isDefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk )
	{
		level thread turn_chugabud_on();
	}
	if ( level._custom_perks.size > 0 )
	{
		a_keys = getarraykeys( level._custom_perks );
		for ( i = 0; i < a_keys.size; i++ )
		{
			if ( isdefined( level._custom_perks[ a_keys[ i ] ].perk_machine_thread ) )
			{
				level thread [[ level._custom_perks[ a_keys[ i ] ].perk_machine_thread ]]();
			}
		}
	}
	if ( isDefined( level._custom_turn_packapunch_on ) )
	{
		level thread [[ level._custom_turn_packapunch_on ]]();
	}
	else
	{
		level thread turn_packapunch_on();
	}
	if ( isDefined( level.quantum_bomb_register_result_func ) )
	{
		[[ level.quantum_bomb_register_result_func ]]( "give_nearest_perk", ::quantum_bomb_give_nearest_perk_result, 10, ::quantum_bomb_give_nearest_perk_validation );
	}
	level thread perk_hostmigration();
}

custom_vending_precaching() //checked changed to match cerberus output
{
	precacheshader( "specialty_electric_cherry_zombie" );
	if ( level._custom_perks.size > 0 )
	{
		a_keys = getarraykeys( level._custom_perks );
		for ( i = 0; i < a_keys.size; i++ )
		{
			if ( isDefined( level._custom_perks[ a_keys[ i ] ].precache_func ) )
			{
				level [[ level._custom_perks[ a_keys[ i ] ].precache_func ]]();
			}
		}
	}
	if ( isDefined( level.zombiemode_using_pack_a_punch ) && level.zombiemode_using_pack_a_punch )
	{
		precacheitem( "zombie_knuckle_crack" );
		precachemodel( "p6_anim_zm_buildable_pap" );
		precachemodel( "p6_anim_zm_buildable_pap_on" );
		precachestring( &"ZOMBIE_PERK_PACKAPUNCH" );
		precachestring( &"ZOMBIE_PERK_PACKAPUNCH_ATT" );
		level._effect[ "packapunch_fx" ] = loadfx( "maps/zombie/fx_zombie_packapunch" );
		level.machine_assets[ "packapunch" ] = spawnstruct();
		level.machine_assets[ "packapunch" ].weapon = "zombie_knuckle_crack";
		level.machine_assets[ "packapunch" ].off_model = "p6_zm_al_vending_pap_on";
		level.machine_assets[ "packapunch" ].on_model = "p6_zm_al_vending_pap_on";
		level.machine_assets[ "packapunch" ].power_on_callback = ::custom_vending_power_on;
		level.machine_assets[ "packapunch" ].power_off_callback = ::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_additionalprimaryweapon_perk ) && level.zombiemode_using_additionalprimaryweapon_perk )
	{
		precacheitem( "zombie_perk_bottle_additionalprimaryweapon" );
		precacheshader( "specialty_additionalprimaryweapon_zombies" );
		precachemodel( "p6_zm_al_vending_three_gun_on" );
		precachestring( &"ZOMBIE_PERK_ADDITIONALWEAPONPERK" );
		level._effect[ "additionalprimaryweapon_light" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
		level.machine_assets[ "additionalprimaryweapon" ] = spawnstruct();
		level.machine_assets[ "additionalprimaryweapon" ].weapon = "zombie_perk_bottle_sleight";
		level.machine_assets[ "additionalprimaryweapon" ].off_model = "p6_zm_al_vending_three_gun_on";
		level.machine_assets[ "additionalprimaryweapon" ].on_model = "p6_zm_al_vending_three_gun_on";
		level.machine_assets[ "additionalprimaryweapon" ].power_on_callback = ::custom_vending_power_on;
		level.machine_assets[ "additionalprimaryweapon" ].power_off_callback = ::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_deadshot_perk ) && level.zombiemode_using_deadshot_perk )
	{
		precacheitem( "zombie_perk_bottle_deadshot" );
		precacheshader( "specialty_ads_zombies" );
		precachemodel( "p6_zm_al_vending_ads_on" );
		precachestring( &"ZOMBIE_PERK_DEADSHOT" );
		level._effect[ "deadshot_light" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
		level.machine_assets[ "deadshot" ] = spawnstruct();
		level.machine_assets[ "deadshot" ].weapon = "zombie_perk_bottle_deadshot";
		level.machine_assets[ "deadshot" ].off_model = "p6_zm_al_vending_ads_on";
		level.machine_assets[ "deadshot" ].on_model = "p6_zm_al_vending_ads_on";
		level.machine_assets[ "deadshot" ].power_on_callback = ::custom_vending_power_on;
		level.machine_assets[ "deadshot" ].power_off_callback = ::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_divetonuke_perk ) && level.zombiemode_using_divetonuke_perk )
	{
		//precacheitem( "zombie_perk_bottle_nuke" );
		precacheshader( "specialty_divetonuke_zombies" );
		precachemodel( "p6_zm_al_vending_nuke_on" );
		//precachestring( &"ZOMBIE_PERK_DIVETONUKE" );
		//level._effect[ "divetonuke_light" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
		level.machine_assets[ "divetonuke" ] = spawnstruct();
		level.machine_assets[ "divetonuke" ].weapon = "zombie_perk_bottle_deadshot";
		level.machine_assets[ "divetonuke" ].off_model = "p6_zm_al_vending_nuke_on";
		level.machine_assets[ "divetonuke" ].on_model = "p6_zm_al_vending_nuke_on";
		level.machine_assets[ "divetonuke" ].power_on_callback = ::custom_vending_power_on;
		level.machine_assets[ "divetonuke" ].power_off_callback = ::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_doubletap_perk ) && level.zombiemode_using_doubletap_perk )
	{
		precacheitem( "zombie_perk_bottle_doubletap" );
		precacheshader( "specialty_doubletap_zombies" );
		precachemodel( "p6_zm_al_vending_doubletap2_on" );
		precachestring( &"ZOMBIE_PERK_DOUBLETAP" );
		level._effect[ "doubletap_light" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
		level.machine_assets[ "doubletap" ] = spawnstruct();
		level.machine_assets[ "doubletap" ].weapon = "zombie_perk_bottle_doubletap";
		level.machine_assets[ "doubletap" ].off_model = "p6_zm_al_vending_doubletap2_on";
		level.machine_assets[ "doubletap" ].on_model = "p6_zm_al_vending_doubletap2_on";
		level.machine_assets[ "doubletap" ].power_on_callback = ::custom_vending_power_on;
		level.machine_assets[ "doubletap" ].power_off_callback = ::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_juggernaut_perk ) && level.zombiemode_using_juggernaut_perk )
	{
		precacheitem( "zombie_perk_bottle_jugg" );
		precacheshader( "specialty_juggernaut_zombies" );
		precachemodel( "p6_zm_al_vending_jugg_on" );
		precachestring( &"ZOMBIE_PERK_JUGGERNAUT" );
		level._effect[ "jugger_light" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
		level.machine_assets[ "juggernog" ] = spawnstruct();
		level.machine_assets[ "juggernog" ].weapon = "zombie_perk_bottle_jugg";
		level.machine_assets[ "juggernog" ].off_model = "p6_zm_al_vending_jugg_on";
		level.machine_assets[ "juggernog" ].on_model = "p6_zm_al_vending_jugg_on";
		level.machine_assets[ "juggernog" ].power_on_callback = ::custom_vending_power_on;
		level.machine_assets[ "juggernog" ].power_off_callback = ::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_marathon_perk ) && level.zombiemode_using_marathon_perk )
	{
		precachestring( &"ZOMBIE_PERK_MARATHON" );
		precacheshader("specialty_doublepoints_zombies");
		//level._effect[ "marathon_light" ] = loadfx( "maps/zombie/fx_alcatraz_perk_smk" );
		level.machine_assets[ "marathon" ] = spawnstruct();
		level.machine_assets[ "marathon" ].weapon = "zombie_perk_bottle_doubletap";
		level.machine_assets[ "marathon" ].off_model = "p6_zm_al_vending_doubletap2_on";
		level.machine_assets[ "marathon" ].on_model = "p6_zm_al_vending_doubletap2_on";
	}
	if ( isDefined( level.zombiemode_using_revive_perk ) && level.zombiemode_using_revive_perk )
	{
		precacheshader( "specialty_instakill_zombies" );
		//precachemodel( "zombie_vending_revive" );
		//precachemodel( "zombie_vending_revive_on" );
		precachestring( &"ZOMBIE_PERK_QUICKREVIVE" );
		//level._effect[ "revive_light" ] = loadfx( "misc/fx_zombie_cola_revive_on" );
		//level._effect[ "revive_light_flicker" ] = loadfx( "maps/zombie/fx_zmb_cola_revive_flicker" );
		level.machine_assets[ "revive" ] = spawnstruct();
		level.machine_assets[ "revive" ].weapon = "zombie_perk_bottle_cherry";
		level.machine_assets[ "revive" ].off_model = "p6_zm_vending_electric_cherry_off";
		level.machine_assets[ "revive" ].on_model = "p6_zm_vending_electric_cherry_on";
	}
	if ( isDefined( level.zombiemode_using_sleightofhand_perk ) && level.zombiemode_using_sleightofhand_perk )
	{
		precacheitem( "zombie_perk_bottle_sleight" );
		precacheshader( "specialty_fastreload_zombies" );
		precachemodel( "p6_zm_al_vending_sleight_on" );
		precachestring( &"ZOMBIE_PERK_FASTRELOAD" );
		level._effect[ "sleight_light" ] = loadfx( "maps/zombie_alcatraz/fx_alcatraz_perk_smk" );
		level.machine_assets[ "speedcola" ] = spawnstruct();
		level.machine_assets[ "speedcola" ].weapon = "zombie_perk_bottle_sleight";
		level.machine_assets[ "speedcola" ].off_model = "p6_zm_al_vending_sleight_on";
		level.machine_assets[ "speedcola" ].on_model = "p6_zm_al_vending_sleight_on";
		level.machine_assets[ "speedcola" ].power_on_callback = ::custom_vending_power_on;
		level.machine_assets[ "speedcola" ].power_off_callback = ::custom_vending_power_off;
	}
	if ( isDefined( level.zombiemode_using_tombstone_perk ) && level.zombiemode_using_tombstone_perk )
	{
		precacheitem( "zombie_perk_bottle_tombstone" );
		precacheshader( "specialty_tombstone_zombies" );
		precachemodel( "zombie_vending_tombstone" );
		precachemodel( "zombie_vending_tombstone_on" );
		precachemodel( "ch_tombstone1" );
		precachestring( &"ZOMBIE_PERK_TOMBSTONE" );
		level._effect[ "tombstone_light" ] = loadfx( "misc/fx_zombie_cola_on" );
		level.machine_assets[ "tombstone" ] = spawnstruct();
		level.machine_assets[ "tombstone" ].weapon = "zombie_perk_bottle_tombstone";
		level.machine_assets[ "tombstone" ].off_model = "zombie_vending_tombstone";
		level.machine_assets[ "tombstone" ].on_model = "zombie_vending_tombstone_on";
	}
	if ( isDefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk )
	{
		precacheitem( "zombie_perk_bottle_whoswho" );
		precacheshader( "specialty_quickrevive_zombies" );
		precachemodel( "p6_zm_vending_chugabud" );
		precachemodel( "p6_zm_vending_chugabud_on" );
		precachemodel( "ch_tombstone1" );
		precachestring( &"ZOMBIE_PERK_TOMBSTONE" );
		level._effect[ "tombstone_light" ] = loadfx( "misc/fx_zombie_cola_on" );
		level.machine_assets[ "whoswho" ] = spawnstruct();
		level.machine_assets[ "whoswho" ].weapon = "zombie_perk_bottle_whoswho";
		level.machine_assets[ "whoswho" ].off_model = "p6_zm_vending_chugabud";
		level.machine_assets[ "whoswho" ].on_model = "p6_zm_vending_chugabud_on";
	}
}

custom_vending_power_on() //checked matches cerberus output
{
	self setclientfield( "toggle_perk_machine_power", 2 );
}

custom_vending_power_off() //checked matches cerberus output
{
	self setclientfield( "toggle_perk_machine_power", 1 );
}

set_perk_clientfield( perk, state ) //checked matches cerberus output
{
	if(level.customMap != "vanilla")
	{
		self.resetPerkHUD = 1;
		if ( is_true( state ) )
		{
			self t5_perk_hud_create( perk );
		}
		else 
		{
			self t5_perk_hud_destroy( perk );
		}
		return;
	}
	switch( perk )
	{
		case "specialty_additionalprimaryweapon":
			self setclientfieldtoplayer( "perk_additional_primary_weapon", state );
			break;
		case "specialty_deadshot":
			self setclientfieldtoplayer( "perk_dead_shot", state );
			break;
		case "specialty_flakjacket":
			self setclientfieldtoplayer( "perk_dive_to_nuke", state );
			break;
		case "specialty_rof":
			self setclientfieldtoplayer( "perk_double_tap", state );
			break;
		case "specialty_armorvest":
			self setclientfieldtoplayer( "perk_juggernaut", state );
			break;
		case "specialty_longersprint":
			self setclientfieldtoplayer( "perk_marathon", state );
			break;
		case "specialty_quickrevive":
			self setclientfieldtoplayer( "perk_quick_revive", state );
			break;
		case "specialty_fastreload":
			self setclientfieldtoplayer( "perk_sleight_of_hand", state );
			break;
		case "specialty_scavenger":
			self setclientfieldtoplayer( "perk_tombstone", state );
			break;
		case "specialty_finalstand":
			self setclientfieldtoplayer( "perk_chugabud", state );
			break;
		default:
		if ( isDefined( level._custom_perks[ perk ] ) && isDefined( level._custom_perks[ perk ].clientfield_set ) )
		{
			self [[ level._custom_perks[ perk ].clientfield_set ]]( state );
		}
	}
}

perks_register_clientfield() //modified function
{
	if ( isDefined( level.zombiemode_using_additionalprimaryweapon_perk ) && level.zombiemode_using_additionalprimaryweapon_perk )
	{
	}
	if ( isDefined( level.zombiemode_using_deadshot_perk ) && level.zombiemode_using_deadshot_perk )
	{
		registerclientfield( "toplayer", "perk_dead_shot", 1, 2, "int" );
	}
	if ( isDefined( level.zombiemode_using_doubletap_perk ) && level.zombiemode_using_doubletap_perk )
	{
		registerclientfield( "toplayer", "perk_double_tap", 1, 2, "int" );
	}
	if ( isDefined( level.zombiemode_using_juggernaut_perk ) && level.zombiemode_using_juggernaut_perk )
	{
		registerclientfield( "toplayer", "perk_juggernaut", 1, 2, "int" );
	}
	if ( isDefined( level.zombiemode_using_marathon_perk ) && level.zombiemode_using_marathon_perk )
	{
	}
	if ( isDefined( level.zombiemode_using_revive_perk ) && level.zombiemode_using_revive_perk )
	{
	}
	if ( isDefined( level.zombiemode_using_sleightofhand_perk ) && level.zombiemode_using_sleightofhand_perk )
	{
		registerclientfield( "toplayer", "perk_sleight_of_hand", 1, 2, "int" );
	}
	if ( isDefined( level.zombiemode_using_tombstone_perk ) && level.zombiemode_using_tombstone_perk )
	{
		registerclientfield( "toplayer", "perk_tombstone", 1, 2, "int" );
	}
	if ( isDefined( level.zombiemode_using_perk_intro_fx ) && level.zombiemode_using_perk_intro_fx )
	{
		registerclientfield( "scriptmover", "clientfield_perk_intro_fx", 1000, 1, "int" );
	}
	if ( isDefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk )
	{
		registerclientfield( "toplayer", "perk_chugabud", 1000, 1, "int" );
	}
	if ( isdefined( level._custom_perks ) )
	{
		a_keys = getarraykeys(level._custom_perks);
		for ( i = 0; i < a_keys.size; i++ )
		{
			if ( isdefined( level._custom_perks[ a_keys[ i ] ].clientfield_register ) )
			{
				level [[ level._custom_perks[ a_keys[ i ] ].clientfield_register ]]();
			}
		}
	}
}

extra_perk_spawns() //custom function
{
	level.docksPerkArray = array( "specialty_deadshot", "specialty_rof", "specialty_fastreload", "specialty_grenadepulldeath", "specialty_weapupgrade", "specialty_longersprint", "specialty_additionalprimaryweapon", "specialty_flakjacket", "specialty_quickrevive" );
	
	level.docksPerks[ "specialty_deadshot" ] = spawnstruct();
	level.docksPerks[ "specialty_deadshot" ].origin = ( -1566, 5542.5, -64 );
	level.docksPerks[ "specialty_deadshot" ].angles = ( 0, 45, 0 );
	level.docksPerks[ "specialty_deadshot" ].model = "zombie_vending_ads_on";
	level.docksPerks[ "specialty_deadshot" ].script_noteworthy = "specialty_deadshot";
	level.docksPerks[ "specialty_fastreload" ] = spawnstruct();
	level.docksPerks[ "specialty_fastreload" ].origin = ( -1232.75, 5205.5, -71.875 );
	level.docksPerks[ "specialty_fastreload" ].angles = ( 0, 179, 0 );
	level.docksPerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
	level.docksPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
	level.docksPerks[ "specialty_rof" ] = spawnstruct();
	level.docksPerks[ "specialty_rof" ].origin = ( -578, 6095, -36 );
	level.docksPerks[ "specialty_rof" ].angles = ( 0, 282, 0 );
	level.docksPerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
	level.docksPerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
	level.docksPerks[ "specialty_grenadepulldeath" ] = spawnstruct();
	level.docksPerks[ "specialty_grenadepulldeath" ].origin = ( 82, 8102, 276 );
	level.docksPerks[ "specialty_grenadepulldeath" ].angles = ( 0, 315, 0 );
	level.docksPerks[ "specialty_grenadepulldeath" ].model = "p6_zm_vending_electric_cherry_off";
	level.docksPerks[ "specialty_grenadepulldeath" ].script_noteworthy = "specialty_grenadepulldeath";
	level.docksPerks[ "specialty_longersprint" ] = spawnstruct();
	level.docksPerks[ "specialty_longersprint" ].origin = ( -652.5, 5326, -72 );
	level.docksPerks[ "specialty_longersprint" ].angles = ( 0, 145, 0 );
	level.docksPerks[ "specialty_longersprint" ].model = "p6_zm_al_vending_nuke_on";
	level.docksPerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
	level.docksPerks[ "specialty_additionalprimaryweapon" ] = spawnstruct();
	level.docksPerks[ "specialty_additionalprimaryweapon" ].origin = ( 386, 8297, 64 );
	level.docksPerks[ "specialty_additionalprimaryweapon" ].angles = ( 0, 0, 0 );
	level.docksPerks[ "specialty_additionalprimaryweapon" ].model = "p6_zm_al_vending_nuke_on";
	level.docksPerks[ "specialty_additionalprimaryweapon" ].script_noteworthy = "specialty_additionalprimaryweapon";
	level.docksPerks[ "specialty_quickrevive" ] = spawnstruct();
	level.docksPerks[ "specialty_quickrevive" ].origin = ( 208.5, 6373.25, 64 );
	level.docksPerks[ "specialty_quickrevive" ].angles = ( 0, 235, 0 );
	level.docksPerks[ "specialty_quickrevive" ].model = "p6_zm_al_vending_nuke_on";
	level.docksPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
	level.docksPerks[ "specialty_flakjacket" ] = spawnstruct();
	level.docksPerks[ "specialty_flakjacket" ].origin = ( -643, 7057, 64 );
	level.docksPerks[ "specialty_flakjacket" ].angles = ( 0, 57, 0 );
	level.docksPerks[ "specialty_flakjacket" ].model = "p6_zm_al_vending_nuke_on";
	level.docksPerks[ "specialty_flakjacket" ].script_noteworthy = "specialty_flakjacket";
	level.docksPerks[ "specialty_weapupgrade" ] = spawnstruct();
	level.docksPerks[ "specialty_weapupgrade" ].origin = ( -1769, 5391, -72 );
	level.docksPerks[ "specialty_weapupgrade" ].angles = ( 0, 100, 0 );
	level.docksPerks[ "specialty_weapupgrade" ].model = "p6_zm_al_vending_pap_on";
	level.docksPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
	
	level.cellblockPerkArray = array( "specialty_armorvest", "specialty_deadshot", "specialty_rof", "specialty_weapupgrade", "specialty_longersprint", "specialty_additionalprimaryweapon", "specialty_flakjacket", "specialty_quickrevive" );
	
	level.cellblockPerks[ "specialty_deadshot" ] = spawnstruct();
	level.cellblockPerks[ "specialty_deadshot" ].origin = ( 2827, 9263, 1335 );
	level.cellblockPerks[ "specialty_deadshot" ].angles = ( 0, 180, 0 );
	level.cellblockPerks[ "specialty_deadshot" ].model = "zombie_vending_ads_on";
	level.cellblockPerks[ "specialty_deadshot" ].script_noteworthy = "specialty_deadshot";
	level.cellblockPerks[ "specialty_armorvest" ] = spawnstruct();
	level.cellblockPerks[ "specialty_armorvest" ].origin = ( 1403.5, 9693.5, 1335 );
	level.cellblockPerks[ "specialty_armorvest" ].angles = ( 0, 90, 0 );
	level.cellblockPerks[ "specialty_armorvest" ].model = "zombie_vending_sleight";
	level.cellblockPerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
	level.cellblockPerks[ "specialty_rof" ] = spawnstruct();
	level.cellblockPerks[ "specialty_rof" ].origin = ( 878, 9956, 1335 );
	level.cellblockPerks[ "specialty_rof" ].angles = ( 0, 180, 0 );
	level.cellblockPerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
	level.cellblockPerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
	level.cellblockPerks[ "specialty_longersprint" ] = spawnstruct();
	level.cellblockPerks[ "specialty_longersprint" ].origin = ( -416.35, 9123.5, 1336 );
	level.cellblockPerks[ "specialty_longersprint" ].angles = ( 0, 90, 0 );
	level.cellblockPerks[ "specialty_longersprint" ].model = "p6_zm_al_vending_nuke_on";
	level.cellblockPerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
	level.cellblockPerks[ "specialty_additionalprimaryweapon" ] = spawnstruct();
	level.cellblockPerks[ "specialty_additionalprimaryweapon" ].origin = ( 1627.6, 9117.5, 1336 );
	level.cellblockPerks[ "specialty_additionalprimaryweapon" ].angles = ( 0, 90, 0 );
	level.cellblockPerks[ "specialty_additionalprimaryweapon" ].model = "p6_zm_al_vending_nuke_on";
	level.cellblockPerks[ "specialty_additionalprimaryweapon" ].script_noteworthy = "specialty_additionalprimaryweapon";
	level.cellblockPerks[ "specialty_quickrevive" ] = spawnstruct();
	level.cellblockPerks[ "specialty_quickrevive" ].origin = ( 1777.1, 10675.5, 1335 );
	level.cellblockPerks[ "specialty_quickrevive" ].angles = ( 0, -43, 0 );
	level.cellblockPerks[ "specialty_quickrevive" ].model = "p6_zm_al_vending_nuke_on";
	level.cellblockPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
	level.cellblockPerks[ "specialty_flakjacket" ] = spawnstruct();
	level.cellblockPerks[ "specialty_flakjacket" ].origin = ( 1584, 9162, 1335 );
	level.cellblockPerks[ "specialty_flakjacket" ].angles = ( 0, 270, 0 );
	level.cellblockPerks[ "specialty_flakjacket" ].model = "p6_zm_al_vending_nuke_on";
	level.cellblockPerks[ "specialty_flakjacket" ].script_noteworthy = "specialty_flakjacket";
	level.cellblockPerks[ "specialty_weapupgrade" ] = spawnstruct();
	level.cellblockPerks[ "specialty_weapupgrade" ].origin = ( 891, 8349, 1544 );
	level.cellblockPerks[ "specialty_weapupgrade" ].angles = ( 0, 180, 0 );
	level.cellblockPerks[ "specialty_weapupgrade" ].model = "p6_zm_al_vending_pap_on";
	level.cellblockPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";

	//level.showersPerkArray = array( "specialty_weapupgrade" );

	//level.showersPerks[ "specialty_weapupgrade" ] = spawnstruct();
	//level.showersPerks[ "specialty_weapupgrade" ].origin = ( 2054, 10678, 1144 );
	//level.showersPerks[ "specialty_weapupgrade" ].angles = ( 0, 0, 0 );
	//level.showersPerks[ "specialty_weapupgrade" ].model = "p6_zm_al_vending_pap_on";
	//level.showersPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";

}

perk_machine_spawn_init() //modified function
{
	extra_perk_spawns();
	match_string = "";

	location = level.scr_zm_map_start_location;
	if ( ( location == "default" || location == "" ) && IsDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}		

	match_string = level.scr_zm_ui_gametype + "_perks_" + location;
	pos = [];
	if ( isdefined( level.override_perk_targetname ) )
	{
		structs = getstructarray( level.override_perk_targetname, "targetname" );
	}
	else
	{
		structs = getstructarray( "zm_perk_machine", "targetname" );
	}
	if ( match_string == "zclassic_perks_rooftop" || match_string == "zclassic_perks_tomb" || match_string == "zstandard_perks_nuked" )
	{
		useDefaultLocation = 1;
	}
	i = 0;
	while ( i < structs.size )
	{
		if(is_true(level.disableBSMMagic))
		{
			structs[i].origin = (0,0,-10000);
		}
		if ( isdefined( structs[ i ].script_string ) )
		{
			tokens = strtok( structs[ i ].script_string, " " );
			k = 0;
			while ( k < tokens.size )
			{
				if ( tokens[ k ] == match_string )
				{
					pos[ pos.size ] = structs[ i ];
				}
				k++;
			}
		}
		else if ( isDefined( useDefaultLocation ) && useDefaultLocation )
		{
			pos[ pos.size ] = structs[ i ];
		}
		i++;
	}
	if ( isDefined( level.customMap ) && level.customMap == "docks" && isdefined(level.disableBSMMagic) && !level.disableBSMMagic )
	{
		foreach ( perk in level.docksPerkArray )
		{
			pos[ pos.size ] = level.docksPerks[ perk ];
		}
	}
	else if ( isDefined( level.customMap ) && level.customMap == "cellblock" && isdefined(level.disableBSMMagic) && !level.disableBSMMagic )
	{
		foreach ( perk in level.cellblockPerkArray )
		{
			pos[ pos.size ] = level.cellblockPerks[ perk ];
		}
	}
	else if ( isDefined( level.customMap ) && level.customMap == "showers" && isdefined(level.disableBSMMagic) && !level.disableBSMMagic )
	{
		foreach ( perk in level.showersPerkArray )
		{
			pos[ pos.size ] = level.showersPerks[ perk ];
		}
	}
	if ( !IsDefined( pos ) || pos.size == 0 )
	{
		return;
	}
	PreCacheModel("zm_collision_perks1");
	for ( i = 0; i < pos.size; i++ )
	{
		perk = pos[ i ].script_noteworthy;
		//added for grieffix gun game
		if ( IsDefined( perk ) && IsDefined( pos[ i ].model ) )
		{
			use_trigger = Spawn( "trigger_radius_use", pos[ i ].origin + ( 0, 0, 30 ), 0, 40, 70 );
			use_trigger.targetname = "zombie_vending";			
			use_trigger.script_noteworthy = perk;
			use_trigger TriggerIgnoreTeam();
			use_trigger thread givePoints();
			//use_trigger thread debug_spot();
			perk_machine = Spawn( "script_model", pos[ i ].origin );
			perk_machine.angles = pos[ i ].angles;
			perk_machine SetModel( pos[ i ].model );
			if(level.customMap == "maze")
			{
				perk_machine NotSolid();
				perk_machine ConnectPaths();
			}
			perk_machine.is_locked = 0;
			if ( isdefined( level._no_vending_machine_bump_trigs ) && level._no_vending_machine_bump_trigs )
			{
				bump_trigger = undefined;
			}
			else
			{
				bump_trigger = spawn("trigger_radius", pos[ i ].origin, 0, 35, 64);
				bump_trigger.script_activated = 1;
				bump_trigger.script_sound = "zmb_perks_bump_bottle";
				bump_trigger.targetname = "audio_bump_trigger";
				if ( perk != "specialty_weapupgrade" )
				{
					bump_trigger thread thread_bump_trigger();
				}
			}
			collision = Spawn( "script_model", pos[ i ].origin, 1 );
			collision.angles = pos[ i ].angles;
			collision SetModel( "zm_collision_perks1" );
			collision DisconnectPaths();
			collision.script_noteworthy = "clip";
			// Connect all of the pieces for easy access.
			if(level.customMap == "vanilla" || level.customMap == "cellblock" )
			{
				use_trigger.clip = collision;
				use_trigger.bump = bump_trigger;
				if( level.customMap == "cellblock" )
				{
					if ( perk == "specialty_quickrevive" || perk == "specialty_armorvest" || perk == "specialty_deadshot" || perk == "specialty_flakjacket" )
					{
						collision2 = spawn("script_model", pos[ i ].origin);
   						collision2 setModel("collision_geo_cylinder_32x128_standard");
    					collision2 rotateTo(pos[ i ].angles, .1);
    				}
    				else if ( perk == "specialty_weapupgrade" )
    				{
    					if ( pos[ i ].angles == ( 0, 180, 0 ) || pos[ i ].angles == ( 0, 0, 0 ) )
    					{
    						collision2 = spawn("script_model", pos[ i ].origin + ( 10, 0, 0 ) );
   							collision2 setModel("collision_geo_cylinder_32x128_standard");
    						collision2 rotateTo(pos[ i ].angles, .1);
    						collision3 = spawn("script_model", pos[ i ].origin - ( 10, 0, 0 ) );
   							collision3 setModel("collision_geo_cylinder_32x128_standard");
    						collision3 rotateTo(pos[ i ].angles, .1);
    						collision4 = spawn("script_model", pos[ i ].origin + ( 20, 0, 0 ) );
   							collision4 setModel("collision_geo_cylinder_32x128_standard");
    						collision4 rotateTo(pos[ i ].angles, .1);
    						collision5 = spawn("script_model", pos[ i ].origin - ( 20, 0, 0 ) );
   							collision5 setModel("collision_geo_cylinder_32x128_standard");
    						collision5 rotateTo(pos[ i ].angles, .1);
    					}
    					else if ( pos[ i ].angles == ( 0, 270, 0 ) || pos[ i ].angles == ( 0, 90, 0 ) )
    					{
    						collision2 = spawn("script_model", pos[ i ].origin + ( 10, 10, 0 ) );
   							collision2 setModel("collision_geo_cylinder_32x128_standard");
    						collision2 rotateTo(pos[ i ].angles, .1);
    						collision3 = spawn("script_model", pos[ i ].origin - ( 0, 10, 0 ) );
   							collision3 setModel("collision_geo_cylinder_32x128_standard");
    						collision3 rotateTo(pos[ i ].angles, .1);
    						collision4 = spawn("script_model", pos[ i ].origin + ( 0, 20, 0 ) );
   							collision4 setModel("collision_geo_cylinder_32x128_standard");
    						collision4 rotateTo(pos[ i ].angles, .1);
    						collision5 = spawn("script_model", pos[ i ].origin - ( 0, 20, 0 ) );
   							collision5 setModel("collision_geo_cylinder_32x128_standard");
    						collision5 rotateTo(pos[ i ].angles, .1);
    					}
    				}
    				else if ( pos[ i ].angles == ( 0, 180, 0 ) || pos[ i ].angles == ( 0, 0, 0 ) )
					{
						collision2 = spawn("script_model", pos[ i ].origin + ( 10, 0, 0 ) );
   						collision2 setModel("collision_geo_cylinder_32x128_standard");
    					collision2 rotateTo(pos[ i ].angles, .1);
    					collision3 = spawn("script_model", pos[ i ].origin - ( 10, 0, 0 ) );
   						collision3 setModel("collision_geo_cylinder_32x128_standard");
    					collision3 rotateTo(pos[ i ].angles, .1);
    				}
    				else if ( pos[ i ].angles == ( 0, 270, 0 ) || pos[ i ].angles == ( 0, 90, 0 ) )
					{
						collision2 = spawn("script_model", pos[ i ].origin + ( 0, 10, 0 ) );
   						collision2 setModel("collision_geo_cylinder_32x128_standard");
    					collision2 rotateTo(pos[ i ].angles, .1);
    					collision3 = spawn("script_model", pos[ i ].origin - ( 0, 10, 0 ) );
   						collision3 setModel("collision_geo_cylinder_32x128_standard");
    					collision3 rotateTo(pos[ i ].angles, .1);
    				}
    			}
			}
			use_trigger.machine = perk_machine;
			//missing code found in cerberus output
			if ( isdefined( pos[ i ].blocker_model ) )
			{
				use_trigger.blocker_model = pos[ i ].blocker_model;
			}
			if ( isdefined( pos[ i ].script_int ) )
			{
				perk_machine.script_int = pos[ i ].script_int;
			}
			if ( isdefined( pos[ i ].turn_on_notify ) )
			{
				perk_machine.turn_on_notify = pos[ i ].turn_on_notify;
			}
			switch( perk )
			{
				case "specialty_quickrevive":
				case "specialty_quickrevive_upgrade":
					use_trigger.script_sound = "mus_perks_revive_jingle";
					use_trigger.script_string = "revive_perk";
					use_trigger.script_label = "mus_perks_revive_sting";
					use_trigger.target = "vending_revive";
					perk_machine.script_string = "revive_perk";
					perk_machine.targetname = "vending_revive";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "revive_perk";
					}
					break;
				case "specialty_fastreload":
				case "specialty_fastreload_upgrade":
					use_trigger.script_sound = "mus_perks_speed_jingle";
					use_trigger.script_string = "speedcola_perk";
					use_trigger.script_label = "mus_perks_speed_sting";
					use_trigger.target = "vending_sleight";
					perk_machine.script_string = "speedcola_perk";
					perk_machine.targetname = "vending_sleight";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "speedcola_perk";
					}
					break;
				case "specialty_longersprint":
				case "specialty_longersprint_upgrade":
					use_trigger.script_sound = "mus_perks_stamin_jingle";
					use_trigger.script_string = "marathon_perk";
					use_trigger.script_label = "mus_perks_stamin_sting";
					use_trigger.target = "vending_marathon";
					perk_machine.script_string = "marathon_perk";
					perk_machine.targetname = "vending_marathon";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "marathon_perk";
					}
					break;
				case "specialty_armorvest":
				case "specialty_armorvest_upgrade":
					use_trigger.script_sound = "mus_perks_jugganog_jingle";
					use_trigger.script_string = "jugg_perk";
					use_trigger.script_label = "mus_perks_jugganog_sting";
					use_trigger.longjinglewait = 1;
					use_trigger.target = "vending_jugg";
					perk_machine.script_string = "jugg_perk";
					perk_machine.targetname = "vending_jugg";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "jugg_perk";
					}
					break;
				case "specialty_scavenger":
				case "specialty_scavenger_upgrade":
					use_trigger.script_sound = "mus_perks_tombstone_jingle";
					use_trigger.script_string = "tombstone_perk";
					use_trigger.script_label = "mus_perks_tombstone_sting";
					use_trigger.target = "vending_tombstone";
					perk_machine.script_string = "tombstone_perk";
					perk_machine.targetname = "vending_tombstone";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "tombstone_perk";
					}
					break;
				case "specialty_rof":
				case "specialty_rof_upgrade":
					use_trigger.script_sound = "mus_perks_doubletap_jingle";
					use_trigger.script_string = "tap_perk";
					use_trigger.script_label = "mus_perks_doubletap_sting";
					use_trigger.target = "vending_doubletap";
					perk_machine.script_string = "tap_perk";
					perk_machine.targetname = "vending_doubletap";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "tap_perk";
					}
					break;
				case "specialty_finalstand":
				case "specialty_finalstand_upgrade":
					use_trigger.script_sound = "mus_perks_whoswho_jingle";
					use_trigger.script_string = "tap_perk";
					use_trigger.script_label = "mus_perks_whoswho_sting";
					use_trigger.target = "vending_chugabud";
					perk_machine.script_string = "tap_perk";
					perk_machine.targetname = "vending_chugabud";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "tap_perk";
					}
					break;
				case "specialty_additionalprimaryweapon":
				case "specialty_additionalprimaryweapon_upgrade":
					use_trigger.script_sound = "mus_perks_mulekick_jingle";
					use_trigger.script_string = "tap_perk";
					use_trigger.script_label = "mus_perks_mulekick_sting";
					use_trigger.target = "vending_additionalprimaryweapon";
					perk_machine.script_string = "tap_perk";
					perk_machine.targetname = "vending_additionalprimaryweapon";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "tap_perk";
					}
					break;
				case "specialty_weapupgrade":
					use_trigger.target = "vending_packapunch";
					use_trigger.script_sound = "mus_perks_packa_jingle";
					use_trigger.script_label = "mus_perks_packa_sting";
					use_trigger.longjinglewait = 1;
					perk_machine.targetname = "vending_packapunch";
					flag_pos = getstruct( pos[ i ].target, "targetname" );
					if ( isDefined( flag_pos ) )
					{
						perk_machine_flag = spawn( "script_model", flag_pos.origin );
						perk_machine_flag.angles = flag_pos.angles;
						perk_machine_flag setmodel( flag_pos.model );
						perk_machine_flag.targetname = "pack_flag";
						perk_machine.target = "pack_flag";
					}
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "perks_rattle";
					}
					break;
				case "specialty_deadshot":
				case "specialty_deadshot_upgrade":
					use_trigger.script_sound = "mus_perks_deadshot_jingle";
					use_trigger.script_string = "deadshot_perk";
					use_trigger.script_label = "mus_perks_deadshot_sting";
					use_trigger.target = "vending_deadshot";
					perk_machine.script_string = "deadshot_vending";
					perk_machine.targetname = "vending_deadshot_model";
					if ( isDefined( bump_trigger ) )
					{
						bump_trigger.script_string = "deadshot_vending";
					}
					break;
				default:
					if ( isdefined( level._custom_perks[ perk ] ) && isdefined( level._custom_perks[ perk ].perk_machine_set_kvps ) )
					{
						[[ level._custom_perks[ perk ].perk_machine_set_kvps ]]( use_trigger, perk_machine, bump_trigger, collision );
					}
					break;
			}
		}
	}
}

givePoints()
{
	change_collected = false;
	while(1)
	{
		players = get_players();
		for(i=0;i<players.size;i++)
		{
			if( Distance( players[i].origin, self.origin ) < 60 && players[i] GetStance() == "prone" )
			{
				players[i].score += 100;
				change_collected = true;
			}
		}
		if( isdefined( change_collected ) && change_collected )
			break;
		wait .1;
	}
}	

t5_perk_hud_create( perk )
{
	if ( !IsDefined( self.perk_hud ) )
	{
		self.perk_hud = [];
	}
	shader = "";
	switch( perk )
	{
	case "specialty_armorvest":
		shader = "specialty_juggernaut_zombies";
		break;
	case "specialty_quickrevive":
		shader = "specialty_quickrevive_zombies";
		if ( level.script == "zm_prison" )
		{
			shader = "specialty_electric_cherry_zombie";
			color = ( 0, 0.4, 0.9 );
		}
		break;
	case "specialty_fastreload":
		shader = "specialty_fastreload_zombies";
		break;
	case "specialty_rof":
		shader = "specialty_doubletap_zombies";
		break;
	case "specialty_longersprint":
		shader = "specialty_marathon_zombies";
		if ( level.script == "zm_prison" )
		{
			shader = "specialty_fastreload_zombies";
			color = ( 0.9, 0.4, 0 );
		}
		break;
	case "specialty_flakjacket":
		shader = "specialty_divetonuke_zombies";
		break;
	case "specialty_deadshot":
		shader = "specialty_ads_zombies"; 
		break;
	case "specialty_additionalprimaryweapon":
		shader = "specialty_additionalprimaryweapon_zombies";
		break;
	case "specialty_scavenger":
		shader = "specialty_tombstone_zombies";
		break;
	case "specialty_finalstand":
		shader = "specialty_chugabud_zombies";
		break;
	case "specialty_grenadepulldeath":
		shader = "specialty_electric_cherry_zombie";
		break;
	case "specialty_nomotionsensor":
		shader = "specialty_vulture_zombies";
		break;
	default:
		shader = "";
		break;
	}
	hud = create_simple_hud( self );
	hud.foreground = true; 
	hud.sort = 1; 
	hud.hidewheninmenu = false; 
	hud.alignX = "left"; 
	hud.alignY = "bottom";
	hud.horzAlign = "user_left"; 
	hud.vertAlign = "user_bottom";
	hud.x = self.perk_hud.size * 30; 
	hud.y = hud.y - 70; 
	hud.alpha = 1;
	if ( isDefined( color ) )
	{
		hud.color = color;
	}
	hud SetShader( shader, 24, 24 );
	self.perk_hud[ perk ] = hud;
}


t5_perk_hud_destroy( perk )
{
	self.perk_hud[ perk ] destroy_hud();
	self.perk_hud[ perk ] = undefined;
}