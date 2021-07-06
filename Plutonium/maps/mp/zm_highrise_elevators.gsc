#include maps/mp/zombies/_zm_ai_leaper;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/animscripts/zm_shared;
#include maps/mp/zm_highrise_distance_tracking;
#include maps/mp/zm_highrise_utility;
#include maps/mp/gametypes_zm/_hostmigration;
#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

//#using_animtree( "zombie_perk_elevator" );

init_perk_elvators_animtree()
{
	//scriptmodelsuseanimtree( -1 );
}

init_elevators()
{
///#
//	init_elevator_devgui();
//#/
}

quick_revive_solo_watch()
{
}

init_perk_elevators_anims()
{
	/*
	level.perk_elevators_door_open_state = %v_zombie_elevator_doors_open;
	level.perk_elevators_door_close_state = %v_zombie_elevator_doors_close;
	level.perk_elevators_door_movement_state = %v_zombie_elevator_doors_idle_movement;
	level.perk_elevators_anims = [];
	level.perk_elevators_anims[ "vending_chugabud" ][ 0 ] = %v_zombie_elevator_doors_whoswho_banging_before_leaving;
	level.perk_elevators_anims[ "vending_chugabud" ][ 1 ] = %v_zombie_elevator_doors_whoswho_trying_to_close;
	level.perk_elevators_anims[ "vending_doubletap" ][ 0 ] = %v_zombie_elevator_doors_doubletap_banging_before_leaving;
	level.perk_elevators_anims[ "vending_doubletap" ][ 1 ] = %v_zombie_elevator_doors_doubletap_trying_to_close;
	level.perk_elevators_anims[ "vending_jugg" ][ 0 ] = %v_zombie_elevator_doors_jugg_banging_before_leaving;
	level.perk_elevators_anims[ "vending_jugg" ][ 1 ] = %v_zombie_elevator_doors_jugg_trying_to_close;
	level.perk_elevators_anims[ "vending_revive" ][ 0 ] = %v_zombie_elevator_doors_marathon_banging_before_leaving;
	level.perk_elevators_anims[ "vending_revive" ][ 1 ] = %v_zombie_elevator_doors_marathon_trying_to_close;
	level.perk_elevators_anims[ "vending_additionalprimaryweapon" ][ 0 ] = %v_zombie_elevator_doors_mulekick_banging_before_leaving;
	level.perk_elevators_anims[ "vending_additionalprimaryweapon" ][ 1 ] = %v_zombie_elevator_doors_mulekick_trying_to_close;
	level.perk_elevators_anims[ "specialty_weapupgrade" ][ 0 ] = %v_zombie_elevator_doors_pap_banging_before_leaving;
	level.perk_elevators_anims[ "specialty_weapupgrade" ][ 1 ] = %v_zombie_elevator_doors_pap_trying_to_close;
	level.perk_elevators_anims[ "vending_sleight" ][ 0 ] = %v_zombie_elevator_doors_speed_banging_before_leaving;
	level.perk_elevators_anims[ "vending_sleight" ][ 1 ] = %v_zombie_elevator_doors_speed_trying_to_close;
*/}

perkelevatoruseanimtree()
{
	//self useanimtree( -1 );
}

perkelevatordoor( set )
{
}

get_link_entity_for_host_migration()
{
}

escape_pod_host_migration_respawn_check( escape_pod )
{
}

is_self_on_elevator()
{
}

object_is_on_elevator()
{
}

elevator_level_for_floor( floor )
{
}

elevator_is_on_floor( floor )
{
}

elevator_path_nodes( elevatorname, floorname )
{
}

elevator_paths_onoff( onoff, target )
{
}

elevator_enable_paths( floor )
{
}

elevator_disable_paths( floor )
{
}

init_elevator( elevatorname, force_starting_floor, force_starting_origin )
{
	elevator = GetEnt( "elevator_bldg" + elevatorname + "_body", "targetname" );
	elevator Delete();
}

elevator_roof_watcher()
{
	
}

zombie_for_elevator_unseen()
{
	
}

zombie_climb_elevator( elev )
{
	
}

elev_clean_up_corpses()
{
}

elev_remove_corpses()
{
}

elevator_next_floor( elevator, last, justchecking )
{
}

elevator_initial_wait( elevator, minwait, maxwait, delaybeforeleaving )
{
}

elevator_set_moving( moving )
{
}

predict_floor( elevator, next, speed )
{

}

elevator_think( elevator )
{
}

is_pap()
{
}

squashed_death_alarm()
{
}

squashed_death_alarm_nearest_point()
{
}

elevator_move_sound()
{
}

init_elevator_perks()
{
}

random_elevator_perks()
{
}

elevator_perk_offset( machine, perk )
{
}

debugline( ent1, ent2 )
{
/*/#
	org = ent2.origin;
	while ( 1 )
	{
		if ( !isDefined( ent1 ) )
		{
			return;
		}
		line( ent1.origin, org, ( 0, 1, 0 ) );
		wait 0,05;
#/
	}*/
}

