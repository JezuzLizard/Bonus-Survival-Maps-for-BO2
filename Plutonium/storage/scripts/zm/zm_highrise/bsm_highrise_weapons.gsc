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
	replacefunc(maps/mp/zombies/_zm_weapons::init_weapons, ::init_weapons);
	precacheEffectsForWeapons();
}

init_weapons() //checked matches cerberus output
{
	//throws exe_client_field_mismatch on join
	//or the server won't rotate to the map
	level._zombie_custom_add_weapons = ::custom_add_weapons();
	if ( isdefined( level._zombie_custom_add_weapons ) )
	{
		[[ level._zombie_custom_add_weapons ]]();
	}
	precachemodel( "zombie_teddybear" );
}

custom_add_weapons() //checked partially changed to match cerberus output changed at own discretion
{
	add_zombie_weapon( "m1911_zm", "m1911_upgraded_zm", &"ZOMBIE_WEAPON_M1911", 50, "", "", undefined );
	add_zombie_weapon( "python_zm", "python_upgraded_zm", &"ZOMBIE_WEAPON_PYTHON", 50, "wpck_python", "", undefined, 1 );
	add_zombie_weapon( "judge_zm", "judge_upgraded_zm", &"ZOMBIE_WEAPON_JUDGE", 50, "wpck_judge", "", undefined, 1 );
	add_zombie_weapon( "kard_zm", "kard_upgraded_zm", &"ZOMBIE_WEAPON_KARD", 50, "wpck_kap", "", undefined, 1 );
	add_zombie_weapon( "fiveseven_zm", "fiveseven_upgraded_zm", &"ZOMBIE_WEAPON_FIVESEVEN", 50, "wpck_57", "", undefined, 1 );
	add_zombie_weapon( "beretta93r_zm", "beretta93r_upgraded_zm", &"ZOMBIE_WEAPON_BERETTA93r", 1000, "", "", undefined );
	add_zombie_weapon( "fivesevendw_zm", "fivesevendw_upgraded_zm", &"ZOMBIE_WEAPON_FIVESEVENDW", 50, "wpck_duel57", "", undefined, 1 );
	add_zombie_weapon( "ak74u_zm", "ak74u_upgraded_zm", &"ZOMBIE_WEAPON_AK74U", 1200, "smg", "", undefined );
	add_zombie_weapon( "mp5k_zm", "mp5k_upgraded_zm", &"ZOMBIE_WEAPON_MP5K", 1000, "smg", "", undefined );
	add_zombie_weapon( "qcw05_zm", "qcw05_upgraded_zm", &"ZOMBIE_WEAPON_QCW05", 50, "wpck_chicom", "", undefined, 1 );
	add_zombie_weapon( "pdw57_zm", "pdw57_upgraded_zm", &"ZOMBIE_WEAPON_PDW57", 1000, "smg", "", undefined );
	add_zombie_weapon( "870mcs_zm", "870mcs_upgraded_zm", &"ZOMBIE_WEAPON_870MCS", 1500, "shotgun", "", undefined );
	add_zombie_weapon( "rottweil72_zm", "rottweil72_upgraded_zm", &"ZOMBIE_WEAPON_ROTTWEIL72", 500, "shotgun", "", undefined );
	add_zombie_weapon( "saiga12_zm", "saiga12_upgraded_zm", &"ZOMBIE_WEAPON_SAIGA12", 50, "wpck_saiga12", "", undefined, 1 );
	add_zombie_weapon( "srm1216_zm", "srm1216_upgraded_zm", &"ZOMBIE_WEAPON_SRM1216", 50, "wpck_m1216", "", undefined, 1 );
	add_zombie_weapon( "m14_zm", "m14_upgraded_zm", &"ZOMBIE_WEAPON_M14", 500, "rifle", "", undefined );
	add_zombie_weapon( "saritch_zm", "saritch_upgraded_zm", &"ZOMBIE_WEAPON_SARITCH", 50, "wpck_sidr", "", undefined, 1 );
	add_zombie_weapon( "m16_zm", "m16_gl_upgraded_zm", &"ZOMBIE_WEAPON_M16", 1200, "burstrifle", "", undefined );
	add_zombie_weapon( "xm8_zm", "xm8_upgraded_zm", &"ZOMBIE_WEAPON_XM8", 50, "wpck_m8a1", "", undefined, 1 );
	add_zombie_weapon( "type95_zm", "type95_upgraded_zm", &"ZOMBIE_WEAPON_TYPE95", 50, "wpck_type25", "", undefined, 1 );
	add_zombie_weapon( "tar21_zm", "tar21_upgraded_zm", &"ZOMBIE_WEAPON_TAR21", 50, "wpck_x95l", "", undefined, 1 );
	add_zombie_weapon( "galil_zm", "galil_upgraded_zm", &"ZOMBIE_WEAPON_GALIL", 50, "wpck_galil", "", undefined, 1 );
	add_zombie_weapon( "fnfal_zm", "fnfal_upgraded_zm", &"ZOMBIE_WEAPON_FNFAL", 50, "wpck_fal", "", undefined, 1 );
	add_zombie_weapon( "dsr50_zm", "dsr50_upgraded_zm", &"ZOMBIE_WEAPON_DR50", 50, "wpck_dsr50", "", undefined, 1 );
	add_zombie_weapon( "barretm82_zm", "barretm82_upgraded_zm", &"ZOMBIE_WEAPON_BARRETM82", 50, "wpck_m82a1", "", undefined, 1 );
	add_zombie_weapon( "svu_zm", "svu_upgraded_zm", &"ZOMBIE_WEAPON_SVU", 1000, "wpck_svuas", "", undefined );
	add_zombie_weapon( "rpd_zm", "rpd_upgraded_zm", &"ZOMBIE_WEAPON_RPD", 50, "wpck_rpd", "", undefined, 1 );
	add_zombie_weapon( "hamr_zm", "hamr_upgraded_zm", &"ZOMBIE_WEAPON_HAMR", 50, "wpck_hamr", "", undefined, 1 );
	add_zombie_weapon( "frag_grenade_zm", undefined, &"ZOMBIE_WEAPON_FRAG_GRENADE", 250, "grenade", "", 250 );
	add_zombie_weapon( "sticky_grenade_zm", undefined, &"ZOMBIE_WEAPON_STICKY_GRENADE", 250, "grenade", "", 250 );
	add_zombie_weapon( "claymore_zm", undefined, &"ZOMBIE_WEAPON_CLAYMORE", 1000, "grenade", "", undefined );
	add_zombie_weapon( "usrpg_zm", "usrpg_upgraded_zm", &"ZOMBIE_WEAPON_USRPG", 50, "wpck_rpg", "", undefined, 1 );
	add_zombie_weapon( "m32_zm", "m32_upgraded_zm", &"ZOMBIE_WEAPON_M32", 50, "wpck_m32", "", undefined, 1 );
	add_zombie_weapon( "an94_zm", "an94_upgraded_zm", &"ZOMBIE_WEAPON_AN94", 1200, "", "", undefined );
	add_zombie_weapon( "cymbal_monkey_zm", undefined, &"ZOMBIE_WEAPON_SATCHEL_2000", 2000, "wpck_monkey", "", undefined, 1 );
	add_zombie_weapon( "ray_gun_zm", "ray_gun_upgraded_zm", &"ZOMBIE_WEAPON_RAYGUN", 10000, "wpck_ray", "", undefined, 1 );
	add_zombie_weapon( "knife_ballistic_zm", "knife_ballistic_upgraded_zm", &"ZOMBIE_WEAPON_KNIFE_BALLISTIC", 10, "wpck_knife", "", undefined, 1 );
	add_zombie_weapon( "knife_ballistic_bowie_zm", "knife_ballistic_bowie_upgraded_zm", &"ZOMBIE_WEAPON_KNIFE_BALLISTIC", 10, "sickle", "", undefined, 1 );
	add_zombie_weapon( "knife_ballistic_no_melee_zm", "knife_ballistic_no_melee_upgraded_zm", &"ZOMBIE_WEAPON_KNIFE_BALLISTIC", 10, "wpck_knife", "", undefined );
	add_zombie_weapon( "tazer_knuckles_zm", undefined, &"ZOMBIE_WEAPON_TAZER_KNUCKLES", 100, "tazerknuckles", "", undefined );
	add_zombie_weapon( "slipgun_zm", "slipgun_upgraded_zm", &"ZOMBIE_WEAPON_SLIPGUN", 10, "slip", "", undefined );
	if ( is_true( level.raygun2_included ) )
	{
		add_zombie_weapon( "raygun_mark2_zm", "raygun_mark2_upgraded_zm", &"ZOMBIE_WEAPON_RAYGUN_MARK2", 10000, "raygun_mark2", "", undefined );
	}
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
		if(isdefined(level.customMap) && level.customMap == "building1top")
		{
			if( spawn_list[i].zombie_weapon_upgrade == "tazer_knuckles_zm")
			{
				spawn_list[ i ].origin = (1109.64, 2570.07, 3100) + (-14,0,0);
				spawn_list[ i ].angles = (0, 270, 0);
				thread playchalkfx("galvaknuckles_effect", spawn_list[ i ].origin, (0,270,0));
			}
			else if( spawn_list[i].zombie_weapon_upgrade == "an94_zm")
			{
				spawn_list[ i ].origin = (1469.64, 2026.42, 3113) + (-14,0,0);
				spawn_list[ i ].angles = (0, 270, 0);
				thread playchalkfx("an94_effect", spawn_list[ i ].origin, (0,270,0));
			}
		}
		else if(isdefined(level.customMap) && level.customMap == "redroom")
		{
			if( spawn_list[i].zombie_weapon_upgrade == "tazer_knuckles_zm")
			{
				spawn_list[ i ].origin = (3255, 1024.4, 1365) + (-14,0,0);
				spawn_list[ i ].angles = (0, 270, 0);
				thread playchalkfx("galvaknuckles_effect", spawn_list[ i ].origin, (0,270,0));
			}
			else if( spawn_list[i].zombie_weapon_upgrade == "an94_zm")
			{
				spawn_list[ i ].origin = (3830, 1430, 1500) + (14,0,0);
				spawn_list[ i ].angles = (0, 90, 0);
				thread playchalkfx("an94_effect", spawn_list[ i ].origin, (0,90,0));
			}
			else if( spawn_list[i].zombie_weapon_upgrade == "m14_zm")
			{
				spawn_list[ i ].origin = (3210, 1868, 1370) + (0,14,0);
				spawn_list[ i ].angles = (0, 180, 0);
				thread playchalkfx("m14_effect", spawn_list[ i ].origin, (12.5,180,0));
			}
			else if( spawn_list[i].zombie_weapon_upgrade == "rottweil72_zm")
			{
				spawn_list[ i ].origin = (3675.37, 1932.36, 1473.8) + (0,14,0);
				spawn_list[ i ].angles = (0, 180, 0);
				thread playchalkfx("olympia_effect", spawn_list[ i ].origin, (12.5,180,0));
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