#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_powerups;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;

init()
{
	if(level.zeGamemode != "sharpshooter")
		return;
	level.bottomclip_duration = 20;
	add_zombie_powerup( "bottom_clip", "zombie_ammocan", &"ZOMBIE_POWERUP_MAX_AMMO", ::func_should_always_drop, 1, 0, 0 );
	powerup_set_can_pick_up_in_last_stand( "bottom_clip", 0 );
	onplayerconnect_callback(::create_bottom_clip_hud);
}

create_bottom_clip_hud()
{
	self.bc_pwp_hud = CreateFontString("Objective", 1.25);
	self.bc_pwp_hud SetPoint("CENTER", "BOTTOM", "CENTER", 0);
	self.bc_pwp_hud.label = &"Infinite Ammo: ";
	self.bc_pwp_hud.alpha = 0;
}

bottom_clip_powerup(powerup, player)
{
	level notify( "bottom_powerup_" + player.name );
	level endon( "bottom_powerup_" + player.name );
	time = level.bottomclip_duration;
	player.bc_pwp_hud.alpha = 1;
	while(time > 0)
	{
		player.bc_pwp_hud SetValue(Int(time));
		player SetWeaponAmmoClip(player GetCurrentWeapon(), weaponclipsize(player GetCurrentWeapon()));
		wait .1;
		time -= .1;
	}
	player.bc_pwp_hud.alpha = 0;
}