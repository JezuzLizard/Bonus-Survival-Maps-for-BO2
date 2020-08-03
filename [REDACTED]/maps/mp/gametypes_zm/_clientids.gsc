#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/gametypes_zm/_hud_util;

init()
{
	level.player_out_of_playable_area_monitor = 0;
	level.player_intersection_tracker_override = ::disable_intersection_tracking;
	thread init_custom_map();
	thread setupWunderfizz();
	if ( level.script == "zm_tomb" && isDefined ( level.customMap ) && level.customMap != "vanilla" )
	{
		level thread turn_on_power_origins();
	}
	if ( isDefined ( level.customMap ) && level.customMap != "vanilla" )
	{
		setDvar( "scr_screecher_ignore_player", 1 );
	}
}

disable_intersection_tracking( player )
{
	return 1;
}

init_custom_map()
{
	level thread onplayerconnected();
	disable_pers_upgrades();
	thread init_buildables();
	wait 5;
	thread map_fixes();
}

onplayerconnected()
{
	for ( ;; )
	{
		level waittill( "connected", player );
		player thread addPerkSlot();
		player thread onplayerspawned();
		player thread perkHud();
		player thread [[ level.givecustomcharacters ]]();
		if ( isDefined ( level.HighRoundTracking ) && level.HighRoundTracking )
		{
			wait 5;
			player iprintln ( "High Round Record for this map: ^1" + level.HighRound );
			player iprintln ( "Record set by: ^1" + level.HighRoundPlayers );
		}
	}
}

perkHud()
{
	if(level.script != "zm_prison" && level.customMap != "vanilla")
		return;
	self endon("disconnect");
	self endon("end_game");
	self.perkText = self createText("Objective", 1, "LEFT", "TOP", -395, -10, 1, self getPerkDisplay());
	for(;;)
	{
		if(self.resetPerkHUD)
		{
			self.perkText setSafeText(self, self getPerkDisplay());
			self.resetPerkHUD = 0;
		}
		wait .1;
	}
}

getPerkDisplay()
{
	myperks = self get_perk_array(0);
	string = "PERKS: ";
	for(i=0;i<myperks.size;i++)
	{
		string = string + "\n" + getPerkName(myperks[i]);
	}
	return string;
}

addPerkSlot()
{
	perks = getPerks();
	killsNeeded = getDvarIntDefault( "perkSlotIncreaseKills", 0 );
	completedCount = 0;
	for(;;)
	{
		if(killsNeeded == 0)
			break;
		if((self.kills - (killsNeeded * completedCount)) >= killsNeeded)
		{
			self increment_player_perk_purchase_limit();
			self IPrintLnBold("You can now hold ^1" + self.player_perk_purchase_limit + " ^7perks!");
			completedCount++;
		}
		if((perks.size - level.perk_purchase_limit) <= completedCount)
			break;
		wait .1;
	}
}

onplayerspawned()
{
	self endon("disconnect");
	level endon("end_game");
	isFirstSpawn = true;
	for ( ;; )
	{
		self waittill( "spawned_player" );
		if(isFirstSpawn)
		{
			self initOverFlowFix();

			isFirstSpawn = false;
		}
		self thread disable_player_pers_upgrades();
		level notify ( "check_count" );
	}
}

map_fixes()
{
	if ( level.script == "zm_prison" && isDefined( level.customMap ) && level.customMap == "docks" )
	{
		level notify( "cable_puzzle_gate_afterlife" );
	}
	else if ( level.script == "zm_prison" && isDefined( level.customMap ) && level.customMap == "cellblock" )
	{
		level notify( "intro_powerup_activate" );
		level notify( "cell_1_powerup_activate" );
		level notify( "cell_2_powerup_activate" );
	}
}

disable_pers_upgrades() //credit to Jbleezy for this function
{
	level waittill("initial_disable_player_pers_upgrades");

	level.pers_upgrades_keys = [];
	level.pers_upgrades = [];
}

