#include maps/mp/zm_prison_sq_wth;
#include maps/mp/zm_prison_sq_fc;
#include maps/mp/zm_prison_sq_final;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zm_alcatraz_travel;
#include maps/mp/zm_alcatraz_traps;
#include maps/mp/zm_prison;
#include maps/mp/zm_alcatraz_sq;
#include maps/mp/zm_prison_sq_bg;
#include maps/mp/zm_prison_spoon;
#include maps/mp/zm_prison_achievement;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/gametypes_zm/_zm_gametype;
#include maps/mp/zombies/_zm_afterlife;
#include maps/mp/zombies/_zm_ai_brutus;
#include maps/mp/zm_alcatraz_craftables;
#include maps/mp/zombies/_zm_craftables;
#include maps/mp/zm_alcatraz_utility;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zm_alcatraz_classic;
#include maps/mp/zm_prison;
#include maps/mp/zombies/_zm_blockers;

main()
{
	if(GetDvar("customMap") == "vanilla") return;
	replacefunc(maps/mp/zm_alcatraz_classic::give_afterlife, ::give_afterlife);
	replacefunc(maps/mp/zombies/_zm_ai_brutus::init, ::init_brutus);
	replacefunc(maps/mp/zombies/_zm_blockers::door_think, ::door_think);
	replacefunc(maps/mp/zm_alcatraz_craftables::include_craftables, ::include_craftables);
}

init()
{
	if(level.customMap == "vanilla")
		return;
	map = level.customMap;
	if ( isDefined(map) && map == "rooftop" )
	{
		level.electric_chair_player_thread_custom_func = ::custom_electric_chair_player_thread;
		level.track_quest_status_thread_custom_func = ::bridge_reset;
	}
	if(isDefined(map) && map == "docks")
	{
		thread acid_bench( map, (751, 6572, 210), (0,191,0) );
	}
	if(isDefined(map) && map != "vanilla")
	{
		level thread onplayerconnect();
		level thread onplayerconnected();
		level thread map_setup();
	}
	level.callbackactordamage = ::actor_damage_override_wrapper;
	level._callbacks[ "on_player_connect" ][ 16 ] = ::player_lightning_manager_override;
}

player_lightning_manager_override()
{
	self setclientfieldtoplayer( "toggle_lightning", 0 );
}

door_think() //checked changed to match cerberus output
{
	self endon( "kill_door_think" );
	cost = 1000;
	if ( isDefined( self.zombie_cost ) )
	{
		cost = self.zombie_cost;
	}
	self sethintlowpriority( 1 );
	while ( 1 )
	{
		switch ( self.script_noteworthy )
		{
			case "local_electric_door":
				if ( !is_true( self.local_power_on ) )
				{
					self waittill( "local_power_on" );
				}
				if ( !is_true( self._door_open ) )
				{
					/*
/#
					println( "ZM BLOCKER local door opened\n" );
#/
					*/
					self door_opened( cost, 1 );
					if ( !isDefined( self.power_cost ) )
					{
						self.power_cost = 0;
					}
					self.power_cost += 200;
				}
				self sethintstring( "" );
				if ( is_true( level.local_doors_stay_open ) )
				{
					return;
				}
				wait 3;
				self waittill_door_can_close();
				self door_block();
				if ( is_true( self._door_open ) )
				{
					/*
/#
					println( "ZM BLOCKER local door closed\n" );
#/
					*/
					self door_opened( cost, 1 );
				}
				self sethintstring( &"ZOMBIE_NEED_LOCAL_POWER" );
				wait 3;
				continue;
			case "electric_door":
				if ( !is_true( self.power_on ) )
				{
					self waittill( "power_on" );
				}
				if ( !is_true( self._door_open ) )
				{
					/*
/#
					println( "ZM BLOCKER global door opened\n" );
#/
					*/
					self door_opened( cost, 1 );
					if ( !isDefined( self.power_cost ) )
					{
						self.power_cost = 0;
					}
					self.power_cost += 200;
				}
				self sethintstring( "" );
				if ( is_true( level.local_doors_stay_open ) )
				{
					return;
				}
				wait 3;
				self waittill_door_can_close();
				self door_block();
				if ( is_true( self._door_open ) )
				{
					/*
/#
					println( "ZM BLOCKER global door closed\n" );
#/
					*/
					self door_opened( cost, 1 );
				}
				self sethintstring( &"ZOMBIE_NEED_POWER" );
				wait 3;
				continue;
			case "electric_buyable_door":
				flag_wait( "power_on" );
				self set_hint_string( self, "default_buy_door", cost );
				if ( !self door_buy() )
				{
					continue;
				}
				break;
			case "delay_door":
				if ( !self door_buy() )
				{
					continue;
				}
				self door_delay();
				break;
			default:
				if ( isDefined( level._default_door_custom_logic ) )
				{
					self alcatraz_afterlife_doors();
					break;
				}
				if ( !self door_buy() )
				{
					continue;
				}
				break;
			}
			self door_opened( cost );
			if ( !flag( "door_can_close" ) )
			{
				break;
			}
	}
}

