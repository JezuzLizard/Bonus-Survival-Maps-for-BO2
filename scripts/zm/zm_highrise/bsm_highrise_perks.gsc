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
	replacefunc(maps\mp\zombies\_zm_perks::set_perk_clientfield, ::set_perk_clientfield);
}

set_perk_clientfield( perk, state ) //checked matches cerberus output
{
	if(level.customMap != "vanilla")
	{
		self.resetPerkHUD = 1;
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

extra_perk_spawns() //custom function
{
	level.building1topPerkArray = array( "specialty_quickrevive", "specialty_armorvest", "specialty_rof", "specialty_fastreload", "specialty_flakjacket", "specialty_additionalprimaryweapon", "specialty_weapupgrade" );

	level.building1topPerks[ "specialty_quickrevive" ] = spawnstruct();
	level.building1topPerks[ "specialty_quickrevive" ].origin = (1435, 1225, 3390);
	level.building1topPerks[ "specialty_quickrevive" ].angles = (-10, 180, 0 );
	level.building1topPerks[ "specialty_quickrevive" ].model = "zombie_vending_quickrevive";
	level.building1topPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
	level.building1topPerks[ "specialty_armorvest" ] = spawnstruct();
	level.building1topPerks[ "specialty_armorvest" ].origin = (1444.47, 2713.98, 3048.52);
	level.building1topPerks[ "specialty_armorvest" ].angles = ( 0, 270, 0 );
	level.building1topPerks[ "specialty_armorvest" ].model = "zombie_vending_jugg";
	level.building1topPerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
	level.building1topPerks[ "specialty_rof" ] = spawnstruct();
	level.building1topPerks[ "specialty_rof" ].origin = (2286.36, 2122.6, 3040.13);
	level.building1topPerks[ "specialty_rof" ].angles = ( 0, 270, 0 );
	level.building1topPerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
	level.building1topPerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
	level.building1topPerks[ "specialty_fastreload" ] = spawnstruct();
	level.building1topPerks[ "specialty_fastreload" ].origin = (1916.92, 1139.1, 3216.13);
	level.building1topPerks[ "specialty_fastreload" ].angles = ( 0, 135, 0 );
	level.building1topPerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
	level.building1topPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
	level.building1topPerks[ "specialty_flakjacket" ] = spawnstruct();
	level.building1topPerks[ "specialty_flakjacket" ].origin = (1421.23, 2102.13, 3219.31);
	level.building1topPerks[ "specialty_flakjacket" ].angles = ( 0, 45, 0 );
	level.building1topPerks[ "specialty_flakjacket" ].model = "zombie_vending_nuke_on_lo";
	level.building1topPerks[ "specialty_flakjacket" ].script_noteworthy = "specialty_flakjacket";
	level.building1topPerks[ "specialty_additionalprimaryweapon" ] = spawnstruct();
	level.building1topPerks[ "specialty_additionalprimaryweapon" ].origin = (1521.58, 2094.12, 3392.13);
	level.building1topPerks[ "specialty_additionalprimaryweapon" ].angles = ( 0, 90, 0 );
	level.building1topPerks[ "specialty_additionalprimaryweapon" ].model = "zombie_vending_three_gun";
	level.building1topPerks[ "specialty_additionalprimaryweapon" ].script_noteworthy = "specialty_additionalprimaryweapon";
	level.building1topPerks["specialty_weapupgrade"] = spawnstruct();
	level.building1topPerks["specialty_weapupgrade"].origin = (1195.34, 1281.47, 3392.13);
	level.building1topPerks["specialty_weapupgrade"].angles = (0, 90, 0);
	level.building1topPerks["specialty_weapupgrade"].model = "p6_anim_zm_buildable_pap_on";
	level.building1topPerks["specialty_weapupgrade"].script_noteworthy = "specialty_weapupgrade";
	
	level.redroomPerkArray = array( "specialty_weapupgrade" );

	level.redroomPerks["specialty_weapupgrade"] = spawnstruct();
	level.redroomPerks["specialty_weapupgrade"].origin = (2988, 1141, 1438);
	level.redroomPerks["specialty_weapupgrade"].angles = (0, 270, 12.4);
	level.redroomPerks["specialty_weapupgrade"].model = "p6_anim_zm_buildable_pap_on";
	level.redroomPerks["specialty_weapupgrade"].script_noteworthy = "specialty_weapupgrade";
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
		if(is_true(level.disableBSMMagic) || level.customMap == "building1top" || level.customMap == "redroom" )
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
					if(is_true(level.customMap == "redroom") && structs[i].script_noteworthy == "specialty_weapupgrade")
					{
						structs[i] Delete();
					}
					else
					{
						pos[ pos.size ] = structs[ i ];
					}
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
	if ( isDefined(level.customMap) && level.customMap == "building1top" )
	{
		foreach( perk in level.building1topPerkArray )
		{
			pos[pos.size] = level.building1topPerks[ perk ];
		}
	}
	else if ( isDefined(level.customMap) && level.customMap == "redroom" )
	{
		foreach( perk in level.redroomPerkArray )
		{
			pos[pos.size] = level.redroomPerks[ perk ];
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
			if(!is_true(level.customMap == "vanilla"))
			{
				collision SetModel( "zm_collision_perks1" );
				collision DisconnectPaths();
			}
			collision.script_noteworthy = "clip";
			// Connect all of the pieces for easy access.
			use_trigger.clip = collision;
			use_trigger.bump = bump_trigger;
			if(is_true(level.disableBSMMagic) && level.script == "zm_highrise")
				use_trigger.origin = (0,0,-10000);
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