disable_player_pers_upgrades() //credit to Jbleezy for this function
{
	flag_wait( "initial_blackscreen_passed" );

	if ( isDefined( self.pers_upgrades_awarded ) )
	{
		upgrade = getFirstArrayKey( self.pers_upgrades_awarded );
		while ( isDefined( upgrade ) )
		{
			self.pers_upgrades_awarded[ upgrade ] = 0;
			upgrade = getNextArrayKey( self.pers_upgrades_awarded, upgrade );
		}
	}

	if ( isDefined( level.pers_upgrades_keys ) )
	{
		index = 0;
		while ( index < level.pers_upgrades_keys.size )
		{
			str_name = level.pers_upgrades_keys[ index ];
			stat_index = 0;
			while ( stat_index < level.pers_upgrades[ str_name ].stat_names.size )
			{
				self maps/mp/zombies/_zm_stats::zero_client_stat( level.pers_upgrades[str_name].stat_names[ stat_index ], 0 );
				stat_index++;
			}
			index++;
		}
	}
	level notify("initial_disable_player_pers_upgrades");
}

changecraftableoption( index )
{
	foreach (craftable in level.a_uts_craftables)
	{
		if (craftable.equipname == "open_table")
		{
			craftable thread setcraftableoption( index );
		}
	}
}

setcraftableoption( index )
{
	self endon("death");

	while (self.a_uts_open_craftables_available.size <= 0)
	{
		wait 0.05;
	}
	if (self.a_uts_open_craftables_available.size > 1)
	{
		self.n_open_craftable_choice = index;
		self.equipname = self.a_uts_open_craftables_available[self.n_open_craftable_choice].equipname;
		self.hint_string = self.a_uts_open_craftables_available[self.n_open_craftable_choice].hint_string;
		foreach (trig in self.playertrigger)
		{
			trig sethintstring( self.hint_string );
		}
	}
}

takecraftableparts( buildable )
{
	player = get_players()[ 0 ];
	foreach (stub in level.zombie_include_craftables)
	{
		if ( stub.name == buildable )
		{
			foreach (piece in stub.a_piecestubs)
			{
				piecespawn = piece.piecespawn;
				if ( isDefined( piecespawn ) )
				{
					player player_take_piece( piecespawn );
				}
			}

			return;
		}
	}
}

buildcraftable( buildable )
{
	player = get_players()[ 0 ];
	foreach (stub in level.a_uts_craftables)
	{
		if ( stub.craftablestub.name == buildable )
		{
			foreach (piece in stub.craftablespawn.a_piecespawns)
			{
				piecespawn = get_craftable_piece( stub.craftablestub.name, piece.piecename );
				if ( isDefined( piecespawn ) )
				{
					player player_take_piece( piecespawn );
				}
			}
			return;
		}
	}
}

get_craftable_piece( str_craftable, str_piece )
{
	foreach (uts_craftable in level.a_uts_craftables)
	{
		if ( uts_craftable.craftablestub.name == str_craftable )
		{
			foreach (piecespawn in uts_craftable.craftablespawn.a_piecespawns)
			{
				if ( piecespawn.piecename == str_piece )
				{
					return piecespawn;
				}
			}
		}
	}
	return undefined;
}

player_take_piece( piecespawn )
{
	piecestub = piecespawn.piecestub;
	damage = piecespawn.damage;

	if ( isDefined( piecestub.onpickup ) )
	{
		piecespawn [[ piecestub.onpickup ]]( self );
	}

	if ( isDefined( piecestub.is_shared ) && piecestub.is_shared )
	{
		if ( isDefined( piecestub.client_field_id ) )
		{
			level setclientfield( piecestub.client_field_id, 1 );
		}
	}
	else
	{
		if ( isDefined( piecestub.client_field_state ) )
		{
			self setclientfieldtoplayer( "craftable", piecestub.client_field_state );
		}
	}

	piecespawn piece_unspawn();
	piecespawn notify( "pickup" );

	if ( isDefined( piecestub.is_shared ) && piecestub.is_shared )
	{
		piecespawn.in_shared_inventory = 1;
	}

	self adddstat( "buildables", piecespawn.craftablename, "pieces_pickedup", 1 );
}

