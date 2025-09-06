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
	if(GetDvar("customMap") == "vanilla")
		return;
	replacefunc(maps\mp\zombies\_zm_perks::perk_machine_spawn_init, ::perk_machine_spawn_init);
	replacefunc(maps\mp\zombies\_zm_perks::wait_for_player_to_take, ::wait_for_player_to_take);
}

wait_for_player_to_take( player, weapon, packa_timer, upgrade_as_attachment ) //changed 3/30/20 4:22 pm //checked matches cerberus output
{
	current_weapon = self.current_weapon;
	upgrade_name = self.upgrade_name;
	/*
/#
	assert( isDefined( current_weapon ), "wait_for_player_to_take: weapon does not exist" );
#/
/#
	assert( isDefined( upgrade_name ), "wait_for_player_to_take: upgrade_weapon does not exist" );
#/
	*/
	upgrade_weapon = upgrade_name;
	self endon( "pap_timeout" );
	level endon( "Pack_A_Punch_off" );
	while ( 1 )
	{
		packa_timer playloopsound( "zmb_perks_packa_ticktock" );
		self waittill( "trigger", trigger_player );
		if ( isDefined( level.pap_grab_by_anyone ) && level.pap_grab_by_anyone )
		{
			player = trigger_player;
		}

		packa_timer stoploopsound( 0.05 );
		if ( trigger_player == player ) //working
		{
			player maps\mp\zombies\_zm_stats::increment_client_stat( "pap_weapon_grabbed" );
			player maps\mp\zombies\_zm_stats::increment_player_stat( "pap_weapon_grabbed" );
			current_weapon = player getcurrentweapon();
			/*
/#
			if ( current_weapon == "none" )
			{
				iprintlnbold( "WEAPON IS NONE, PACKAPUNCH RETRIEVAL DENIED" );
#/
			}
			*/
			if ( is_player_valid( player ) && !player.is_drinking && !is_placeable_mine( current_weapon ) && !is_equipment( current_weapon ) && level.revive_tool != current_weapon && current_weapon != "none" && !player hacker_active() )
			{
				maps\mp\_demo::bookmark( "zm_player_grabbed_packapunch", getTime(), player );
				self notify( "pap_taken" );
				player notify( "pap_taken" );
				player.pap_used = 1;
				if ( isDefined( upgrade_as_attachment ) && !upgrade_as_attachment )
				{
					player thread do_player_general_vox( "general", "pap_arm", 15, 100 );
				}
				else
				{
					player thread do_player_general_vox( "general", "pap_arm2", 15, 100 );
				}
				weapon_limit = get_player_weapon_limit( player );
				player maps\mp\zombies\_zm_weapons::take_fallback_weapon();
				primaries = player getweaponslistprimaries();
				if ( isDefined( primaries ) && primaries.size >= weapon_limit )
				{
					player maps\mp\zombies\_zm_weapons::weapon_give( upgrade_weapon );
				}
				else
				{
					player giveweapon( upgrade_weapon, 0, player maps\mp\zombies\_zm_weapons::get_pack_a_punch_weapon_options( upgrade_weapon ) );
					player givestartammo( upgrade_weapon );
				}
				if(upgrade_weapon == "staff_air_upgraded_zm" || upgrade_weapon == "staff_fire_upgraded_zm" || upgrade_weapon == "staff_lightning_upgraded_zm" || upgrade_weapon == "staff_water_upgraded_zm")
				{
					player giveweapon( "staff_revive_zm" );
				}
				player switchtoweapon( upgrade_weapon );
				if ( isDefined( player.restore_ammo ) && player.restore_ammo )
				{
					new_clip = player.restore_clip + ( weaponclipsize( upgrade_weapon ) - player.restore_clip_size );
					new_stock = player.restore_stock + ( weaponmaxammo( upgrade_weapon ) - player.restore_max );
					player setweaponammostock( upgrade_weapon, new_stock );
					player setweaponammoclip( upgrade_weapon, new_clip );
				}
				player.restore_ammo = undefined;
				player.restore_clip = undefined;
				player.restore_stock = undefined;
				player.restore_max = undefined;
				player.restore_clip_size = undefined;
				player maps\mp\zombies\_zm_weapons::play_weapon_vo( upgrade_weapon );
				return;
			}
		}
		//wait 0.05;
	}
}

