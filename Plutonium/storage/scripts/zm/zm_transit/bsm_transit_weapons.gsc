#include maps/mp/zombies/_zm_weap_cymbal_monkey;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/zombies/_zm_equipment;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_melee_weapon;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/gametypes_zm/_weaponobjects;
#include maps/mp/zombies/_zm_magicbox;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_weap_claymore;
#include maps/mp/zombies/_zm_weap_ballistic_knife;
#include maps/mp/zombies/_zm_weapons;

main()
{
	replacefunc(maps/mp/zombies/_zm_weapons::init_spawnable_weapon_upgrade, ::init_spawnable_weapon_upgrade);
	precacheEffectsForWeapons();
}

precacheEffectsForWeapons() //custom function
{
	level._effect[ "olympia_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_olympia" );
	level._effect[ "m16_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_m16" );
	level._effect[ "galvaknuckles_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_taseknuck" );
	level._effect[ "mp5k_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_mp5k" );
	level._effect[ "bowie_knife_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_bowie" );
	level._effect[ "m14_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_m14" );
	level._effect[ "ak74u_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_ak74u" );
	level._effect[ "b23r_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_berreta93r" );
	level._effect[ "claymore_effect" ] = loadfx( "maps/zombie/fx_zmb_wall_buy_claymore" );
}