piece_unspawn()
{
	if ( isDefined( self.model ) )
	{
		self.model delete();
	}
	self.model = undefined;
	if ( isDefined( self.unitrigger ) )
	{
		thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.unitrigger );
	}
	self.unitrigger = undefined;
}

init_buildables()
{
	if ( isDefined( level.customMap ) && level.customMap == "tunnel" || isDefined( level.customMap ) && level.customMap == "diner" || isDefined( level.customMap ) && level.customMap == "power" || isDefined( level.customMap ) && level.customMap == "cornfield" || isDefined( level.customMap ) && level.customMap == "house" )
	{
		wait 1;
		buildbuildable( "dinerhatch", 1 );
		buildbuildable( "pap", 1 );
		buildbuildable( "turbine" );
		buildbuildable( "electric_trap" );
		buildbuildable( "riotshield_zm", 1 );
		removebuildable( "jetgun_zm" );
		removebuildable( "powerswitch" );
		removebuildable( "sq_common" );
		removebuildable( "busladder" );
		removebuildable( "bushatch" );
		removebuildable( "cattlecatcher" );
	}
	if ( level.script == "zm_prison" && isDefined( level.customMap ) && level.customMap != "vanilla" )
	{
		wait 2;
		buildcraftable( "quest_key1" );
		buildcraftable( "alcatraz_shield_zm" );
		if ( isDefined( level.customMap ) && level.customMap == "cellblock" )
		{
			buildcraftable( "packasplat" );
			buildcraftable( "plane" );
		}
		else if ( isDefined ( level.customMap ) && level.customMap == "docks" )
		{
			buildcraftable( "plane" );
		}
		else if ( isDefined ( level.customMap ) && level.customMap == "rooftop" )
		{
			level thread build_plane_later();
			level thread prison_auto_refuel_plane();
		}
		changecraftableoption( 0 );
	}
}

buildbuildable( buildable, craft ) //credit to Jbleezy for this function
{
	if ( !isDefined( craft ) )
	{
		craft = 0;
	}

	player = get_players()[ 0 ];
	foreach ( stub in level.buildable_stubs )
	{
		if ( !isDefined( buildable ) || stub.equipname == buildable )
		{
			if ( isDefined( buildable ) || stub.persistent != 3 )
			{
				if (craft)
				{
					stub maps/mp/zombies/_zm_buildables::buildablestub_finish_build( player );
					stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
					stub.model notsolid();
					stub.model show();
				}

				i = 0;
				foreach ( piece in stub.buildablezone.pieces )
				{
					piece maps/mp/zombies/_zm_buildables::piece_unspawn();
					if ( !craft && i > 0 )
					{
						stub.buildablezone maps/mp/zombies/_zm_buildables::buildable_set_piece_built( piece );
					}
					i++;
				}
				return;
			}
		}
	}
}

removebuildable( buildable, after_built )
{
	if (!isDefined(after_built))
	{
		after_built = 0;
	}

	if (after_built)
	{
		foreach (stub in level._unitriggers.trigger_stubs)
		{
			if(IsDefined(stub.equipname) && stub.equipname == buildable)
			{
				stub.model hide();
				maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
				return;
			}
		}
	}
	else
	{
		foreach (stub in level.buildable_stubs)
		{
			if ( !isDefined( buildable ) || stub.equipname == buildable )
			{
				if ( isDefined( buildable ) || stub.persistent != 3 )
				{
					stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
					foreach (piece in stub.buildablezone.pieces)
					{
						piece maps/mp/zombies/_zm_buildables::piece_unspawn();
					}
					maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
					return;
				}
			}
		}
	}
}

get_equipname() //credit to Jbleezy for this function
{
	if ( self.equipname == "turbine" )
	{
		return "Turbine";
	}
	else if ( self.equipname == "electric_trap" )
	{
		return "Electric Trap";
	}
	else if ( self.equipname == "riotshield_zm" )
	{
		return "Zombie Shield";
	}
}