get_perk_elevator()
{
}

elevator_depart_early( elevator )
{
}

elevator_sparks_fx( elevator )
{
}

faller_location_logic()
{
}

disable_elevator_spawners( volume, spawn_points )
{
	_a1468 = spawn_points;
	_k1468 = getFirstArrayKey( _a1468 );
	while ( isDefined( _k1468 ) )
	{
		point = _a1468[ _k1468 ];
		if ( isDefined( point.name ) && point.name == volume.targetname )
		{
			point.is_enabled = 0;
		}
		_k1468 = getNextArrayKey( _a1468, _k1468 );
	}
}

shouldsuppressgibs()
{
}

watch_for_elevator_during_faller_spawn()
{
}

init_elevator_devgui( elevatorname, elevator )
{
/*/#
	if ( !isDefined( elevatorname ) )
	{
		adddebugcommand( "devgui_cmd "Zombies:1/Highrise:15/Elevators:1/Stop All:1" "set zombie_devgui_hrelevatorstop all" \n" );
		adddebugcommand( "devgui_cmd "Zombies:1/Highrise:15/Elevators:1/Unstop All:2" "set zombie_devgui_hrelevatorgo all" \n" );
		level thread watch_elevator_devgui( "all", 1 );
	}
	else
	{
		adddebugcommand( "devgui_cmd "Zombies:1/Highrise:15/Elevators:1/" + elevatorname + "/Stop:1" "set zombie_devgui_hrelevatorstop " + elevatorname + "" \n" );
		adddebugcommand( "devgui_cmd "Zombies:1/Highrise:15/Elevators:1/" + elevatorname + "/Go:2" "set zombie_devgui_hrelevatorgo " + elevatorname + "" \n" );
		i = 0;
		while ( i < elevator.floors.size )
		{
			fname = elevator.floors[ "" + i ].script_location;
			adddebugcommand( "devgui_cmd "Zombies:1/Highrise:15/Elevators:1/" + elevatorname + "/stop " + i + " [floor " + fname + "]" "set zombie_devgui_hrelevatorfloor " + i + "; set zombie_devgui_hrelevatorgo " + elevatorname + "" \n" );
			i++;
		}
		elevator thread watch_elevator_devgui( elevatorname, 0 );
		elevator thread show_elevator_floor( elevatorname );
#/
	}*/
}

watch_elevator_devgui( name, global )
{
/*/#
	while ( 1 )
	{
		stopcmd = getDvar( "zombie_devgui_hrelevatorstop" );
		if ( isDefined( stopcmd ) && stopcmd == name )
		{
			if ( global )
			{
				level.elevators_stop = 1;
			}
			else
			{
				if ( isDefined( self ) )
				{
					self.body.elevator_stop = 1;
				}
			}
			setdvar( "zombie_devgui_hrelevatorstop", "" );
		}
		gofloor = getDvarInt( "zombie_devgui_hrelevatorfloor" );
		gocmd = getDvar( "zombie_devgui_hrelevatorgo" );
		if ( isDefined( gocmd ) && gocmd == name )
		{
			if ( global )
			{
				level.elevators_stop = 0;
			}
			else
			{
				if ( isDefined( self ) )
				{
					self.body.elevator_stop = 0;
					if ( gofloor >= 0 )
					{
						self.body.force_starting_floor = gofloor;
					}
					self.body notify( "forcego" );
				}
			}
			setdvar( "zombie_devgui_hrelevatorfloor", "-1" );
			setdvar( "zombie_devgui_hrelevatorgo", "" );
		}
		wait 1;
#/
	}*/
}

show_elevator_floor( name )
{
/*
	while ( 1 )
	{
		if ( getDvarInt( #"B67910B4" ) )
		{
			floor = 0;
			forced = isDefined( self.body.force_starting_floor );
			color = vectorScale( ( 0, 1, 0 ), 0,7 );
			if ( forced )
			{
				color = ( 0,7, 0,3, 0 );
			}
			if ( isDefined( level.elevators_stop ) || level.elevators_stop && isDefined( self.body.elevator_stop ) && self.body.elevator_stop )
			{
				if ( forced )
				{
					color = vectorScale( ( 0, 1, 0 ), 0,7 );
				}
				else
				{
					color = vectorScale( ( 0, 1, 0 ), 0,7 );
				}
			}
			else
			{
				if ( self.body.is_moving )
				{
					if ( forced )
					{
						color = vectorScale( ( 0, 1, 0 ), 0,7 );
						break;
					}
					else
					{
						color = vectorScale( ( 0, 1, 0 ), 0,7 );
					}
				}
			}
			if ( isDefined( self.body.current_level ) )
			{
				floor = self.body.current_level;
			}
			text = "elv " + name + " stop " + self.body.current_level + " floor " + self.floors[ self.body.current_level ].script_location;
			pos = self.body.origin;
			print3d( pos, text, color, 1, 0,75, 1 );
		}
		wait 0,05;
#/
	}
	*/
}