init_spawnable_weapon_upgrade()
{
	spawn_list = [];
	spawnable_weapon_spawns = getstructarray( "weapon_upgrade", "targetname" );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "bowie_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "sickle_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "tazer_upgrade", "targetname" ), 1, 0 );
	spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "buildable_wallbuy", "targetname" ), 1, 0 );
	if ( !is_true( level.headshots_only ) )
	{
		spawnable_weapon_spawns = arraycombine( spawnable_weapon_spawns, getstructarray( "claymore_purchase", "targetname" ), 1, 0 );
	}
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( location == "default" || location == "" && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = level.scr_zm_ui_gametype;
	if ( location != "" )
	{
		match_string = match_string + "_" + location;
	}
	match_string_plus_space = " " + match_string;
	i = 0;
	while ( i < spawnable_weapon_spawns.size )
	{
		spawnable_weapon = spawnable_weapon_spawns[ i ];
		if ( isDefined( spawnable_weapon.zombie_weapon_upgrade ) && spawnable_weapon.zombie_weapon_upgrade == "sticky_grenade_zm" && is_true( level.headshots_only ) )
		{
			i++;
			continue;
		}
		if ( !isDefined( spawnable_weapon.script_noteworthy ) || spawnable_weapon.script_noteworthy == "" )
		{
			spawn_list[ spawn_list.size ] = spawnable_weapon;
			i++;
			continue;
		}
		matches = strtok( spawnable_weapon.script_noteworthy, "," );
		for ( j = 0; j < matches.size; j++ )
		{
			if ( matches[ j ] == match_string || matches[ j ] == match_string_plus_space )
			{
				spawn_list[ spawn_list.size ] = spawnable_weapon;
			}
		}
		i++;
	}
	tempmodel = spawn( "script_model", ( 0, 0, 0 ) );
	i = 0;
	while ( i < spawn_list.size )
	{
		clientfieldname = spawn_list[ i ].zombie_weapon_upgrade + "_" + spawn_list[ i ].origin;
		numbits = 2;
		if ( isDefined(level.customMap) && level.customMap == "tunnel" )
		{
			if( spawn_list[ i ].zombie_weapon_upgrade == "m14_zm" )
			{
				spawn_list[ i ].origin = (-11166, -2844, 247);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("m14_effect", spawn_list[ i ].origin, (0,-86,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "rottweil72_zm" )
			{
				spawn_list[ i ].origin = (-10790, -1430, 247);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("olympia_effect", spawn_list[ i ].origin, (0,83,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "mp5k_zm" )
			{
				spawn_list[ i ].origin = (-10625, -545, 247);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("mp5k_effect", spawn_list[ i ].origin, (0,83,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "tazer_knuckles_zm" )
			{
				spawn_list[ i ].origin = (-11839, -2406, 283);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("galvaknuckles_effect", spawn_list[ i ].origin, (0,-93,0));
			}
		}
		else if ( isDefined(level.customMap) && level.customMap == "diner" )
		{
			if( spawn_list[ i ].zombie_weapon_upgrade == "m14_zm" )
			{
				spawn_list[ i ].origin = (-4280, -7486, -5);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("m14_effect", spawn_list[ i ].origin, (0,0,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "rottweil72_zm" )
			{
				spawn_list[ i ].origin = (-5085, -7807, -5);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("olympia_effect", spawn_list[ i ].origin, (0,0,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "m16_zm" )
			{
				spawn_list[ i ].origin = (-3578, -7181, 0);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("m16_effect", spawn_list[ i ].origin, (0,180,0));
			}
		}
		else if ( isDefined(level.customMap) && level.customMap == "cornfield" )
		{
			/*
			if( spawn_list[ i ].zombie_weapon_upgrade == "beretta93r_zm" )
			{
				spawn_list[ i ].origin = (12968, -917, -142);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("b23r_effect", spawn_list[ i ].origin, (0,0,0));
			}
			*/
			if( spawn_list[ i ].zombie_weapon_upgrade == "claymore_zm" )
			{
				spawn_list[ i ].origin = (13603, -1282, -134);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("claymore_effect", spawn_list[ i ].origin, (0,-180,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "rottweil72_zm" )
			{
				spawn_list[ i ].origin = (13663, -1166, -134);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("olympia_effect", spawn_list[ i ].origin, (0,-90,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "m16_zm" )
			{
				spawn_list[ i ].origin = (14092, -351, -133);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("m16_effect", spawn_list[ i ].origin, (0,90,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "mp5k_zm" )
            {
                spawn_list[ i ].origin = (13542, -764, -133);
                spawn_list[ i ].angles = ( 0, 0, 0 );
                thread playchalkfx("mp5k_effect", spawn_list[ i ].origin + (0, 7, 0), (0,90,0));
            }
			if( spawn_list[ i ].zombie_weapon_upgrade == "tazer_knuckles_zm" )
			{
				spawn_list[ i ].origin = (13502, -12, -125);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("galvaknuckles_effect", spawn_list[ i ].origin + (0, 13, 0), (0,90,0));
			}
		}
		else if ( isDefined(level.customMap) && level.customMap == "house" )
		{
			if( spawn_list[ i ].zombie_weapon_upgrade == "m14_zm" )
			{
				spawn_list[ i ].origin = (5270, 6668, 31);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("m14_effect", spawn_list[ i ].origin, (0,0,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "rottweil72_zm" )
			{
				spawn_list[ i ].origin = (5004, 6696, 31);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("olympia_effect", spawn_list[ i ].origin, (0,270,0));
			}
			if( spawn_list[ i ].zombie_weapon_upgrade == "mp5k_zm" )
			{
				spawn_list[ i ].origin = (5143, 6651, 31);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("mp5k_effect", spawn_list[ i ].origin, (0,180,0));
			}
		}
		else if ( isDefined(level.customMap) && level.customMap == "power" )
		{
			if( spawn_list[ i ].zombie_weapon_upgrade == "m14_zm" )
			{
				spawn_list[ i ].origin = (10559, 8226, -504);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("m14_effect", spawn_list[ i ].origin, (0,90,0));
			}
			else if( spawn_list[ i ].zombie_weapon_upgrade == "rottweil72_zm" )
			{
				spawn_list[ i ].origin = (11769, 7662, -701);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("olympia_effect", spawn_list[ i ].origin, (0,170,0));
			}
			else if( spawn_list[ i ].zombie_weapon_upgrade == "m16_zm" )
			{
				spawn_list[ i ].origin = (10859, 8146, -353);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("m16_effect", spawn_list[ i ].origin, (0,0,0));
			}
			else if( spawn_list[ i ].zombie_weapon_upgrade == "mp5k_zm" )
			{
				spawn_list[ i ].origin = (11452, 8692, -521);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("mp5k_effect", spawn_list[ i ].origin, (0,90,0));
			}
			else if( spawn_list[ i ].zombie_weapon_upgrade == "bowie_knife_zm" )
			{
				spawn_list[ i ].origin = (10837, 8135, -490);
				spawn_list[ i ].angles = ( 0, 0, 0 );
				thread playchalkfx("bowie_knife_effect", spawn_list[ i ].origin, (0,180,0));
			}
		}
		if ( isDefined( level._wallbuy_override_num_bits ) )
		{
			numbits = level._wallbuy_override_num_bits;
		}
		registerclientfield( "world", clientfieldname, 1, numbits, "int" );
		target_struct = getstruct( spawn_list[ i ].target, "targetname" );
		if ( spawn_list[ i ].targetname == "buildable_wallbuy" )
		{
			bits = 4;
			if ( isDefined( level.buildable_wallbuy_weapons ) )
			{
				bits = getminbitcountfornum( level.buildable_wallbuy_weapons.size + 1 );
			}
			registerclientfield( "world", clientfieldname + "_idx", 12000, bits, "int" );
			spawn_list[ i ].clientfieldname = clientfieldname;
			i++;
			continue;
		}
		precachemodel( target_struct.model );
		unitrigger_stub = spawnstruct();
		unitrigger_stub.origin = spawn_list[ i ].origin;
		unitrigger_stub.angles = spawn_list[ i ].angles;
		tempmodel.origin = spawn_list[ i ].origin;
		tempmodel.angles = spawn_list[ i ].angles;
		mins = undefined;
		maxs = undefined;
		absmins = undefined;
		absmaxs = undefined;
		tempmodel setmodel( target_struct.model );
		tempmodel useweaponhidetags( spawn_list[ i ].zombie_weapon_upgrade );
		mins = tempmodel getmins();
		maxs = tempmodel getmaxs();
		absmins = tempmodel getabsmins();
		absmaxs = tempmodel getabsmaxs();
		bounds = absmaxs - absmins;
		unitrigger_stub.script_length = bounds[ 0 ] * 0.25;
		unitrigger_stub.script_width = bounds[ 1 ];
		unitrigger_stub.script_height = bounds[ 2 ];
		unitrigger_stub.origin -= anglesToRight( unitrigger_stub.angles ) * ( unitrigger_stub.script_length * 0.4 );
		unitrigger_stub.target = spawn_list[ i ].target;
		unitrigger_stub.targetname = spawn_list[ i ].targetname;
		unitrigger_stub.cursor_hint = "HINT_NOICON";
		if ( spawn_list[ i ].targetname == "weapon_upgrade" )
		{
			unitrigger_stub.cost = get_weapon_cost( spawn_list[ i ].zombie_weapon_upgrade );
			if ( isDefined( level.monolingustic_prompt_format ) && !level.monolingustic_prompt_format )
			{
				unitrigger_stub.hint_string = get_weapon_hint( spawn_list[ i ].zombie_weapon_upgrade );
				unitrigger_stub.hint_parm1 = unitrigger_stub.cost;
			}
			else
			{
				unitrigger_stub.hint_parm1 = get_weapon_display_name( spawn_list[ i ].zombie_weapon_upgrade );
				if ( !isDefined( unitrigger_stub.hint_parm1 ) || unitrigger_stub.hint_parm1 == "" || unitrigger_stub.hint_parm1 == "none" )
				{
					unitrigger_stub.hint_parm1 = "missing weapon name " + spawn_list[ i ].zombie_weapon_upgrade;
				}
				unitrigger_stub.hint_parm2 = unitrigger_stub.cost;
				unitrigger_stub.hint_string = &"ZOMBIE_WEAPONCOSTONLY";
			}
		}
		unitrigger_stub.weapon_upgrade = spawn_list[ i ].zombie_weapon_upgrade;
		unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
		unitrigger_stub.require_look_at = 1;
		if ( isDefined( spawn_list[ i ].require_look_from ) && spawn_list[ i ].require_look_from )
		{
			unitrigger_stub.require_look_from = 1;
		}
		unitrigger_stub.zombie_weapon_upgrade = spawn_list[ i ].zombie_weapon_upgrade;
		unitrigger_stub.clientfieldname = clientfieldname;
		maps/mp/zombies/_zm_unitrigger::unitrigger_force_per_player_triggers( unitrigger_stub, 1 );
		if ( is_melee_weapon( unitrigger_stub.zombie_weapon_upgrade ) )
		{
			if ( unitrigger_stub.zombie_weapon_upgrade == "tazer_knuckles_zm" && isDefined( level.taser_trig_adjustment ) )
			{
				unitrigger_stub.origin += level.taser_trig_adjustment;
			}
			maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
		}
		else if ( unitrigger_stub.zombie_weapon_upgrade == "claymore_zm" )
		{
			unitrigger_stub.prompt_and_visibility_func = ::claymore_unitrigger_update_prompt;
			maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::buy_claymores );
		}
		else
		{
			unitrigger_stub.prompt_and_visibility_func = ::wall_weapon_update_prompt;
			maps/mp/zombies/_zm_unitrigger::register_static_unitrigger( unitrigger_stub, ::weapon_spawn_think );
		}
		spawn_list[ i ].trigger_stub = unitrigger_stub;
		i++;
	}
	level._spawned_wallbuys = spawn_list;
	tempmodel delete();
}

customWallbuy(weapon, displayName, cost, ammoCost, origin, angles, fx) //custom function
{
	level endon("end_game");
	if(!isdefined(weapon) || !isdefined(origin) || !isdefined(angles))
		return;
	if(!isdefined(cost))
		cost = 1000;
	trig = spawn("trigger_radius", origin, 1, 50, 50);
	trig SetCursorHint("HINT_NOICON");
	thread playchalkfx(fx, origin + (0,0,55), angles);
	if(is_melee_weapon(weapon) || weapon_no_ammo(weapon))
	{
		trig SetHintString("Hold ^3&&1^7 to buy " + displayName + " [Cost: " + cost + "]");
	}
	else
	{
		trig SetHintString("Hold ^3&&1^7 to buy " + displayName + " [Cost: " + cost + " Ammo: " + ammoCost + " Upg: 4500]");
	}
	for(;;)
	{
		trig waittill("trigger", player);
		if(player UseButtonPressed() && player can_buy_weapon())
		{

			if(!player has_weapon_or_upgrade( weapon ) && player.score >= cost)
			{
				player.score -= cost;
				player playsound("zmb_cha_ching");
				if(weapon == "one_inch_punch_zm" && isdefined(level.oneInchPunchGiveFunc))
				{
					player thread [[level.oneInchPunchGiveFunc]]();
				}
				else
					player weapon_give(weapon);
				wait 3;
			}
			else
			{
				if(player has_upgrade(weapon) && player.score >= 4500)
				{
					if(player ammo_give(get_upgrade_weapon(weapon)))
					{
						player.score -= 4500;
						player playsound("zmb_cha_ching");
						wait 3;
					}
				}
				else if(player.score >= ammoCost)
				{
					if(player ammo_give(weapon))
					{
						player.score -= ammoCost;
						player playsound("zmb_cha_ching");
						wait 3;
					}
				}
			}
		}
		wait .1;
	}
}

weapon_no_ammo(weapon) //custom function
{
	if(weapon == "one_inch_punch_zm")
	{
		return 1;
	}
	return 0;
}

playchalkfx(effect, origin, angles) //custom function
{
	if(!isdefined(effect))
		return;
	for(;;)
	{
		fx = SpawnFX(level._effect[ effect ], origin,AnglesToForward(angles),AnglesToUp(angles));
		TriggerFX(fx);
		level waittill("connected", player);
		fx Delete();
	}
}