get_player_perk_purchase_limit()
{
	if ( isDefined( self.player_perk_purchase_limit ) )
	{
		return self.player_perk_purchase_limit;
	}
	return level.perk_purchase_limit;
}

increment_player_perk_purchase_limit()
{
	perks = getPerks();
	if ( !isDefined( self.player_perk_purchase_limit ) )
	{
		self.player_perk_purchase_limit = level.perk_purchase_limit;
	}
	if ( self.player_perk_purchase_limit < perks.size )
	{
		self.player_perk_purchase_limit++;
	}
}

prison_auto_refuel_plane()
{
	level endon ( "end_game" );
	for ( ;; )
	{
		flag_wait( "spawn_fuel_tanks" );
		wait 0.05;
		buildcraftable( "refuelable_plane" );
	}
}

build_plane_later()
{
	level endon ( "end_game" );
	level endon ( "plane_built" );
	
	level.planeBuiltOnRound = getDvarIntDefault( "planeBuiltOnRound", 10 );
	level.zombie_vars[ "planeBuiltOnRound" ] = level.planeBuiltOnRound;
	
	for ( ;; )
	{
		level waittill ( "start_of_round" );
		if ( level.round_number >= level.planeBuiltOnRound )
		{
			buildcraftable( "plane" );
			level notify ( "plane_built" );
		}
		wait 0.5;
	}
}

setupWunderfizz()
{
	level.wunderfizzCost = getDvarIntDefault("wunderfizzCost", 1500);
	if(level.script == "zm_tomb")
    {
    	level._effect[ "wunderfizz_loop" ] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_on" );
    	//thread wunderfizz((2468,4459,-316), (0,180,0), "p6_zm_vending_diesel_magic");
    }
    if ( isDefined ( level.customMap ) && level.customMap == "house" )
	{
		thread wunderfizz((4782,5998,-64),(0,111,0), "zombie_vending_jugg");
    }
    else if ( isDefined ( level.customMap ) && level.customMap == "rooftop" )
	{
		thread wunderfizz((3215.64,9568.38,1528),(0,90,0), "p6_zm_al_vending_jugg_on");
    }
}

getPerks()
{
	perks = [];
	//Order is Rainbow
	if(isDefined(level.zombiemode_using_juggernaut_perk) && level.zombiemode_using_juggernaut_perk)
	{
		perks[perks.size] = "specialty_armorvest";
	}
	if(isDefined(level._custom_perks[ "specialty_nomotionsensor"] ))
	{
		perks[perks.size] = "specialty_nomotionsensor";
	}
	if ( isDefined( level.zombiemode_using_doubletap_perk ) && level.zombiemode_using_doubletap_perk )
	{
		perks[perks.size] = "specialty_rof";
	}
	if ( isDefined( level.zombiemode_using_marathon_perk ) && level.zombiemode_using_marathon_perk )
	{
		perks[perks.size] = "specialty_longersprint";
	}
	if ( isDefined( level.zombiemode_using_sleightofhand_perk ) && level.zombiemode_using_sleightofhand_perk )
	{
		perks[perks.size] = "specialty_fastreload";
	}
	if(isDefined(level.zombiemode_using_additionalprimaryweapon_perk) && level.zombiemode_using_additionalprimaryweapon_perk)
	{
		perks[perks.size] = "specialty_additionalprimaryweapon";
	}
	if ( isDefined( level.zombiemode_using_revive_perk ) && level.zombiemode_using_revive_perk )
	{
		perks[perks.size] = "specialty_quickrevive";
	}
	if ( isDefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk )
	{
		perks[perks.size] = "specialty_finalstand";
	}
	if ( isDefined( level._custom_perks[ "specialty_grenadepulldeath" ] ))
	{
		perks[perks.size] = "specialty_grenadepulldeath";
	}
	if ( isDefined( level._custom_perks[ "specialty_flakjacket" ]) && level.script != "zm_buried" )
	{
		perks[perks.size] = "specialty_flakjacket";
	}
	if ( isDefined( level.zombiemode_using_deadshot_perk ) && level.zombiemode_using_deadshot_perk )
	{
		perks[perks.size] = "specialty_deadshot";
	}
	if ( isDefined( level.zombiemode_using_tombstone_perk ) && level.zombiemode_using_tombstone_perk )
	{
		perks[perks.size] = "specialty_scavenger";
	}
	return perks;
}