include_craftables()
{
	level.zombie_include_craftables[ "open_table" ].custom_craftablestub_update_prompt = ::prison_open_craftablestub_update_prompt;
	craftable_name = "alcatraz_shield_zm";
	riotshield_dolly = generate_zombie_craftable_piece( craftable_name, "dolly", "t6_wpn_zmb_shield_dlc2_dolly", 32, 64, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_riotshield_dolly", 1, "build_zs" );
	riotshield_door = generate_zombie_craftable_piece( craftable_name, "door", "t6_wpn_zmb_shield_dlc2_door", 48, 15, 25, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_riotshield_door", 1, "build_zs" );
	riotshield_clamp = generate_zombie_craftable_piece( craftable_name, "clamp", "t6_wpn_zmb_shield_dlc2_shackles", 32, 15, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_riotshield_clamp", 1, "build_zs" );
	riotshield = spawnstruct();
	riotshield.name = craftable_name;
	riotshield add_craftable_piece( riotshield_dolly );
	riotshield add_craftable_piece( riotshield_door );
	riotshield add_craftable_piece( riotshield_clamp );
	riotshield.onbuyweapon = ::onbuyweapon_riotshield;
	riotshield.triggerthink = ::riotshieldcraftable;
	include_craftable( riotshield );
	craftable_name = "packasplat";
	packasplat_case = generate_zombie_craftable_piece( craftable_name, "case", "p6_zm_al_packasplat_suitcase", 48, 36, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_packasplat_case", 1, "build_bsm" );
	packasplat_fuse = generate_zombie_craftable_piece( craftable_name, "fuse", "p6_zm_al_packasplat_engine", 32, 36, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_packasplat_fuse", 1, "build_bsm" );
	packasplat_blood = generate_zombie_craftable_piece( craftable_name, "blood", "p6_zm_al_packasplat_iv", 32, 15, 0, undefined, ::onpickup_common, ::ondrop_common, undefined, undefined, undefined, undefined, "piece_packasplat_blood", 1, "build_bsm" );
	packasplat = spawnstruct();
	packasplat.name = craftable_name;
	packasplat add_craftable_piece( packasplat_case );
	packasplat add_craftable_piece( packasplat_fuse );
	packasplat add_craftable_piece( packasplat_blood );
	packasplat.triggerthink = ::packasplatcraftable;
	include_craftable( packasplat );
	include_key_craftable( "quest_key1", "p6_zm_al_key" );
	craftable_name = "plane";
	plane_cloth = generate_zombie_craftable_piece( craftable_name, "cloth", "p6_zm_al_clothes_pile_lrg", 48, 15, 0, undefined, ::onpickup_plane, ::ondrop_plane, ::oncrafted_plane, undefined, "tag_origin", undefined, 1 );
	plane_fueltanks = generate_zombie_craftable_piece( craftable_name, "fueltanks", "veh_t6_dlc_zombie_part_fuel", 32, 15, 0, undefined, ::onpickup_plane, ::ondrop_plane, ::oncrafted_plane, undefined, "tag_feul_tanks", undefined, 2 );
	plane_engine = generate_zombie_craftable_piece( craftable_name, "engine", "veh_t6_dlc_zombie_part_engine", 32, 62, 0, undefined, ::onpickup_plane, ::ondrop_plane, ::oncrafted_plane, undefined, "tag_origin", undefined, 3 );
	plane_steering = generate_zombie_craftable_piece( craftable_name, "steering", "veh_t6_dlc_zombie_part_control", 32, 15, 0, undefined, ::onpickup_plane, ::ondrop_plane, ::oncrafted_plane, undefined, "tag_control_mechanism", undefined, 4 );
	plane_rigging = generate_zombie_craftable_piece( craftable_name, "rigging", "veh_t6_dlc_zombie_part_rigging", 32, 15, 0, undefined, ::onpickup_plane, ::ondrop_plane, ::oncrafted_plane, undefined, "tag_origin", undefined, 5 );
	plane_cloth.is_shared = 1;
	plane_fueltanks.is_shared = 1;
	plane_engine.is_shared = 1;
	plane_steering.is_shared = 1;
	plane_rigging.is_shared = 1;
	plane_cloth.client_field_state = undefined;
	plane_fueltanks.client_field_state = undefined;
	plane_engine.client_field_state = undefined;
	plane_steering.client_field_state = undefined;
	plane_rigging.client_field_state = undefined;
	plane_cloth.pickup_alias = "sidequest_sheets";
	plane_fueltanks.pickup_alias = "sidequest_oxygen";
	plane_engine.pickup_alias = "sidequest_engine";
	plane_steering.pickup_alias = "sidequest_valves";
	plane_rigging.pickup_alias = "sidequest_rigging";
	plane = spawnstruct();
	plane.name = craftable_name;
	plane add_craftable_piece( plane_cloth );
	plane add_craftable_piece( plane_engine );
	plane add_craftable_piece( plane_fueltanks );
	plane add_craftable_piece( plane_steering );
	plane add_craftable_piece( plane_rigging );
	plane.triggerthink = ::planecraftable;
	plane.custom_craftablestub_update_prompt = ::prison_plane_update_prompt;
	include_craftable( plane );
	craftable_name = "refuelable_plane";
	refuelable_plane_gas1 = generate_zombie_craftable_piece( craftable_name, "fuel1", "accessories_gas_canister_1", 32, 15, 0, undefined, ::onpickup_fuel, ::ondrop_fuel, ::oncrafted_fuel, undefined, undefined, undefined, 6 );
	refuelable_plane_gas2 = generate_zombie_craftable_piece( craftable_name, "fuel2", "accessories_gas_canister_1", 32, 15, 0, undefined, ::onpickup_fuel, ::ondrop_fuel, ::oncrafted_fuel, undefined, undefined, undefined, 7 );
	refuelable_plane_gas3 = generate_zombie_craftable_piece( craftable_name, "fuel3", "accessories_gas_canister_1", 32, 15, 0, undefined, ::onpickup_fuel, ::ondrop_fuel, ::oncrafted_fuel, undefined, undefined, undefined, 8 );
	refuelable_plane_gas4 = generate_zombie_craftable_piece( craftable_name, "fuel4", "accessories_gas_canister_1", 32, 15, 0, undefined, ::onpickup_fuel, ::ondrop_fuel, ::oncrafted_fuel, undefined, undefined, undefined, 9 );
	refuelable_plane_gas5 = generate_zombie_craftable_piece( craftable_name, "fuel5", "accessories_gas_canister_1", 32, 15, 0, undefined, ::onpickup_fuel, ::ondrop_fuel, ::oncrafted_fuel, undefined, undefined, undefined, 10 );
	refuelable_plane_gas1.is_shared = 1;
	refuelable_plane_gas2.is_shared = 1;
	refuelable_plane_gas3.is_shared = 1;
	refuelable_plane_gas4.is_shared = 1;
	refuelable_plane_gas5.is_shared = 1;
	refuelable_plane_gas1.client_field_state = undefined;
	refuelable_plane_gas2.client_field_state = undefined;
	refuelable_plane_gas3.client_field_state = undefined;
	refuelable_plane_gas4.client_field_state = undefined;
	refuelable_plane_gas5.client_field_state = undefined;
	refuelable_plane = spawnstruct();
	refuelable_plane.name = craftable_name;
	refuelable_plane add_craftable_piece( refuelable_plane_gas1 );
	refuelable_plane add_craftable_piece( refuelable_plane_gas2 );
	refuelable_plane add_craftable_piece( refuelable_plane_gas3 );
	refuelable_plane add_craftable_piece( refuelable_plane_gas4 );
	refuelable_plane add_craftable_piece( refuelable_plane_gas5 );
	refuelable_plane.triggerthink = ::planefuelable;
	plane.custom_craftablestub_update_prompt = ::prison_plane_update_prompt;
	include_craftable( refuelable_plane );
}

alcatraz_afterlife_doors() //checked changed to match cerberus output
{
	wait 0.05;
	if ( !isDefined( level.shockbox_anim ) )
	{
		level.shockbox_anim[ "on" ] = %fxanim_zom_al_shock_box_on_anim;
		level.shockbox_anim[ "off" ] = %fxanim_zom_al_shock_box_off_anim;
	}
	if ( isDefined( self.script_noteworthy ) && self.script_noteworthy == "afterlife_door" )
	{
		self sethintstring( &"ZM_PRISON_AFTERLIFE_DOOR" );
		if ( isDefined ( level.customMap ) && level.customMap == "cellblock" || isDefined ( level.customMap ) && level.customMap == "rooftop" )
		{
			if ( self.origin != ( 2138, 9210, 1375 ) )
			{
				self maps/mp/zombies/_zm_blockers::door_opened( 0 );
			}
		}
		/*
/#
		self thread afterlife_door_open_sesame();
#/
		*/
		s_struct = getstruct( self.target, "targetname" );
		if ( !isDefined( s_struct ) )
		{
			/*
/#
			iprintln( "Afterlife Door was not targeting a valid struct" );
#/
			*/
			return;
		}
		m_shockbox = getent( s_struct.target, "targetname" );
		m_shockbox.health = 5000;
		m_shockbox setcandamage( 1 );
		m_shockbox useanimtree( -1 );
		t_bump = spawn( "trigger_radius", m_shockbox.origin, 0, 28, 64 );
		t_bump.origin = ( ( m_shockbox.origin + ( anglesToForward( m_shockbox.angles ) * 0 ) ) + ( anglesToRight( m_shockbox.angles ) * 28 ) ) + ( anglesToUp( m_shockbox.angles ) * 0 );
		if ( isDefined( t_bump ) )
		{
			t_bump setcursorhint( "HINT_NOICON" );
			t_bump sethintstring( &"ZM_PRISON_AFTERLIFE_INTERACT" );
		}
		while ( 1 )
		{
			m_shockbox waittill( "damage", amount, attacker );
			if ( isplayer( attacker ) && attacker getcurrentweapon() == "lightning_hands_zm" )
			{
				if ( isDefined( level.afterlife_interact_dist ) )
				{
					if ( distance2d( attacker.origin, m_shockbox.origin ) < level.afterlife_interact_dist )
					{
						t_bump delete();
						m_shockbox playsound( "zmb_powerpanel_activate" );
						playfxontag( level._effect[ "box_activated" ], m_shockbox, "tag_origin" );
						m_shockbox setmodel( "p6_zm_al_shock_box_on" );
						m_shockbox setanim( level.shockbox_anim[ "on" ] );
						if ( ( m_shockbox.script_string == "wires_shower_door" || m_shockbox.script_string == "wires_admin_door" ) && isDefined( m_shockbox.script_string ) )
						{
							array_delete( getentarray( m_shockbox.script_string, "script_noteworthy" ) );
						}
						self maps/mp/zombies/_zm_blockers::door_opened( 0 );
						attacker notify( "player_opened_afterlife_door" );
						break;
					}
				}
			}
		}
	}
	while ( 1 )
	{
		if ( !self maps/mp/zombies/_zm_blockers::door_buy() )
		{
			wait 0.05;
			continue;
		}
		break;
	}
}

map_setup()
{
	map = level.customMap;
	thread disable_afterlife_boxes();
	if ( level.script == "zm_prison" && isDefined( map ) && map == "docks" )
	{
		thread auto_upgrade_tower();
		thread disable_gondola();
		thread disable_doors_docks();
	}
	else if ( isdefined(map) && map == "showers")
	{
		thread disable_doors_showers();
	}
	else if ( level.script == "zm_prison" && isDefined( map ) && map == "cellblock" )
	{
		thread disable_doors_cellblock();
	}
	else if ( level.script == "zm_prison" && isDefined( map ) && map == "rooftop" )
	{
		thread disable_doors_cellblock();
	}
}

onplayerconnect()
{
	level waittill( "connected", player );
	maps/mp/zombies/_zm_game_module::turn_power_on_and_open_doors();
	wait 1;
	flag_set( "power_on" );
	level setclientfield( "zombie_power_on", 1 );
	level notify( "sleight_on" );
	wait_network_frame();
	level notify( "doubletap_on" );
	wait_network_frame();
	level notify( "juggernog_on" );
	wait_network_frame();
	level notify( "electric_cherry_on" );
	wait_network_frame();
	level notify( "deadshot_on" );
	wait_network_frame();
	level notify( "divetonuke_on" );
	wait_network_frame();
	level notify( "additionalprimaryweapon_on" );
	wait_network_frame();
	level notify( "Pack_A_Punch_on" );
	wait_network_frame();
}
onplayerconnected()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread afterlife_doors_close();
	}
}

acid_bench(map, origin, angles)
{
	level endon("end_game");
	//level.soulFX = loadfx("fx_alcatraz_soul_charge");
	level.soulDistance = 400;
	bench = spawn("script_model", origin);
	bench SetModel("p6_zm_work_bench");
	bench.angles = angles;
	bench.souls = 0;
	//do these for every map separately
	if(isDefined(map) && map == "docks")
	{
		col = spawn("script_model", (758, 6589, 242));
		col SetModel("collision_clip_64x64x64");
		col.angles = angles;
		col2 = spawn("script_model", (764, 6554, 242));
		col2 SetModel("collision_clip_64x64x64");
		col2.angles = angles;
	}
	acidGatModel = spawn("script_model", origin + (0,0,45));
	acidGatModel SetModel("p6_anim_zm_al_packasplat");
	acidGatModel.angles = angles;
	trigger = spawn("trigger_radius", origin + (0,0,32), 0, 35, 70);
	trigger.targetname = "acid_gat_trigger";
	trigger.angles = angles;
	trigger SetHintString("This Machine Needs Power");
	trigger SetCursorHint("HINT_NOICON");
	thread watchZombies(bench);
	level waittill("soulsAreDone");
	wait 2;
	trigger SetHintString("Hold ^3&&1^7 to convert Blundergat into Acidgat");
	for(;;)
	{
		trigger waittill("trigger", player);
		if(player UseButtonPressed())
		{
			weap = player GetCurrentWeapon();
			if(weap == "blundergat_zm" || weap == "blundergat_upgraded_zm")
			{
				if(weap == "blundergat_zm")
				{
					player TakeWeapon("blundergat_zm");
				}
				else if(weap == "blundergat_upgraded_zm")
				{
					player TakeWeapon("blundergat_upgraded_zm");
				}
				trigger SetHintString("Converting...");
				wait 5;
				trigger SetHintString("Hold ^3&&1^7 for Acidgat");
				for(;;)
				{
					if(player UseButtonPressed() && Distance(player.origin, trigger.origin) < 65)
					{
						if(weap == "blundergat_zm")
						{
							player GiveWeapon("blundersplat_zm");
							player SwitchToWeapon("blundersplat_zm");
							break;
						}
						else if(weap == "blundergat_upgraded_zm")
						{
							player GiveWeapon("blundersplat_upgraded_zm");
							player SwitchToWeapon("blundersplat_upgraded_zm");
							break;
						}
					}
					wait .1;
				}
			}
		}
		wait .1;
		trigger SetHintString("Hold ^3&&1^7 to convert Blundergat into Acidgat");
	}
}

watchZombies(bench)
{
	level endon("soulsAreDone");
	while(1)
	{
		zombies = GetAiSpeciesArray( "axis", "all" );
		for(i=0;i<zombies.size;i++)
		{
			if(!isdefined(zombies[i].soulChest))
				zombies[i] thread watchMe(bench);
		}
		wait(.05);
	}
}

watchMe(bench)
{
	level endon("soulsAreDone");
	self.soulChest = true;
	//IPrintLn("A zombie has been threaded");
	self waittill("death");
	if(!isdefined(self))
	{
		return;
	}
	start = self.origin + (0,0,45);
	if(!isdefined(start))
	{
		return;
	}
	closest = level.soulDistance;
	newbench = undefined;
	if(Distance(start, bench.origin) < closest )
	{
		closest = Distance(start, bench.origin);
		newbench = bench;
	}
	if(!isDefined(newbench) || !isDefined(newbench.origin))
	{
		return;
	}
	bench.souls++;
	//IPrintLn(bench.souls);
	newbench thread sendSoul(start);
	if(bench.souls >= 15)
	{
		level notify("soulsAreDone");
	}
}

sendSoul(start)
{
	if(isdefined(self))
	{
		end = self.origin + (0,0,45);
	}
	if(!isdefined(start) || !isdefined(end))
	{
		return;
	}
	fxOrg = Spawn("script_model", start);
	fxOrg SetModel("tag_origin");
	fx = PlayFxOnTag( level._effect[ "powerup_on" ], fxOrg, "tag_origin" );
	fxOrg MoveTo(end, 2);
	wait 2;
	fx Delete();
	fxOrg Delete();
}

give_afterlife() //checked changed to match cerberus output
{
	
}

init_brutus() //checked changed to match cerberus output
{
	if(isdefined(level.customMap) && level.customMap != "vanilla" && !GetDvarIntDefault("useBossZombies", 1))
	{
		registerclientfield( "actor", "helmet_off", 9000, 1, "int" );
		registerclientfield( "actor", "brutus_lock_down", 9000, 1, "int" );
		flag_set( "brutus_setup_complete" );
		return;
	}
	level.brutus_spawners = getentarray( "brutus_zombie_spawner", "script_noteworthy" );
	if ( level.brutus_spawners.size == 0 )
	{
		return;
	}
	array_thread( level.brutus_spawners, ::add_spawn_function, ::brutus_prespawn );
	for ( i = 0; i < level.brutus_spawners.size; i++ )
	{
		level.brutus_spawners[ i ].is_enabled = 1;
		level.brutus_spawners[ i ].script_forcespawn = 1;
	}
	level.brutus_spawn_positions = getstructarray( "brutus_location", "script_noteworthy" );
	level thread setup_interaction_matrix();
	level.sndbrutusistalking = 0;
	level.brutus_health = 500;
	level.brutus_health_increase = 1000;
	level.brutus_round_count = 0;
	level.brutus_last_spawn_round = 0;
	level.brutus_count = 0;
	level.brutus_max_count = 1;
	level.brutus_damage_percent = 0.1;
	level.brutus_helmet_shots = 5;
	level.brutus_team_points_for_death = 500;
	level.brutus_player_points_for_death = 250;
	level.brutus_points_for_helmet = 250;
	level.brutus_alarm_chance = 100;
	level.brutus_min_alarm_chance = 100;
	level.brutus_alarm_chance_increment = 10;
	level.brutus_max_alarm_chance = 200;
	level.brutus_min_round_fq = 4;
	level.brutus_max_round_fq = 7;
	level.brutus_reset_dist_sq = 262144;
	level.brutus_aggro_dist_sq = 16384;
	level.brutus_aggro_earlyout = 12;
	level.brutus_blocker_pieces_req = 1;
	level.brutus_zombie_per_round = 1;
	level.brutus_players_in_zone_spawn_point_cap = 120;
	level.brutus_teargas_duration = 7;
	level.player_teargas_duration = 2;
	level.brutus_teargas_radius = 64;
	level.num_pulls_since_brutus_spawn = 0;
	level.brutus_min_pulls_between_box_spawns = 4;
	level.brutus_explosive_damage_for_helmet_pop = 1500;
	level.brutus_explosive_damage_increase = 600;
	level.brutus_failed_paths_to_teleport = 4;
	level.brutus_do_prologue = 1;
	level.brutus_min_spawn_delay = 10;
	level.brutus_max_spawn_delay = 60;
	level.brutus_respawn_after_despawn = 1;
	level.brutus_in_grief = 0;
	if ( getDvar( "ui_gametype" ) == "zgrief" )
	{
		level.brutus_in_grief = 1;
	}
	level.brutus_shotgun_damage_mod = 1.5;
	level.brutus_custom_goalradius = 48;
	registerclientfield( "actor", "helmet_off", 9000, 1, "int" );
	registerclientfield( "actor", "brutus_lock_down", 9000, 1, "int" );
	level thread maps/mp/zombies/_zm_ai_brutus::brutus_spawning_logic();
	if ( !level.brutus_in_grief )
	{
		level thread maps/mp/zombies/_zm_ai_brutus::get_brutus_interest_points();
		/*
/#
		setup_devgui();
#/
		*/
		level.custom_perk_validation = ::check_perk_machine_valid;
		level.custom_craftable_validation = ::check_craftable_table_valid;
		level.custom_plane_validation = ::check_plane_valid;
	}
}

custom_electric_chair_player_thread( m_linkpoint, chair_number, n_effects_duration )
{
	logprint("using custom electric chair thread");
	self endon( "death_or_disconnect" );
	e_home_telepoint = getstruct( "home_telepoint_" + chair_number, "targetname" );
	e_corpse_location = getstruct( "corpse_starting_point_" + chair_number, "targetname" );
	self disableweapons();
	self enableinvulnerability();
	self setstance( "stand" );
	self playerlinktodelta( m_linkpoint, "tag_origin", 1, 20, 20, 20, 20 );
	self setplayerangles( m_linkpoint.angles );
	self playsoundtoplayer( "zmb_electric_chair_2d", self );
	self do_player_general_vox( "quest", "chair_electrocution", undefined, 100 );
	self ghost();
	self.ignoreme = 1;
	self.dontspeak = 1;
	self setclientfieldtoplayer( "isspeaking", 1 );
	wait ( n_effects_duration - 2 );
	switch( self.character_name )
	{
		case "Arlington":
			self playsoundontag( "vox_plr_3_arlington_electrocution_0", "J_Head" );
			break;
		case "Sal":
			self playsoundontag( "vox_plr_1_sal_electrocution_0", "J_Head" );
			break;
		case "Billy":
			self playsoundontag( "vox_plr_2_billy_electrocution_0", "J_Head" );
			break;
		case "Finn":
			self playsoundontag( "vox_plr_0_finn_electrocution_0", "J_Head" );
			break;
	}
	wait 2;
	level.zones[ "zone_golden_gate_bridge" ].is_enabled = 1;
	level.zones[ "zone_golden_gate_bridge" ].is_spawning_allowed = 1;
	self unlink();
	self setstance( "stand" );
	if ( chair_number == 0 )
	{
		self setorigin( ( 2282.9, 9557.3, 1792 ) );
	}
	else if ( chair_number == 1 )
	{
		self setorigin( ( 2304.65, 10019, 1792 ) );
	}
	else if ( chair_number == 2 )
	{
		self setorigin( ( 2642.4, 10023.6, 1792 ) );
	}
	else if ( chair_number == 3 )
	{
		self setorigin( ( 2290.6, 9444.3, 1792 ) );
	}
	else if ( chair_number == 4 )
	{
		self setorigin( ( 2436.5, 9394.1, 1792 ) );
	}
	else if ( chair_number == 5 )
	{
		self setorigin( ( 2540.81, 9263.64, 1792 ) );
	}
	self enableweapons();
	self setclientfieldtoplayer( "rumble_electric_chair", 0 );
	wait 1.5;
	//level thread bridge_reset();
	self disableinvulnerability();
	self Show();
	self.ignoreme = 0;
	self.dontspeak = 0;
}

bridge_reset()
{
	logprint("using bridge reset thread");
	while(1)
	{
		while( level.characters_in_nml.size == 0)
		{
			wait 1;
		}
		while (level.characters_in_nml.size > 0)
		{
			wait 1;
		}
		if( flag( "plane_trip_to_nml_successful" ) )
		{
			flag_clear( "plane_trip_to_nml_successful" );
		}
		/*
		level.players_on_bridge = 0;
		foreach ( player in level.players )
		{
			player.zone = player get_current_zone();
			if( maps/mp/zombies/_zm_utility::is_player_valid( player ) && player.zone == "zone_golden_gate_bridge" )
			{
				level.players_on_bridge++;
			}
		}*/
		//if ( level.players_on_bridge == 0 )
		//{
		level notify( "bridge_empty" );
		level waittill( "start_of_round" );
		prep_for_new_quest();
		waittill_crafted( "refuelable_plane" );
		maps/mp/zombies/_zm_ai_brutus::transfer_plane_trigger( "fuel", "fly" );
		t_plane_fly = getent( "plane_fly_trigger", "targetname" );
		t_plane_fly trigger_on();
		wait 1;
		//}
	}
}

auto_upgrade_tower()
{
	level endon( "end_game");
	level endon( "tower_disabled" );

	level.enableTowerUpgrade = getDvarIntDefault( "enableTowerUpgrade", 0 );
	level.zombie_vars[ "enableTowerUpgrade" ] = level.enableTowerUpgrade;

	if ( !level.enableTowerUpgrade )
	{
		level notify ( "tower_disabled" );
	}
	while ( 1 )
	{
		level waittill( "trap_activated" );
		wait 2;
		level notify( "tower_trap_upgraded" );
	}
}

disable_gondola()
{
	wait 7;
	level notify( "gondola_powered_on_roof" );
	t_call_triggers = getentarray( "gondola_call_trigger", "targetname" );
	call_triggers = getFirstArrayKey( t_call_triggers );
	while ( isDefined( call_triggers ) )
	{
		trigger = t_call_triggers[ call_triggers ];
		trigger.origin = ( 0, 0, 0 );
		return;
	}
}

disable_doors_docks()
{
	zm_doors = getentarray( "zombie_door", "targetname" );
	i = 0;
	while ( i < zm_doors.size )
	{
		if ( zm_doors[ i ].origin == ( 101, 8124, 311 ) )
		{
			zm_doors[ i ].origin = ( 0, 0, 0 );
		}
		i++;
	}
}

disable_doors_showers()
{
	zm_doors = getentarray( "zombie_door", "targetname" );
	i = 0;
	while ( i < zm_doors.size )
	{
		if ( zm_doors[ i ].origin == (1227, 9983, 1170) )
		{
			zm_doors[ i ].origin = ( 0, 0, 0 );
		}
		i++;
	}
}

disable_doors_cellblock()
{
	zm_doors = getentarray( "zombie_door", "targetname" );
	i = 0;
	while ( i < zm_doors.size )
	{
		if ( zm_doors[ i ].origin == ( 2429, 9793, 1374 ) || zm_doors[ i ].origin == ( 2281, 9484, 1564 ) || zm_doors[ i ].origin == ( -149, 8679, 1166 ) )
		{
			zm_doors[ i ].origin = ( 0, 0, 0 );
		}
		i++;
	}
}

disable_afterlife_boxes()
{
	a_afterlife_triggers = getstructarray( "afterlife_trigger", "targetname" );
	_a87 = a_afterlife_triggers;
	_k87 = getFirstArrayKey( _a87 );
	while ( isDefined( _k87 ) )
	{
		struct = _a87[ _k87 ];
		struct.unitrigger_stub.origin = ( 0, 0, 0 );
		_k87 = getNextArrayKey( _a87, _k87 );
	}
}

actor_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) //checked changed to match cerberus output //checked against bo3 _zm.gsc partially changed to match
{
	if ( !isDefined( self ) || !isDefined( attacker ) )
	{
		return damage;
	}
	if ( weapon == "tazer_knuckles_zm" || weapon == "jetgun_zm" )
	{
		self.knuckles_extinguish_flames = 1;
	}
	else if ( weapon != "none" )
	{
		self.knuckles_extinguish_flames = undefined;
	}
	if ( isDefined( attacker.animname ) && attacker.animname == "quad_zombie" )
	{
		if ( isDefined( self.animname ) && self.animname == "quad_zombie" )
		{
			return 0;
		}
	}
	if ( !isplayer( attacker ) && isDefined( self.non_attacker_func ) )
	{
		if ( isDefined( self.non_attack_func_takes_attacker ) && self.non_attack_func_takes_attacker )
		{
			return self [[ self.non_attacker_func ]]( damage, weapon, attacker );
		}
		else
		{
			return self [[ self.non_attacker_func ]]( damage, weapon );
		}
	}
	if ( !isplayer( attacker ) && !isplayer( self ) )
	{
		return damage;
	}
	if ( !isDefined( damage ) || !isDefined( meansofdeath ) )
	{
		return damage;
	}
	if ( meansofdeath == "" )
	{
		return damage;
	}
	old_damage = damage;
	final_damage = damage;
	if ( isDefined( self.actor_damage_func ) )
	{
		final_damage = [[ self.actor_damage_func ]]( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	}
	if ( attacker.classname == "script_vehicle" && isDefined( attacker.owner ) )
	{
		attacker = attacker.owner;
	}
	if ( isDefined( self.in_water ) && self.in_water )
	{
		if ( int( final_damage ) >= self.health )
		{
			self.water_damage = 1;
		}
	}
	attacker thread maps/mp/gametypes_zm/_weapons::checkhit( weapon );
	if ( attacker maps/mp/zombies/_zm_pers_upgrades_functions::pers_mulit_kill_headshot_active() && is_headshot( weapon, shitloc, meansofdeath ) )
	{
		final_damage *= 2;
	}
	if ( is_true( level.headshots_only ) && isDefined( attacker ) && isplayer( attacker ) )
	{
		//changed to match bo3 _zm.gsc behavior
		if ( meansofdeath == "MOD_MELEE" && shitloc == "head" || meansofdeath == "MOD_MELEE" && shitloc == "helmet" )
		{
			return int( final_damage );
		}
		if ( is_explosive_damage( meansofdeath ) )
		{
			return int( final_damage );
		}
		else if ( !is_headshot( weapon, shitloc, meansofdeath ) )
		{
			return 0;
		}
	}
	if ( self.animname != "brutus_zombie" )
	{
		if ( weapon == "minigun_alcatraz_zm" )
		{
			final_damage = ( self.health * 0.24 ) + 666;
		}
		else if ( weapon == "minigun_alcatraz_upgraded_zm" )
		{
			final_damage = ( self.health * 0.29 ) + 666;
		}
		if ( is_true( level.zombiemode_using_deadshot_perk ) && isDefined( attacker ) && isPlayer( attacker ) && attacker hasPerk( "specialty_deadshot" ) && is_headshot( weapon, shitloc, meansofdeath ) )
		{
			final_damage *= 2;
		}
	}
	else if ( self.animname == "brutus_zombie" )
	{
		final_damage /= 3;
	}
	return int( final_damage );
}

actor_damage_override_wrapper( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) //checked does not match cerberus output did not change
{
	damage_override = self actor_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	if ( ( self.health - damage_override ) > 0 || !is_true( self.dont_die_on_me ) )
	{
		self finishactordamage( inflictor, attacker, damage_override, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	}
	else 
	{
		self [[ level.callbackactorkilled ]]( inflictor, attacker, damage, meansofdeath, weapon, vdir, shitloc, psoffsettime );
		self finishactordamage( inflictor, attacker, damage_override, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	}
}