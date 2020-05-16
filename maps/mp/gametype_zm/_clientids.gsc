#include maps/mp/zombies/_zm_utility;
#include maps/common_scripts/utility;
#include maps/mp/_utility;

init()
{
	level.player_out_of_playable_area_monitor = 0;
	setDvar( "scr_screecher_ignore_player", 1 );
	if(isDefined(level.houseMap) && level.houseMap)
   	{
    		thread wunderfizz((5038,6698,-25),(0,130,0), "zombie_vending_jugg");
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
	if ( isDefined( level._custom_perks[ "specialty_grenadepulldeath" ].perk_machine_set_kvps ))
	{
		perks[perks.size] = "specialty_grenadepulldeath";
	}
	if ( isDefined( level._custom_perks[ "specialty_flakjacket" ].perk_machine_set_kvps ))
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

wunderfizz(origin, angles, model)
{
	collision = spawn("script_model", origin);
	collision setModel("collision_geo_cylinder_32x128_standard");
	collision rotateTo(angles, .1);
	wunderfizzMachine = spawn("script_model", origin);
	wunderfizzMachine setModel(model);
	wunderfizzMachine rotateTo(angles, .1);
	perks = getPerks();
	cost = 1500;
	trig = spawn("trigger_radius", origin, 1, 25, 25);
	trig SetCursorHint("HINT_NOICON");
	trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
	level waittill("connected", player);
	for(;;)
	{
		trig waittill("trigger", player);
		if(player UseButtonPressed() && player.score >= cost)
		{
			if(player.num_perks < level.perk_purchase_limit)
			{
				if(player.num_perks < perks.size)
				{
					player playsound("zmb_cha_ching");
					player.score -= cost;
					trig setHintString("Randomizing");
					wait 3;
					perklist = array_randomize(perks);
					for(j=0;j<perklist.size;j++)
					{
						if(!(player hasPerk(perklist[j])))
						{
							perkName = getPerkName(perklist[j]);
							trig SetHintString("Hold ^3&&1^7 for " + perkName);
							time = 7;
							while(time > 0)
							{
								if(player UseButtonPressed() && distance(player.origin, trig.origin) < 50)
								{
									player thread givePerk(perklist[j]);
									break;
								}
								wait .1;
								time -= .1;
							}
							break;
						}
					}
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

givePerk(perk)
{
	self iPrintLn("Enjoy Your Perk");
	perkcheck = 0;
	if(!(self hasPerk(perk) || (self maps/mp/zombies/_zm_perks::has_perk_paused(perk))))
	{
		gun = self maps/mp/zombies/_zm_perks::perk_give_bottle_begin(perk);
        	evt = self waittill_any_return("fake_death", "death", "player_downed", "weapon_change_complete");
        	if (evt == "weapon_change_complete")
        	self thread maps/mp/zombies/_zm_perks::wait_give_perk(perk, 1);
       		self maps/mp/zombies/_zm_perks::perk_give_bottle_end(gun, perk);
    		if (self maps/mp/zombies/_zm_laststand::player_is_in_laststand() || isDefined(self.intermission) && self.intermission)
        	return;
    		self notify("burp");
	}
}