getPerkName(perk)
{
	if(perk == "specialty_armorvest")
		return "Juggernog";
	if(perk == "specialty_rof")
		return "Double Tap";
	if(perk == "specialty_longersprint")
		return "Stamin-Up";
	if(perk == "specialty_fastreload")
		return "Speed Cola";
	if(perk == "specialty_additionalprimaryweapon")
		return "Mule Kick";
	if(perk == "specialty_quickrevive")
		return "Quick Revive";
	if(perk == "specialty_finalstand")
		return "Who's Who";
	if(perk == "specialty_grenadepulldeath")
		return "Electric Cherry";
	if(perk == "specialty_flakjacket")
		return "PHD Flopper";
	if(perk == "specialty_deadshot")
		return "Deadshot Daiquiri";
	if(perk == "specialty_scavenger")
		return "Tombstone";
	if(perk == "specialty_nomotionsensor")
		return "Vulture Aid";
}

getPerkModel(perk)
{
	if(perk == "specialty_armorvest")
	{
		if( level.script == "zm_prison" )
			return "p6_zm_al_vending_jugg_on";
		else
			return "zombie_vending_jugg";
	}
	if(perk == "specialty_nomotionsensor")
		return "p6_zm_vending_vultureaid";
	if(perk == "specialty_rof")
	{
		if(level.script == "zm_prison")
			return "p6_zm_al_vending_doubletap2_on";
		else
			return "zombie_vending_doubletap2";
	}
	if(perk == "specialty_longersprint")
		return "zombie_vending_marathon";
	if(perk == "specialty_fastreload")
	{
		if( level.script == "zm_prison" )
			return "p6_zm_al_vending_sleight_on";
		else
			return "zombie_vending_sleight";
	}
	if(perk == "specialty_quickrevive")
		if(level.script == "zm_prison")
			return "p6_zm_vending_electric_cherry_on";
		else
			return "zombie_vending_revive";
	if(perk == "specialty_scavenger")
		return "zombie_vending_tombstone";
	if(perk == "specialty_finalstand")
		return "p6_zm_vending_chugabud";
	if(perk == "specialty_grenadepulldeath")
		return "p6_zm_vending_electric_cherry_on";
	if(perk == "specialty_additionalprimaryweapon")
		if(level.script == "zm_prison")
			return "p6_zm_al_vending_three_gun_on";
		else
			return "zombie_vending_three_gun";
	if(perk == "specialty_deadshot")
	{
		if(level.script == "zm_prison")
			return "p6_zm_al_vending_ads_on";
		else
			return "zombie_vending_ads";
	}
	if(perk == "specialty_flakjacket")
	{
		if(level.script == "zm_prison")
			return "p6_zm_al_vending_nuke_on";
		else
			return "zombie_vending_ads";
	}
}
getPerkBottleModel(perk)
{
	if(perk == "specialty_armorvest")
		return "t6_wpn_zmb_perk_bottle_jugg_world";
	if(perk == "specialty_rof")
		return "t6_wpn_zmb_perk_bottle_doubletap_world";
	if(perk == "specialty_longersprint")
		return "t6_wpn_zmb_perk_bottle_marathon_world";
	if(perk == "specialty_nomotionsensor")
		return "t6_wpn_zmb_perk_bottle_vultureaid_world";
	if(perk == "specialty_fastreload")
		return "t6_wpn_zmb_perk_bottle_sleight_world";
	if(perk == "specialty_flakjacket")
		return "t6_wpn_zmb_perk_bottle_nuke_world";
	if(perk == "specialty_quickrevive")
		return "t6_wpn_zmb_perk_bottle_revive_world";
	if(perk == "specialty_scavenger")
		return "t6_wpn_zmb_perk_bottle_tombstone_world";
	if(perk == "specialty_finalstand")
		return "t6_wpn_zmb_perk_bottle_chugabud_world";
	if(perk == "specialty_grenadepulldeath")
		return "t6_wpn_zmb_perk_bottle_cherry_world";
	if(perk == "specialty_additionalprimaryweapon")
		return "t6_wpn_zmb_perk_bottle_mule_kick_world";
	if(perk == "specialty_deadshot")
		return "t6_wpn_zmb_perk_bottle_deadshot_world";
}

