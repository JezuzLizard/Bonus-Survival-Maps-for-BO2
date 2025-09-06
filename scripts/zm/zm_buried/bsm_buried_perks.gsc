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
	level.mazePerkArray = array( "specialty_quickrevive", "specialty_armorvest", "specialty_rof", "specialty_fastreload", "specialty_additionalprimaryweapon", "specialty_longersprint", "specialty_weapupgrade" );

	pLA = [];
	pLA[0] = spawnstruct();
	pLA[0].origin = (4897.65, 724.522, 2.91781);
	pLA[0].angles = (0,0,0);
	pLA[1] = spawnstruct();
	pLA[1].origin = (6704.95, 944.359, 108.125);
	pLA[1].angles = (0,5,0);
	pLA[2] = spawnstruct();
	pLA[2].origin = (6994.16, 360.486, 108.125);
	pLA[2].angles = (0,236,0);
	pLA[3] = spawnstruct();
	pLA[3].origin = (5439, 870, 4.125);
	pLA[3].angles = (0,180,0);
	pLA[4] = spawnstruct();
	pLA[4].origin = (3434.58, 848.447, 57.4652);
	pLA[4].angles = (0,90,0);
	pLA[5] = spawnstruct();
	pLA[5].origin = (5211.65, 57.4669, 4.125);
	pLA[5].angles = (0,90,0);
	pLA[6] = spawnstruct();
	pLA[6].origin = (4115.64, -126.73, 4.125);
	pLA[6].angles = (0,90,0);
	pLA[7] = spawnstruct();
	pLA[7].origin = (4586.63, 1100.12, 4.125);
	pLA[7].angles = (0,270,0);
	pLA = array_randomize(pLA);
	level.mazePerks[ "specialty_armorvest" ] = spawnstruct();
	level.mazePerks[ "specialty_armorvest" ].origin = pLA[0].origin;
	level.mazePerks[ "specialty_armorvest" ].angles = pLA[0].angles;
	level.mazePerks[ "specialty_armorvest" ].model = "zombie_vending_jugg";
	level.mazePerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
	level.mazePerks[ "specialty_quickrevive" ] = spawnstruct();
	level.mazePerks[ "specialty_quickrevive" ].origin = pLA[1].origin;
	level.mazePerks[ "specialty_quickrevive" ].angles = pLA[1].angles;
	level.mazePerks[ "specialty_quickrevive" ].model = "zombie_vending_quickrevive";
	level.mazePerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
	level.mazePerks[ "specialty_rof" ] = spawnstruct();
	level.mazePerks[ "specialty_rof" ].origin = pLA[2].origin;
	level.mazePerks[ "specialty_rof" ].angles = pLA[2].angles;
	level.mazePerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
	level.mazePerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
	level.mazePerks[ "specialty_fastreload" ] = spawnstruct();
	level.mazePerks[ "specialty_fastreload" ].origin = pLA[3].origin;
	level.mazePerks[ "specialty_fastreload" ].angles = pLA[3].angles;
	level.mazePerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
	level.mazePerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
	level.mazePerks[ "specialty_additionalprimaryweapon" ] = spawnstruct();
	level.mazePerks[ "specialty_additionalprimaryweapon" ].origin = pLA[4].origin;
	level.mazePerks[ "specialty_additionalprimaryweapon" ].angles = pLA[4].angles;
	level.mazePerks[ "specialty_additionalprimaryweapon" ].model = "zombie_vending_three_gun";
	level.mazePerks[ "specialty_additionalprimaryweapon" ].script_noteworthy = "specialty_additionalprimaryweapon";
	level.mazePerks[ "specialty_longersprint" ] = spawnstruct();
	level.mazePerks[ "specialty_longersprint" ].origin = pLA[5].origin;
	level.mazePerks[ "specialty_longersprint" ].angles = pLA[5].angles;
	level.mazePerks[ "specialty_longersprint" ].model = "zombie_vending_marathon";
	level.mazePerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
	level.mazePerks[ "specialty_weapupgrade" ] = spawnstruct();
	level.mazePerks[ "specialty_weapupgrade" ].origin = pLA[6].origin;
	level.mazePerks[ "specialty_weapupgrade" ].angles = pLA[6].angles;
	level.mazePerks[ "specialty_weapupgrade" ].model = "p6_anim_zm_buildable_pap_on";
	level.mazePerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
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
		if(is_true(level.customMap == "maze"))
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
	if ( isdefined(level.customMap) && level.customMap == "maze" && !is_true(level.disableBSMMagic) )
	{
		foreach( perk in level.mazePerkArray )
		{
			pos[pos.size] = level.mazePerks[ perk ];
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
			if(level.script == "zm_buried" && level.customMap == "maze")
			{
				collision SetModel( "collision_player_cylinder_32x128" );
				collision ConnectPaths();
			}
			else
			{
				collision SetModel( "zm_collision_perks1" );
				collision DisconnectPaths();
			}
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