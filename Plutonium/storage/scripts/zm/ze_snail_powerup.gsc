#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;

init()
{
	if(level.zeGamemode != "sharpshooter")
		return;
	level.snail_powerup_duration = 10;
	if(level.script == "zm_prison")
		snail_powerup_model = "p6_anim_zm_al_magic_box_lock";
	else
		snail_powerup_model = "zombie_teddybear";
	add_zombie_powerup( "snail", snail_powerup_model, &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_always_drop, 1, 0, 0 );
	powerup_set_can_pick_up_in_last_stand( "snail", 0 );
	onplayerconnect_callback(::create_snail_hud);
}

create_snail_hud()
{
	self.ss_pwp_hud = CreateFontString("Objective", 1.25);
	self.ss_pwp_hud SetPoint("CENTER", "BOTTOM", "CENTER",-30);
	self.ss_pwp_hud.label = &"Snail's Pace: ";
	self.ss_pwp_hud.alpha = 0;
}

snail_powerup(powerup, player)
{
	level notify( "snail_powerup_" + player.name );
	level endon( "snail_powerup_" + player.name );
	IPrintLnBold(player.name + " has slowed everyone");
	time = level.snail_powerup_duration;
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
			players[i] SetMoveSpeedScale(0.5);
			players[i].ss_pwp_hud.alpha = 1;
			players[i].ss_pwp_hud SetValue(Int(time));
		}
		wait 1;
		time--;
	}
	players = get_players();
	for(i=0;i<players.size;i++)
	{
		players[i] SetMoveSpeedScale(1);
		players[i].ss_pwp_hud.alpha = 0;
	}
}