wunderfizz(origin, angles, model)
{
	collision = spawn("script_model", origin);
    collision setModel("collision_geo_cylinder_32x128_standard");
    collision rotateTo(angles, .1);
	wunderfizzMachine = spawn("script_model", origin);
	wunderfizzMachine setModel(model);
	wunderfizzMachine rotateTo(angles, .1);
	wunderfizzBottle = spawn("script_model", origin);
	wunderfizzBottle setModel("tag_origin");
	wunderfizzBottle.angles = angles;
	wunderfizzBottle.origin += vectorScale( ( 0, 0, 1 ), 55 );
	wunderfizzMachine.bottle = wunderfizzBottle;
	perks = getPerks();
	cost = level.wunderfizzCost;
	trig = spawn("trigger_radius", origin, 1, 50, 50);
	trig SetCursorHint("HINT_NOICON");
	trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
	if(level.script == "zm_tomb")
		wunderfizzMachine thread wunderfizzSounds();
	for(;;)
	{
		trig waittill("trigger", player);
		if(player UseButtonPressed() && player.score >= cost && player.isDrinkingPerk == 0)
		{
			if(player.num_perks < level.perk_purchase_limit)
			{
				if(player.num_perks < perks.size)
				{
					player playsound("zmb_cha_ching");
					player.score -= cost;
					trig setHintString(" ");
					rtime = 3;
					wunderfx = SpawnFX(level._effect["wunderfizz_loop"], wunderfizzMachine.origin,AnglesToForward(angles),AnglesToUp(angles));
					TriggerFX(wunderfx);
					level notify("wunderSpinStart");
					wunderfizzMachine thread perk_bottle_motion();
					wait .1;
					while(rtime>0)
					{
						for(;;)
						{
							perkForRandom = perks[randomInt(perks.size)];
							if(!(player hasPerk(perkForRandom)))
							{
								if(level.script == "zm_tomb")
								{
									wunderfizzMachine.bottle setModel(getPerkBottleModel(perkForRandom));
									break;
								}
								else
								{
									wunderfizzMachine setModel(getPerkModel(perkForRandom));
									break;
								}
							}
						}
						if(level.script == "zm_tomb")
						{
							TriggerFX(wunderfx);
							wait .2;
							rtime -= .2;
						}
						else
						{
							wait .1;
							rtime -= .1;
						}
					}
					wunderfizzMachine notify( "done_cycling" );
					perklist = array_randomize(perks);
					for(j=0;j<perklist.size;j++)
					{
						if(!(player hasPerk(perklist[j])))
						{
							perkName = getPerkName(perklist[j]);
							if(level.script == "zm_tomb")
							{
								wunderfizzMachine.bottle setModel(getPerkBottleModel(perklist[j]));

							}
							else
							{
								if(level.script == "zm_prison")
								{
									wunderfizzMachine setModel(getPerkModel(perklist[j]));
									fx = SpawnFX(level._effect["electriccherry"], origin, AnglesToForward(angles),AnglesToUp(angles));
								}
								else
								{
									wunderfizzMachine setModel(getPerkModel(perklist[j]) + "_on");
									fx = SpawnFX(level._effect["tombstone_light"], origin, AnglesToForward(angles),AnglesToUp(angles));
								}
								TriggerFX(fx);
							}
							trig SetHintString("Hold ^3&&1^7 for " + perkName);
							time = 7;
							while(time > 0)
							{
								if(player UseButtonPressed() && distance(player.origin, trig.origin) < 65)
								{
									player thread givePerk(perklist[j]);
									break;
								}
								TriggerFX(wunderfx);
								wait .2;
								time -= .2;
							}
							wunderfizzMachine setModel(model);
							wunderfizzMachine.bottle setModel("tag_origin");
							trig SetHintString(" ");
							level notify("wunderSpinStop");
							fx Delete();
							break;
						}
					}
					wunderfx Delete();
					wait 2;
					trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
				}
				else
				{
					trig SetHintString("You Have All " + perks.size + " Perks");
					wait 2;
					trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
				}
			}
			else{
				trig SetHintString("You Can Only Hold " + level.perk_purchase_limit + " Perks");
				wait 2;
				trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
			}
		}
		wait .1;
	}
}
perk_bottle_motion()
{
	putouttime = 3;
	putbacktime = 10;
	v_float = anglesToForward( self.angles - ( 0, 90, 0 ) ) * 10;
	self.bottle.origin = self.origin + ( 0, 0, 53 );
	self.bottle.angles = self.angles;
	self.bottle.origin -= v_float;
	self.bottle moveto( self.bottle.origin + v_float, putouttime, putouttime * 0.5 );
	self.bottle.angles += ( 0, 0, 10 );
	self.bottle rotateyaw( 720, putouttime, putouttime * 0.5 );
	self waittill( "done_cycling" );
	self.bottle.angles = self.angles;
	self.bottle moveto( self.bottle.origin - v_float, putbacktime, putbacktime * 0.5 );
	self.bottle rotateyaw( 90, putbacktime, putbacktime * 0.5 );
}

