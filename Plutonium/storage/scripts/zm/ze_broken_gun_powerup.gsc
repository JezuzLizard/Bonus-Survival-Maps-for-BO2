#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;

init()
{
	if(level.zeGamemode != "sharpshooter")
		return;
	level.broken_gun_powerup_duration = 10;
	add_zombie_powerup( "broken_gun", "t6_wpn_ar_m14_world", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_always_drop, 1, 0, 0 );
	powerup_set_can_pick_up_in_last_stand( "broken_gun", 0 );
	onplayerconnect_callback(::create_broken_gun_hud);
}

create_broken_gun_hud()
{
	self.bg_pwp_hud = self CreateFontString("Objective", 1.25);
	self.bg_pwp_hud SetPoint("CENTER", "BOTTOM", "CENTER", 15);
	self.bg_pwp_hud.label = &"Broken Gun: ";
	self.bg_pwp_hud.alpha = 0;
}

broken_gun_powerup(powerup, player)
{
	level notify( "broken_gun_powerup_" + player.name );
	level endon( "broken_gun_powerup_" + player.name );
	time = level.broken_gun_powerup_duration;
	IPrintLnBold(player.name + " has disabled everyone's Weapons");
	while(time > 0)
	{
		players = get_players();
		for(i=0;i<players.size;i++)
		{
			if(player == players[i] && !flag("solo_game"))
			{
				i++;
				continue;
			}
			players[i] DisableWeapons();
			players[i].bg_pwp_hud.alpha = 1;
			players[i].bg_pwp_hud SetValue(Int(time));
		}
		wait 1;
		time--;
	}
	players = get_players();
	foreach(player in players)
	{
		player EnableWeapons();
		player.bg_pwp_hud.alpha = 0;
	}
}