extra_perk_spawns() //custom function
{
	level.trenchesPerkArray = array( "specialty_armorvest", "specialty_weapupgrade", "specialty_longersprint" );
	
	level.trenchesPerks[ "specialty_armorvest" ] = spawnstruct();
	level.trenchesPerks[ "specialty_armorvest" ].origin = ( -976.359, 2905.5, -112 );
	level.trenchesPerks[ "specialty_armorvest" ].angles = ( 0, 90, 0 );
	level.trenchesPerks[ "specialty_armorvest" ].model = "p6_zm_al_vending_nuke_on";
	level.trenchesPerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
	level.trenchesPerks[ "specialty_weapupgrade" ] = spawnstruct();
	level.trenchesPerks[ "specialty_weapupgrade" ].origin = (-6223.94, -6694.36, 152.125);
	level.trenchesPerks[ "specialty_weapupgrade" ].angles = ( 0, 180, 0 );
	level.trenchesPerks[ "specialty_weapupgrade" ].model = "p6_zm_tm_packapunch";
	level.trenchesPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
	level.trenchesPerks[ "specialty_longersprint" ] = spawnstruct();
	level.trenchesPerks[ "specialty_longersprint" ].origin = (-250.068, 4296.36, -191.754);
	level.trenchesPerks[ "specialty_longersprint" ].angles = ( 0, 0, 0 );
	level.trenchesPerks[ "specialty_longersprint" ].model = "zombie_vending_marathon";
	level.trenchesPerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
	
	level.excavationPerkArray = array( "specialty_fastreload", "specialty_quickrevive", "specialty_additionalprimaryweapon" );
	
	level.excavationPerks[ "specialty_fastreload" ] = spawnstruct();
	level.excavationPerks[ "specialty_fastreload" ].origin = ( -104.359, -758.326, 224 );
	level.excavationPerks[ "specialty_fastreload" ].angles = ( 0, 87.718, 0 );
	level.excavationPerks[ "specialty_fastreload" ].model = "p6_zm_al_vending_nuke_on";
	level.excavationPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
	level.excavationPerks[ "specialty_quickrevive" ] = spawnstruct();
	level.excavationPerks[ "specialty_quickrevive" ].origin = ( -395.641, 1078.5, 131.5 );
	level.excavationPerks[ "specialty_quickrevive" ].angles = ( 0, 314, 0 );
	level.excavationPerks[ "specialty_quickrevive" ].model = "p6_zm_al_vending_nuke_on";
	level.excavationPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
	level.excavationPerks[ "specialty_additionalprimaryweapon" ] = spawnstruct();
	level.excavationPerks[ "specialty_additionalprimaryweapon" ].origin = ( -863.388, 2216.36, -119.95 );
	level.excavationPerks[ "specialty_additionalprimaryweapon" ].angles = ( 0, 0, 0 );
	level.excavationPerks[ "specialty_additionalprimaryweapon" ].model = "p6_anim_zm_buildable_pap_on";
	level.excavationPerks[ "specialty_additionalprimaryweapon" ].script_noteworthy = "specialty_additionalprimaryweapon";
	
	level.tankPerkArray = array( "specialty_longersprint", "specialty_fastreload", "specialty_additionalprimaryweapon", "specialty_armorvest", "specialty_quickrevive", "specialty_weapupgrade" );
	
	level.tankPerks[ "specialty_fastreload" ] = spawnstruct();
	level.tankPerks[ "specialty_fastreload" ].origin = ( 1081.96, -2531.19, 302.1 );
	level.tankPerks[ "specialty_fastreload" ].angles = ( 0, 286, 0 );
	level.tankPerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
	level.tankPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
	level.tankPerks[ "specialty_additionalprimaryweapon" ] = spawnstruct();
	level.tankPerks[ "specialty_additionalprimaryweapon" ].origin = ( 132.545, -2446, 302.1 );
	level.tankPerks[ "specialty_additionalprimaryweapon" ].angles = ( 0, 55, 0 );
	level.tankPerks[ "specialty_additionalprimaryweapon" ].model = "p6_zm_al_vending_nuke_on";
	level.tankPerks[ "specialty_additionalprimaryweapon" ].script_noteworthy = "specialty_additionalprimaryweapon";
	level.tankPerks[ "specialty_quickrevive" ] = spawnstruct();
	level.tankPerks[ "specialty_quickrevive" ].origin = ( -48.11, -2140.42, 230 );
	level.tankPerks[ "specialty_quickrevive" ].angles = ( 0, 113.712, 0 );
	level.tankPerks[ "specialty_quickrevive" ].model = "p6_zm_al_vending_nuke_on";
	level.tankPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
	level.tankPerks[ "specialty_armorvest" ] = spawnstruct();
	level.tankPerks[ "specialty_armorvest" ].origin = ( 1578.91, -2230.5, -34.5 );
	level.tankPerks[ "specialty_armorvest" ].angles = ( 0, 284, 0 );
	level.tankPerks[ "specialty_armorvest" ].model = "p6_zm_al_vending_nuke_on";
	level.tankPerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
	level.tankPerks[ "specialty_longersprint" ] = spawnstruct();
	level.tankPerks[ "specialty_longersprint" ].origin = ( 172.817, -2415.75, 50 );
	level.tankPerks[ "specialty_longersprint" ].angles = ( 0, 13, 0 );
	level.tankPerks[ "specialty_longersprint" ].model = "p6_zm_al_vending_nuke_on";
	level.tankPerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
	level.tankPerks[ "specialty_weapupgrade" ] = spawnstruct();
	level.tankPerks[ "specialty_weapupgrade" ].origin = ( 1427.41, -1577.64, -107.95 );
	level.tankPerks[ "specialty_weapupgrade" ].angles = ( 0, 356.609, 0 );
	level.tankPerks[ "specialty_weapupgrade" ].model = "p6_zm_tm_packapunch";
	level.tankPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
	
	level.crazyplacePerkArray = array( "specialty_longersprint", "specialty_fastreload", "specialty_armorvest", "specialty_quickrevive", "specialty_weapupgrade" );
	
	level.crazyplacePerks[ "specialty_fastreload" ] = spawnstruct();
	level.crazyplacePerks[ "specialty_fastreload" ].origin = ( 9519.64, -7785.12, -463.25 );
	level.crazyplacePerks[ "specialty_fastreload" ].angles = ( 0, 54.5, 0 );
	level.crazyplacePerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
	level.crazyplacePerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
	level.crazyplacePerks[ "specialty_quickrevive" ] = spawnstruct();
	level.crazyplacePerks[ "specialty_quickrevive" ].origin = ( 10728, -7107, -443.75 );
	level.crazyplacePerks[ "specialty_quickrevive" ].angles = ( 0, 27, 0 );
	level.crazyplacePerks[ "specialty_quickrevive" ].model = "p6_zm_al_vending_nuke_on";
	level.crazyplacePerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
	level.crazyplacePerks[ "specialty_armorvest" ] = spawnstruct();
	level.crazyplacePerks[ "specialty_armorvest" ].origin = ( 9986, -8815.25, -451.75 );
	level.crazyplacePerks[ "specialty_armorvest" ].angles = ( 0, 194, 0 );
	level.crazyplacePerks[ "specialty_armorvest" ].model = "p6_zm_al_vending_nuke_on";
	level.crazyplacePerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
	level.crazyplacePerks[ "specialty_longersprint" ] = spawnstruct();
	level.crazyplacePerks[ "specialty_longersprint" ].origin = ( 10853.9, -8289.79, -447.75 );
	level.crazyplacePerks[ "specialty_longersprint" ].angles = ( 0, 178, 0 );
	level.crazyplacePerks[ "specialty_longersprint" ].model = "p6_zm_al_vending_nuke_on";
	level.crazyplacePerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
	level.crazyplacePerks[ "specialty_weapupgrade" ] = spawnstruct();
	level.crazyplacePerks[ "specialty_weapupgrade" ].origin = ( 10781.6, -7873.87, -463.875 );
	level.crazyplacePerks[ "specialty_weapupgrade" ].angles = ( 0, 274.026, 0 );
	level.crazyplacePerks[ "specialty_weapupgrade" ].model = "p6_zm_tm_packapunch";
	level.crazyplacePerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
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
					if(is_true(level.customMap == "trenches") )
					{
						if(structs[i].script_noteworthy == "specialty_armorvest" || structs[i].script_noteworthy == "specialty_longersprint")
							structs[i] Delete();
						else
							pos[ pos.size ] = structs[ i ];
					}
					else if( is_true(level.customMap == "crazyplace") )
					{
						if(structs[i].script_noteworthy == "specialty_armorvest" || structs[i].script_noteworthy == "specialty_longersprint" || structs[i].script_noteworthy == "specialty_rof" || structs[i].script_noteworthy == "specialty_quickrevive" || structs[i].script_noteworthy == "specialty_fastreload" )
							structs[i] Delete();
						else
							pos[ pos.size ] = structs[ i ];
					}
					else if( is_true(level.customMap == "excavation") )
					{
						if(structs[i].script_noteworthy == "specialty_weapupgrade" || structs[i].script_noteworthy == "specialty_quickrevive" || structs[i].script_noteworthy == "specialty_fastreload" )
							structs[i] Delete();
						else
							pos[ pos.size ] = structs[ i ];
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
	if ( isDefined( level.customMap ) && level.customMap == "trenches" && isdefined(level.disableBSMMagic) && !level.disableBSMMagic )
	{
		foreach ( perk in level.trenchesPerkArray )
		{
			pos[ pos.size ] = level.trenchesPerks[ perk ];
		}
	}
	else if ( isDefined( level.customMap ) && level.customMap == "excavation" )
	{
		foreach ( perk in level.excavationPerkArray )
		{
			pos[ pos.size ] = level.excavationPerks[ perk ];
		}
	}
	else if ( isDefined( level.customMap ) && level.customMap == "tank" )
	{
		foreach ( perk in level.tankPerkArray )
		{
			pos[ pos.size ] = level.tankPerks[ perk ];
		}
	}
	else if ( isDefined( level.customMap ) && level.customMap == "crazyplace" && isdefined(level.disableBSMMagic) && !level.disableBSMMagic )
	{
		foreach ( perk in level.crazyplacePerkArray )
		{
			pos[ pos.size ] = level.crazyplacePerks[ perk ];
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