wunderfizzSounds()
{
	while(1)
	{
		level waittill("wunderSpinStart");
		sound_ent = spawn("script_origin", self.origin);
		sound_ent StopSounds();
		sound_ent PlaySound( "zmb_rand_perk_start");
		sound_ent PlayLoopSound("zmb_rand_perk_loop", 0.5);
		level waittill("wunderSpinStop");
		sound_ent StopLoopSound(1);
		sound_ent PlaySound("zmb_rand_perk_stop");
		sound_ent Delete();

	}
}

givePerk(perk)
{
	if(!(self hasPerk(perk) || (self maps/mp/zombies/_zm_perks::has_perk_paused(perk))))
	{
		self.isDrinkingPerk = 1;
		gun = self maps/mp/zombies/_zm_perks::perk_give_bottle_begin(perk);
        evt = self waittill_any_return("fake_death", "death", "player_downed", "weapon_change_complete");
        if (evt == "weapon_change_complete")
        self thread maps/mp/zombies/_zm_perks::wait_give_perk(perk, 1);
       	self maps/mp/zombies/_zm_perks::perk_give_bottle_end(gun, perk);
       	self.isDrinkingPerk = 0;
    	if (self maps/mp/zombies/_zm_laststand::player_is_in_laststand() || isDefined(self.intermission) && self.intermission)
        	return;
    	self notify("burp");
	}
}

turn_on_power_origins()
{
	level waittill( "connected", player );
	maps/mp/zombies/_zm_game_module::turn_power_on_and_open_doors();
	wait 1;
	flag_set( "power_on" );
	level setclientfield( "zombie_power_on", 1 );
	if ( isDefined ( level.customMap ) && level.customMap != "trenches" )
	{
		level notify( "sleight_on" );
		wait_network_frame();
	}
	level notify( "sleight_on" );
	wait_network_frame();
	level notify( "doubletap_on" );
	wait_network_frame();
	if ( isDefined ( level.customMap ) && level.customMap != "excavation" )
	{
		level notify( "juggernog_on" );
		wait_network_frame();
		level notify( "marathon_on" );
		wait_network_frame();
	}
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
	t_pap = getent( "specialty_weapupgrade", "script_noteworthy" );
	t_pap trigger_on();
	flag_set( "power_on" );
	level setclientfield( "zone_capture_hud_all_generators_captured", 1 );
	if ( !flag( "generator_lost_to_recapture_zombies" ) )
	{
		level notify( "all_zones_captured_none_lost" );
	}
}

