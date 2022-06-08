/* GSC SHAX */

gsc_shax(gun, reloadtime, show, take)
{
    self giveWeapon(gun);
    self switchToWeapon(gun);
    self setSpawnWeapon(gun);
    old_clip = self GetWeaponAmmoClip(gun);
    setDvar("cg_drawgun", 0);
    setDvar("cg_drawCrosshair", 0);
    self setClientDvar("perk_weapReloadMultiplier", reloadtime);
    waitframe();
    self setWeaponAmmoClip(gun, 0);
    wait 0.01;
    self setWeaponAmmoClip(gun, old_clip);
    wait show;
    self setSpawnWeapon(gun);
    self setClientDvar("perk_weapReloadMultiplier", 0.5);
    setDvar("cg_drawgun", 1);
    setDvar("cg_drawCrosshair", 1);
    wait take;
    self takeWeapon(gun);
}

/*

    Usage:

    gun = shax gun of preference.
    reloadtime = speed of reload time.
    show = time it takes to show the shax gun.
    take = time it takes to take the shax gun.

    Example:
    thread gsc_shax("ump45_mp", .32, .64, .15);


*/

/* Round Timer Reset */

do_reset_timer()
{
    level endon("game_ended");
    level endon("round_end_finished");
    for(;;)
    {
        if(isDefined(level.pers["timer_reset"]))
        {
            if(game["state"] == "postgame")
            {
                setDvar("scr_sd_timelimit", 2.5);
            } else if (getTimeRemaining() < 5025) {
                setDvar("scr_sd_timelimit", getDvarFloat("scr_sd_timelimit") + 2.5);
                wait 5;
            }
        }
        waitframe();
    }
}

/*
    Usage:

    Requires setDvar("scr_sd_timelimit", 2.5); to be set @ spawn!
    Call it as thread do_reset_timer(); on init!
    Also call: level.pers["timer_reset"] = true;
*/

/* Smooth Anim Bind */

smooth_anim_toggle()
{
    if(!self.smooth_anim)
    {
        self.smooth_anim = true;
        self thread smooth_anim_bind();
    } else {
        self.smooth_anim = false;
        self notify("stop_smooth");
    }
}

smooth_anim_bind()
{
    self endon("disconnect");
    self endon("stop_smooth");
    for(;;)
    {
        self notifyOnPlayerCommand("smooth", "+actionslot 2");
        self waittill("smooth");
        if(self getCurrentWeapon() == self.primaryWeapon)
        {
            setDvar("cg_nopredict", 1);
            self switchToWeapon(self.secondaryWeapon);
            waitframe();
            self switchToWeapon(self.primaryWeapon);
            waitframe();
            setDvar("cg_nopredict", 0);
        }
        else
        {
            setDvar("cg_nopredict", 1);
            self switchToWeapon(self.primaryWeapon);
            waitframe();
            self switchToWeapon(self.secondaryWeapon);
            waitframe();
            setDvar("cg_nopredict", 0);
        }
    }
}

/* Shotgun Jumps */

shotgun_jump_toggle()
{
    if(!self.shotgun_jump)
    {
        self.shotgun_jump = true;
        self thread initiate_shotgun();
    } else {
        self.shotgun_jump = false;
        self notify("stop_shotgun");
    }
}

initiate_shotgun()
{
    self endon("stop_shotgun");
    self endon("disconnect");
    for(;;)
    {
        self waittill("weapon_fired", weapon);
        if(weapon == "spas12_mp")
        {
            self maps\mp\gametypes\_damagefeedback::updateDamageFeedback("damage_feedback");
            self thread [[ level.callbackPlayerDamage ]](self,self,5,8,"MOD_RIFLE_BULLET",weapon,(0,0,0),(0,0,0),"left_lower_leg",0,0);
            self setVelocity((150,50,250)); /* Feel Free to Adjust This */
        }
        waitframe();
    }
}
