#include maps\mp\zombies\_zm;
#include maps\mp\zombies\_zm_perks;
#include maps\mp\_visionset_mgr;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_stats;
#include maps\mp\_demo;
#include maps\mp\zombies\_zm_audio;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include maps\mp\zombies\_zm_power;
#include maps\mp\zombies\_zm_laststand;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_magicbox;

main()
{
	replacefunc(maps\mp\zombies\_zm_perks::perk_machine_spawn_init, ::perk_machine_spawn_init);
}

extra_perk_spawns() //custom function
{
	level.cornfieldPerkArray = array( "specialty_armorvest", "specialty_rof", "specialty_fastreload", "specialty_longersprint",
							 "specialty_scavenger", "specialty_weapupgrade", "specialty_quickrevive" );
							 
	level.cornfieldPerks[ "specialty_armorvest" ] = spawnstruct();
	level.cornfieldPerks[ "specialty_armorvest" ].origin = ( 13936, -649, -189 );
	level.cornfieldPerks[ "specialty_armorvest" ].angles = ( 0, 179, 0 );
	level.cornfieldPerks[ "specialty_armorvest" ].model = "zombie_vending_jugg";
	level.cornfieldPerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
	level.cornfieldPerks[ "specialty_rof" ] = spawnstruct();
	level.cornfieldPerks[ "specialty_rof" ].origin = ( 12052, -1943, -160 );
	level.cornfieldPerks[ "specialty_rof" ].angles = ( 0, -137, 0 );
	level.cornfieldPerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
	level.cornfieldPerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
	level.cornfieldPerks[ "specialty_fastreload" ] = spawnstruct();
	level.cornfieldPerks[ "specialty_fastreload" ].origin = ( 13255, 74, -195 );
	level.cornfieldPerks[ "specialty_fastreload" ].angles = ( 0, -4, 0 );
	level.cornfieldPerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
	level.cornfieldPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
	level.cornfieldPerks[ "specialty_longersprint" ] = spawnstruct();
	level.cornfieldPerks[ "specialty_longersprint" ].origin = ( 9944, -725, -211 );
	level.cornfieldPerks[ "specialty_longersprint" ].angles = ( 0, 133, 0 );
	level.cornfieldPerks[ "specialty_longersprint" ].model = "zombie_vending_marathon";
	level.cornfieldPerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
	level.cornfieldPerks[ "specialty_scavenger" ] = spawnstruct();
	level.cornfieldPerks[ "specialty_scavenger" ].origin = ( 13551, -1384, -188 );
	level.cornfieldPerks[ "specialty_scavenger" ].angles = ( 0, 90, 0 );
	level.cornfieldPerks[ "specialty_scavenger" ].model = "zombie_vending_tombstone";
	level.cornfieldPerks[ "specialty_scavenger" ].script_noteworthy = "specialty_scavenger";
	level.cornfieldPerks[ "specialty_weapupgrade" ] = spawnstruct();
	level.cornfieldPerks[ "specialty_weapupgrade" ].origin = ( 9960, -1288, -217 );
	level.cornfieldPerks[ "specialty_weapupgrade" ].angles = ( 0, 123, 0);
	level.cornfieldPerks[ "specialty_weapupgrade" ].model = "p6_anim_zm_buildable_pap_on";
	level.cornfieldPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
	level.cornfieldPerks[ "specialty_quickrevive" ] = spawnstruct();
	level.cornfieldPerks[ "specialty_quickrevive" ].origin = ( 7831, -464, -203 );
	level.cornfieldPerks[ "specialty_quickrevive" ].angles = ( 0, -90, 0 );
	level.cornfieldPerks[ "specialty_quickrevive" ].model = "zombie_vending_quickrevive";
	level.cornfieldPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
	
	level.dinerPerkArray = array( "specialty_armorvest", "specialty_rof", "specialty_longersprint",
							 	  "specialty_scavenger", "specialty_weapupgrade", "specialty_quickrevive" );
							 
	level.dinerPerks[ "specialty_armorvest" ] = spawnstruct();
	level.dinerPerks[ "specialty_armorvest" ].origin = ( -3634, -7464, -58 );
	level.dinerPerks[ "specialty_armorvest" ].angles = ( 0, 176, 0 );
	level.dinerPerks[ "specialty_armorvest" ].model = "zombie_vending_jugg";
	level.dinerPerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
	level.dinerPerks[ "specialty_rof" ] = spawnstruct();
	level.dinerPerks[ "specialty_rof" ].origin = ( -4170, -7610, -61 );
	level.dinerPerks[ "specialty_rof" ].angles = ( 0, -90, 0 );
	level.dinerPerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
	level.dinerPerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
	level.dinerPerks[ "specialty_longersprint" ] = spawnstruct();
	level.dinerPerks[ "specialty_longersprint" ].origin = ( -4576, -6704, -61 );
	level.dinerPerks[ "specialty_longersprint" ].angles = ( 0, 4, 0 );
	level.dinerPerks[ "specialty_longersprint" ].model = "zombie_vending_marathon";
	level.dinerPerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
	level.dinerPerks[ "specialty_scavenger" ] = spawnstruct();
	level.dinerPerks[ "specialty_scavenger" ].origin = ( -6496, -7691, 0 );
	level.dinerPerks[ "specialty_scavenger" ].angles = ( 0, 90, 0 );
	level.dinerPerks[ "specialty_scavenger" ].model = "zombie_vending_tombstone";
	level.dinerPerks[ "specialty_scavenger" ].script_noteworthy = "specialty_scavenger";
	level.dinerPerks[ "specialty_weapupgrade" ] = spawnstruct();
	level.dinerPerks[ "specialty_weapupgrade" ].origin = ( -6351, -7778, 227 );
	level.dinerPerks[ "specialty_weapupgrade" ].angles = ( 0, 175, 0 );
	level.dinerPerks[ "specialty_weapupgrade" ].model = "p6_anim_zm_buildable_pap_on";
	level.dinerPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
	level.dinerPerks[ "specialty_quickrevive" ] = spawnstruct();
	level.dinerPerks[ "specialty_quickrevive" ].origin = ( -5424, -7920, -64 );
	level.dinerPerks[ "specialty_quickrevive" ].angles = ( 0, 137, 0 );
	level.dinerPerks[ "specialty_quickrevive" ].model = "zombie_vending_quickrevive";
	level.dinerPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
	
	level.powerStationPerkArray = array( "specialty_armorvest", "specialty_rof", "specialty_fastreload",
							 			 "specialty_longersprint", "specialty_weapupgrade", "specialty_quickrevive" );
							 
	level.powerStationPerks[ "specialty_armorvest" ] = spawnstruct();
	level.powerStationPerks[ "specialty_armorvest" ].origin = ( 10746, 7282, -557 );
	level.powerStationPerks[ "specialty_armorvest" ].angles = ( 0, -132, 0 );
	level.powerStationPerks[ "specialty_armorvest" ].model = "zombie_vending_jugg";
	level.powerStationPerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
	level.powerStationPerks[ "specialty_rof" ] = spawnstruct();
	level.powerStationPerks[ "specialty_rof" ].origin = ( 11879, 7296, -755 );
	level.powerStationPerks[ "specialty_rof" ].angles = ( 0, -138, 0 );
	level.powerStationPerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
	level.powerStationPerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
	level.powerStationPerks[ "specialty_fastreload" ] = spawnstruct();
	level.powerStationPerks[ "specialty_fastreload" ].origin = ( 11568, 7723, -755 );
	level.powerStationPerks[ "specialty_fastreload" ].angles = ( 0, -1, 0 );
	level.powerStationPerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
	level.powerStationPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
	level.powerStationPerks[ "specialty_longersprint" ] = spawnstruct();
	level.powerStationPerks[ "specialty_longersprint" ].origin = ( 10856, 7879, -576 );
	level.powerStationPerks[ "specialty_longersprint" ].angles = ( 0, -35, 0 );
	level.powerStationPerks[ "specialty_longersprint" ].model = "zombie_vending_marathon";
	level.powerStationPerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
	level.powerStationPerks[ "specialty_weapupgrade" ] = spawnstruct();
	level.powerStationPerks[ "specialty_weapupgrade" ].origin = ( 12625, 7434, -755 );
	level.powerStationPerks[ "specialty_weapupgrade" ].angles = ( 0, 162, 0 );
	level.powerStationPerks[ "specialty_weapupgrade" ].model = "p6_anim_zm_buildable_pap_on";
	level.powerStationPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
	level.powerStationPerks[ "specialty_quickrevive" ] = spawnstruct();
	level.powerStationPerks[ "specialty_quickrevive" ].origin = ( 11156, 8120, -575 );
	level.powerStationPerks[ "specialty_quickrevive" ].angles = ( 0, -4, 0 );
	level.powerStationPerks[ "specialty_quickrevive" ].model = "zombie_vending_quickrevive";
	level.powerStationPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
	
	level.tunnelPerkArray = array( "specialty_armorvest", "specialty_rof", "specialty_fastreload", "specialty_longersprint",
							 	   "specialty_scavenger", "specialty_weapupgrade", "specialty_quickrevive" );
							 
	level.tunnelPerks[ "specialty_armorvest" ] = spawnstruct();
	level.tunnelPerks[ "specialty_armorvest" ].origin = ( -11541, -2630, 194 );
	level.tunnelPerks[ "specialty_armorvest" ].angles = ( 0, -180, 0 );
	level.tunnelPerks[ "specialty_armorvest" ].model = "zombie_vending_jugg";
	level.tunnelPerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
	level.tunnelPerks[ "specialty_rof" ] = spawnstruct();
	level.tunnelPerks[ "specialty_rof" ].origin = ( -11170, -590, 196 );
	level.tunnelPerks[ "specialty_rof" ].angles = ( 0, -10, 0 );
	level.tunnelPerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
	level.tunnelPerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
	level.tunnelPerks[ "specialty_fastreload" ] = spawnstruct();
	level.tunnelPerks[ "specialty_fastreload" ].origin = ( -11373, -1674, 192 );
	level.tunnelPerks[ "specialty_fastreload" ].angles = ( 0, -89, 0 );
	level.tunnelPerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
	level.tunnelPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
	level.tunnelPerks[ "specialty_longersprint" ] = spawnstruct();
	level.tunnelPerks[ "specialty_longersprint" ].origin = ( -11681, -734, 228 );
	level.tunnelPerks[ "specialty_longersprint" ].angles = ( 0, -19, 0 );
	level.tunnelPerks[ "specialty_longersprint" ].model = "zombie_vending_marathon";
	level.tunnelPerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
	level.tunnelPerks[ "specialty_scavenger" ] = spawnstruct();
	level.tunnelPerks[ "specialty_scavenger" ].origin = ( -10664, -757, 196 );
	level.tunnelPerks[ "specialty_scavenger" ].angles = ( 0, -98, 0 );
	level.tunnelPerks[ "specialty_scavenger" ].model = "zombie_vending_tombstone";
	level.tunnelPerks[ "specialty_scavenger" ].script_noteworthy = "specialty_scavenger";
	level.tunnelPerks[ "specialty_weapupgrade" ] = spawnstruct();
	level.tunnelPerks[ "specialty_weapupgrade" ].origin = ( -11301, -2096, 184 );
	level.tunnelPerks[ "specialty_weapupgrade" ].angles = ( 0, 115, 0 );
	level.tunnelPerks[ "specialty_weapupgrade" ].model = "p6_anim_zm_buildable_pap_on";
	level.tunnelPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
	level.tunnelPerks[ "specialty_quickrevive" ] = spawnstruct();
	level.tunnelPerks[ "specialty_quickrevive" ].origin = ( -10780, -2565, 224 );
	level.tunnelPerks[ "specialty_quickrevive" ].angles = ( 0, 270, 0 );
	level.tunnelPerks[ "specialty_quickrevive" ].model = "zombie_vending_quickrevive";
	level.tunnelPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
	
	level.housePerkArray = array( "specialty_weapupgrade" );

	level.housePerks["specialty_weapupgrade"] = spawnstruct();
	level.housePerks["specialty_weapupgrade"].origin = (5394,6869,-23);
	level.housePerks["specialty_weapupgrade"].angles = (0,90,0);
	level.housePerks["specialty_weapupgrade"].model = "tag_origin";
	level.housePerks["specialty_weapupgrade"].script_noteworthy = "specialty_weapupgrade";

	level.farmPerkArray = array( "specialty_weapupgrade" );

	level.farmPerks["specialty_weapupgrade"] = spawnstruct();
	level.farmPerks["specialty_weapupgrade"].origin = (7057, -5727, -49);
	level.farmPerks["specialty_weapupgrade"].angles = (0,90,0);
	level.farmPerks["specialty_weapupgrade"].model = "p6_anim_zm_buildable_pap_on";
	level.farmPerks["specialty_weapupgrade"].script_noteworthy = "specialty_weapupgrade";

	level.busPerkArray = array( "specialty_quickrevive", "specialty_weapupgrade", "specialty_armorvest", "specialty_rof", "specialty_fastreload" );

	level.busPerks[ "specialty_quickrevive" ] = spawnstruct();
	level.busPerks[ "specialty_quickrevive" ].origin = (-6706, 5016, -56);
	level.busPerks[ "specialty_quickrevive" ].angles = (0, 180, 0 );
	level.busPerks[ "specialty_quickrevive" ].model = "zombie_vending_quickrevive";
	level.busPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
	level.busPerks["specialty_weapupgrade"] = spawnstruct();
	level.busPerks["specialty_weapupgrade"].origin = (-6834, 4553, -65);
	level.busPerks["specialty_weapupgrade"].angles = (0,230,0);
	level.busPerks["specialty_weapupgrade"].model = "p6_anim_zm_buildable_pap_on";
	level.busPerks["specialty_weapupgrade"].script_noteworthy = "specialty_weapupgrade";
	level.busPerks["specialty_armorvest"] = spawnstruct();
	level.busPerks["specialty_armorvest"].origin = (-6122, 4110, -52);
	level.busPerks["specialty_armorvest"].angles = (0,180,0);
	level.busPerks["specialty_armorvest"].model = "zombie_vending_jugg";
	level.busPerks["specialty_armorvest"].script_noteworthy = "specialty_armorvest";
	level.busPerks[ "specialty_rof" ] = spawnstruct();
	level.busPerks[ "specialty_rof" ].origin = (-6241, 5337, -56);
	level.busPerks[ "specialty_rof" ].angles = ( 0, 180, 0 );
	level.busPerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
	level.busPerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
	level.busPerks[ "specialty_fastreload" ] = spawnstruct();
	level.busPerks[ "specialty_fastreload" ].origin = (-7489, 4217, -64);
	level.busPerks[ "specialty_fastreload" ].angles = ( 0, 120, 0 );
	level.busPerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
	level.busPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
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
	if ( isDefined(level.customMap) && level.customMap == "cornfield" && isdefined(level.disableBSMMagic) && !level.disableBSMMagic )
	{
		foreach ( perk in level.cornfieldPerkArray )
		{
			pos[ pos.size ] = level.cornfieldPerks[ perk ];
		}
	}
	else if ( isDefined(level.customMap) && level.customMap == "power" && isdefined(level.disableBSMMagic) && !level.disableBSMMagic )
	{
		foreach ( perk in level.powerStationPerkArray )
		{
			pos[ pos.size ] = level.powerStationPerks[ perk ];
		}
	}
	else if ( isDefined(level.customMap) && level.customMap =="diner" && isdefined(level.disableBSMMagic) && !level.disableBSMMagic )
	{
		foreach ( perk in level.dinerPerkArray )
		{
			pos[ pos.size ] = level.dinerPerks[ perk ];
		}
	}
	else if ( isDefined(level.customMap) && level.customMap == "tunnel" && isdefined(level.disableBSMMagic) && !level.disableBSMMagic )
	{
		foreach ( perk in level.tunnelPerkArray )
		{
			pos[ pos.size ] = level.tunnelPerks[ perk ];
		}
	}
	else if ( isDefined(level.customMap) && level.customMap == "house" )
	{
		foreach( perk in level.housePerkArray )
		{
			pos[pos.size] = level.housePerks[ perk ];
		}
	}
	else if ( getDvar("customMap") == "farm" && isdefined(level.disableBSMMagic) && !level.disableBSMMagic )
	{
		foreach( perk in level.farmPerkArray )
		{
			pos[pos.size] = level.farmPerks[ perk ];
		}
	}
	else if ( getDvar("customMap") == "busdepot" && isdefined(level.disableBSMMagic) && !level.disableBSMMagic)
	{
		foreach( perk in level.busPerkArray )
		{
			pos[pos.size] = level.busPerks[ perk ];
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
			use_trigger.clip = collision;
			use_trigger.bump = bump_trigger;
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