createText(font, fontscale, align, relative, x, y, sort, text)
{
	textElem = CreateFontString( font, fontscale );
	textElem setPoint( align, relative, x, y );
	textElem.sort = sort;
	textElem.hideWhenInMenu = true;

	textElem.type = "text";
	addTextTableEntry(textElem, getStringId(text));
	textElem setSafeText(self, text);

	return textElem;
}


initOverFlowFix()
{
	self.stringTable = [];
	self.stringTableEntryCount = 0;
	self.textTable = [];
	self.textTableEntryCount = 0;

	if(isDefined(level.anchorText) == false)
	{
		level.anchorText = createServerFontString("default",1.5);
		level.anchorText setText("anchor");
		level.anchorText.alpha = 0;

	level.stringCount = 0;
	}
}

clearStrings()
{
	level.anchorText clearAllTextAfterHudElem();
	level.stringCount = 0;

	foreach(player in level.players)
	{
		player purgeTextTable();
		player purgeStringTable();
		player recreateText();
		player.resetPerkHUD = 1;
	}
}

setSafeText(player, text)
{
	stringId = player getStringId(text);

	if(stringId == -1)
	{
		player addStringTableEntry(text);
		stringId = player getStringId(text);
	}
	else
	{
		player editTextTableEntry(self.textTableIndex, stringId);
	}


	if(level.stringCount > 150)
	clearStrings();

	self setText(text);
}

recreateText()
{
	foreach(entry in self.textTable)
		entry.element setSafeText(self, lookUpStringById(entry.stringId));
}

addStringTableEntry(string)
{
	entry = spawnStruct();
	entry.id = self.stringTableEntryCount;
	entry.string = string;

	self.stringTable[self.stringTable.size] = entry;
	self.stringTableEntryCount++;
	level.stringCount++;
}

lookUpStringById(id)
{
	string = "";

	foreach(entry in self.stringTable)
	{
		if(entry.id == id)
		{
			string = entry.string;
			break;
		}
	}

	return string;
}

getStringId(string)
{
	id = -1;

	foreach(entry in self.stringTable)
	{
		if(entry.string == string)
		{
			id = entry.id;
			break;
		}
	}

	return id;
}

getStringTableEntry(id)
{
	stringTableEntry = -1;

	foreach(entry in self.stringTable)
	{
		if(entry.id == id)
		{
			stringTableEntry = entry;
			break;
		}
	}
	return stringTableEntry;
}

purgeStringTable()
{
	stringTable = [];
	foreach(entry in self.stringTable)
	{
		stringTable[stringTable.size] = getStringTableEntry(entry.stringId);
	}

	self.stringTable = stringTable;
}

purgeTextTable()
{
	textTable = [];

	foreach(entry in self.textTable)
	{
		if(entry.id != -1)
			textTable[textTable.size] = entry;
	}

	self.textTable = textTable;
}

addTextTableEntry(element, stringId)
{
	entry = spawnStruct();
	entry.id = self.textTableEntryCount;
	entry.element = element;
	entry.stringId = stringId;

	element.textTableIndex = entry.id;

	self.textTable[self.textTable.size] = entry;
	self.textTableEntryCount++;
}

editTextTableEntry(id, stringId)
{
	foreach(entry in self.textTable)
	{
		if(entry.id == id)
		{
			entry.stringId = stringId;
			break;
		}
	}
}

deleteTextTableEntry(id)
{
	foreach(entry in self.textTable)
	{
		if(entry.id == id)
		{
			entry.id = -1;
			entry.stringId = -1;
		}
	}
}

clear(player)
{
	if(self.type == "text")
		player deleteTextTableEntry(self.textTableIndex);

	self destroy();
}
