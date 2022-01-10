#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;

init()
{
	if(level.zeGamemode != "sharpshooter")
		return;
	level.invis_zomb_powerup_duration = 10;
	if(level.script == "zm_transit")
		invis_zomb_powerup_model = "c_zom_zombie_head_a";
	else if(level.script == "zm_nuked")
		invis_zomb_powerup_model = "c_zom_dlc0_zom_head1";
	else if(level.script == "zm_highrise")
		invis_zomb_powerup_model = "c_zom_zombie_chinese_head1";
	else if(level.script == "zm_prison")
		invis_zomb_powerup_model = "c_zom_zombie_hellcatraz_head";
	else if(level.script == "zm_buried")
		invis_zomb_powerup_model = "c_zom_zombie_buried_male_head1";
	else if(level.script == "zm_tomb")
		invis_zomb_powerup_model = "c_zom_tomb_german_head1";
	add_zombie_powerup( "invis_zomb", invis_zomb_powerup_model, &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_always_drop, 1, 0, 0 );
	powerup_set_can_pick_up_in_last_stand( "invis_zomb", 0 );
	onplayerconnect_callback(::create_invis_zombie_hud);
}

create_invis_zombie_hud()
{
	self.iz_pwp_hud = CreateFontString("Objective", 1.25);
	self.iz_pwp_hud SetPoint("CENTER", "BOTTOM", "CENTER",-45);
	self.iz_pwp_hud.label = &"Invisible Zombies: ";
	self.iz_pwp_hud.alpha = 0;
}

invis_zomb_powerup(powerup, player)
{
	level notify( "invis_zombie_powerup_" + player.name );
	level endon( "invis_zombie_powerup_" + player.name );
	IPrintLnBold(player.name + " has hid the zombies");
	time = level.invis_zomb_powerup_duration;
	while(time > 0)
	{
		zombies = get_round_enemy_array();
		players = get_players();
		for(i=0;i<players.size;i++)
		{
			if(player == players[i] && !flag("solo_game"))
			{
				i++;
				continue;
			}
			players[i].iz_pwp_hud.alpha = 1;
			players[i].iz_pwp_hud SetValue(Int(time));
			for(k=0;k<zombies.size;k++)
			{
				zombies[k] SetInvisibleToPlayer(players[i]);
			}
		}
		wait 1;
		time--;
	}
	for(i=0;i<get_players().size;i++)
		get_players()[i].iz_pwp_hud.alpha = 0;
	zombies = get_round_enemy_array();
	foreach(zombie in zombies)
		zombie SetVisibleToAll();
}