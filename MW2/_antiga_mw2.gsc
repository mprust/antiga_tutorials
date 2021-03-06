/* 
    GSC SHAX
    Usage:

    gun = shax gun of preference.
    reloadtime = speed of reload time.
    show = time it takes to show the shax gun.
    take = time it takes to take the shax gun.
    
    exagerate_shax = toggle smooth slowdown of shax anim.

    Example:
    thread gsc_shax("ump45_mp", .32, .64, .15);
*/

exagerate_shax()
{
    if(!self.pers["exag_shax"])
        self.pers["exag_shax"] = true;
    else
        self.pers["exag_shax"] = false;
}

gsc_shax(gun, reloadtime, show, take)
{
    old_timescale = getDvarFloat("timescale");
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
    if(self.pers["exag_shax"])
    {
        setDvar("timescale", 0.25);
    }
    self setSpawnWeapon(gun);
    self setClientDvar("perk_weapReloadMultiplier", 0.5);
    setDvar("cg_drawgun", 1);
    setDvar("cg_drawCrosshair", 1);
    wait take;
    self takeWeapon(gun);
    if(self.pers["exag_shax"])
    {
        setDvar("timescale", old_timescale);
    }
}

/* 
    Round Timer Reset 
*/

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

/* 
    Smooth Anim Bind 
*/

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
            waitframe();
            self switchToWeapon(self.secondaryWeapon);
            waitframe();
            self switchToWeapon(self.primaryWeapon);
            waitframe();
            setDvar("cg_nopredict", 0);
        }
        else
        {
            setDvar("cg_nopredict", 1);
            waitframe();
            self switchToWeapon(self.primaryWeapon);
            waitframe();
            self switchToWeapon(self.secondaryWeapon);
            waitframe();
            setDvar("cg_nopredict", 0);
        }
    }
}

/* 
    Shotgun Jumps 
*/

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

/*
    Menu Based Class Editor:
    Example use: 
    self addOption("primary", "WA2K", ::change_weapon, "wa2000"); //Primary
    self addOption("camoE", "Primary Camo [Fall]", ::set_weapon_camo, "orange_fall"); //Primary Camo
    self addOption("secondary", "MP5k", ::change_weapon, undefined, "mp5k"); //Secondary
    self addOption("camoE", "Secondary Camo [Red]", ::set_weapon_camo, undefined, "red_tiger"); //Secondary Camo
    self addOption("primaryA", "FMJ", ::set_weapon_attachments, "fmj"); //Primary Attachments
    self addOption("secondaryA", "FMJ", ::set_weapon_attachments, undefined, undefined, "fmj"); //Secondary Attachments
    self addOption("perk1", "Marathon", ::set_perk_force, "specialty_marathon"); //Perk 1
    self addOption("perk2", "Stopping Power", ::set_perk_force, undefined, "specialty_bulletdamage"); //Perk2
    self addOption("perk3", "Steady Aim", ::set_perk_force, undefined, undefined, "specialty_bulletaccuracy"); //Perk 3
    self addOption("lethal", "Frag", ::set_equipment_function, "frag_grenade_mp"); //Lethal EQ
    self addOption("offhand", "Flash", ::set_equipment_function, undefined, "flash_grenade"); //Offhand EQ
*/

set_perk_force(perk, perk2, perk3)
{
    my_class = self.pers["class"];
    class_number = self thread maps\mp\gametypes\_class::getClassIndex(my_class);
    waitframe();
    if(isDefined(perk))
        self setPlayerData("customClasses", class_number, "perks", 1, perk);
    if(isDefined(perk2))
        self setPlayerData("customClasses", class_number, "perks", 2, perk2);
    if(isDefined(perk3))
        self setPlayerData("customClasses", class_number, "perks", 3, perk3);
}

set_equipment_function(lethal, offSe)
{
    my_class = self.pers["class"];
    class_number = self thread maps\mp\gametypes\_class::getClassIndex(my_class);
    waitframe();
    if(isDefined(lethal))
        self setPlayerData("customClasses", class_number, "perks", 0, lethal);
    if(isDefined(offSe))
        self setPlayerData("customClasses", class_number, "specialGrenade", offSe);
}

change_weapon(primary, secondary)
{
    my_class = self.pers["class"];
    class_number = self thread maps\mp\gametypes\_class::getClassIndex(my_class);
    waitframe();
    if(isDefined(primary))
        self setPlayerData("customClasses", class_number, "weaponSetups", 0, "weapon", primary);
    if(isDefined(secondary))
        self setPlayerData("customClasses", class_number, "weaponSetups", 1, "weapon", secondary);
}

set_weapon_attachments(at1, at2, st1, st2)
{
    my_class = self.pers["class"];
    class_number = self thread maps\mp\gametypes\_class::getClassIndex(my_class);
    waitframe();
    if(isDefined(at1))
        self setPlayerData("customClasses", class_number, "weaponSetups", 0, "attachment", 0, at1);
    if(isDefined(at2))
        self setPlayerData("customClasses", class_number, "weaponSetups", 0, "attachment", 1, at2);
    if(isDefined(st1))
        self setPlayerData("customClasses", class_number, "weaponSetups", 1, "attachment", 0, st1);
    if(isDefined(st2))
        self setPlayerData("customClasses", class_number, "weaponSetups", 1, "attachment", 1, st2);

}

set_weapon_camo(ca1, ca2)
{
    my_class = self.pers["class"];
    class_number = self thread maps\mp\gametypes\_class::getClassIndex(my_class);
    waitframe();
    if(isDefined(ca1))
        self setPlayerData("customClasses", class_number, "weaponSetups", 0, "camo", ca1);
    if(isDefined(ca2))
        self setPlayerData("customClasses", class_number, "weaponSetups", 1, "camo", ca2);
}

/*
    Two Different Types of Mala's
        - One force setting spawn weapon (can't shoot).
        - 2nd one is an genuine mala (can shoot).
*/

force_mala_mw2_toggle()
{
    if(!self.mw2_toggle)
    {
        self.mw2_toggle = true;
        self thread //whatevermalayouwanthere.
    } else {
        self.mw2_toggle = false;
        self notify("stop_mala_mod");
    }
}

force_mala_spawn()
{
    self endon("disconnect");
    self endon("stop_mala_mod");
    for(;;)
    {
        self waittill("grenade_pullback", grenade);
        self setSpawnWeapon(grenade);
        waitframe();
    }
}

force_mala_shoot()
{
    self endon("disconnect");
    self endon("stop_mala_mod");
    for(;;)
    {
        self waittill("grenade_pullback", grenade);
        my_class = self.pers["class"];
        my_weapon = self getCurrentWeapon();
        old_clip = self getWeaponAmmoClip(my_weapon);
        old_stock = self getWeaponAmmoStock(my_weapon);
        waitframe();
        self maps\mp\gametypes\_class::setClass(my_class);
        self maps\mp\gametypes\_class::giveLoadout(self.pers["team"],my_class);
        self setWeaponAmmoStock(my_weapon, old_stock);
        self setWeaponAmmoClip(my_weapon, old_clip);
    }    
}

/*
    Airspace Full Toggle
*/

force_airspace_full()
{
    if(!self.airpace_full)
    {
        self.airpace_full = true;
        level.littleBirds = 4;
    } else {
        self.airpace_full = false;
        level.littleBirds = 0;
    }
}

/* 
    Delete All Carepackages Bind
*/

delete_care_packages()
{
    self endon("disconnect");
    for(;;)
    {
        self notifyOnPlayerCommand("delete_me", "delete_me");
        self waittill("delete_me");
        level.airDropCrates = getEntArray( "care_package", "targetname" );
        level.oldAirDropCrates = getEntArray( "airdrop_crate", "targetname" );
        
        if ( !level.airDropCrates.size )
        {	
            level.airDropCrates = level.oldAirDropCrates;
            
            assert( level.airDropCrates.size );
            
            level.airDropCrateCollision = getEnt( level.airDropCrates[0].target, "targetname" );
        }
        else
        {
            foreach ( crate in level.oldAirDropCrates ) 
                crate delete();
            
            level.airDropCrateCollision = getEnt( level.airDropCrates[0].target, "targetname" );
            level.oldAirDropCrates = getEntArray( "airdrop_crate", "targetname" );
        }
        
        if ( level.airDropCrates.size )
        {
            foreach ( crate in level.AirDropCrates )
            {
                _objective_delete( crate.objIdFriendly );
                _objective_delete( crate.objIdEnemy );
                crate delete();
            }
        }
        waitframe();
    }
}

/*
    Change AC-130 Timer via Dvar
        - Make sure you setDvarIfUninitialized("rewrite_ac130", 0);
*/

rewrite_ac130_timer()
{
    if(!getDvarInt("rewrite_ac130"))
    {
        setDvar("rewrite_ac130", 1);
        level.ac130_use_duration = 5;
        makeDvarServerInfo( "ui_ac130usetime", level.ac130_use_duration );

    } else {
        setDvar("rewrite_ac130", 0);
        level.ac130_use_duration = 40;
        makeDvarServerInfo( "ui_ac130usetime", level.ac130_use_duration );
    }
}

/*
    Glide/SetSpawnWeapon Assistance
*/

glide_assis_toggle()
{
    if(!self.glide_toggle)
    {
        self.glide_toggle = true;
        self.pers["glide_weapon"] = self getCurrentWeapon();
        self thread glide_assistance();
    } else {
        self.glide_toggle = false;
        self.pers["glide_weapon"] = undefined;
        self notify("stop_glides");
    }
}

glide_assistance()
{
    self endon("disconnect");
    self endon("stop_glides");
    for(;;)
    {
        self waittill("weapon_change", weapon);
        if(weapon == self.pers["glide_weapon"])
            self setSpawnWeapon(weapon);
        waitframe();
    }
}

/*
    Always Canswap (HOST is best) that keeps camo's from your loadout
*/

canswap_mod_toggle()
{
    if(!self.monitor_can)
    {
        self.monitor_can = true;
        self thread monitor_canswaps();
    } else {
        self.monitor_can = false;
        self notify("stop_mod");
    }
}

monitor_canswaps()
{
    self endon("disconnect");
    self endon("stop_mod");
    for(;;)
    {
        self waittill("weapon_change");
        my_weapon = self getCurrentWeapon();
        if(my_weapon == self.primaryWeapon)
        {
            self takeWeapon(my_weapon);
            self giveWeapon(my_weapon, self.loadoutPrimaryCamo);
            self switchToWeapon(my_weapon);
        }
        else
        {
            self takeWeapon(my_weapon);
            self giveWeapon(my_weapon, self.loadoutSecondaryCamo);
            self switchToWeapon(my_weapon);
        }
        waitframe();
    }
}

/*
    Drop Weapon + Delete Weapon on Command

    Parse: 
        - player.pers["drop_toggle"] = false; via PlayerConnect
        - player.pers["delete_dropped"] = false; via PlayerConnect

    drop_weapon_toggle = the toggle to enable/disable the drop weapon command.
    delete_weapons_toggle = the toggle to enable/disable the deletion of weapons on the ground.
*/

drop_weapon_toggle()
{
    if(!self.pers["drop_toggle"])
    {
        self.pers["drop_toggle"] = true;
        self thread drop_weapon();
    } else {
        self.pers["drop_toggle"] = false;
        self notify("stop_drop_toggle");
    }
}

drop_weapon()
{
    self endon("disconnect");
    self endon("stop_drop_toggle");
    for(;;)
    {
        self notifyOnPlayerCommand("drop", "+drop"); //Change this to whatever you want.
        self waittill("drop");
        self.pers["item_ground"] = self dropItem(self getCurrentWeapon());
        waitframe();
    }   
}

delete_weapons_toggle()
{
    if(!self.pers["delete_dropped"])
    {
        self.pers["delete_dropped"] = true;
        self thread delete_weapons_off_floor();
    } else {
        self.pers["delete_dropped"] = false;
        self notify("stop_delete_toggle");
    }    
}

delete_weapons_off_floor()
{
    self endon("disconnect");
    self endon("stop_delete_toggle");
    for(;;)
    {
        self notifyOnPlayerCommand("dg", "+dg"); //Change this to whatever you want.
        self waittill("dg");
        self.pers["item_ground"] delete();
        waitframe();
    }
}

/*
    Use Bar Command with Delete Option Command

    Parse:
        - player.pers["bar_cmd"] = false; via PlayerConnect
        - player.pers["delete_bar"] = false; via PlayerConnect
    
    do_bar_cmd = the toggle to enable/disable the custom bar command.
    destroy_all_cmd = the toggle to enable/disable the delete custom bar command.
*/

do_bar_cmd()
{
    if(!self.pers["bar_cmd"])
    {
        self.pers["bar_cmd"] = true;
        self thread do_custom_bar_cmd();
    } else {
        self.pers["bar_cmd"] = false;
        self notify("stop_bar_cmd");
    }    
}

do_custom_bar_cmd()
{
    self endon("disconnect");
    self endon("stop_bar_cmd");
    for(;;)
    {
        self notifyOnPlayerCommand("ba", "+ba"); //Change this to whatever you want.
        self waittill("ba");
        self thread custom_bar(5);
        waitframe();
    }
}

custom_bar( duration )
{
	self endon( "disconnect" );
	
	self.pers["useBar"] = createPrimaryProgressBar( 0 ); //Change this to whatever you want.
	self.pers["useBarText"] = createPrimaryProgressBarText( 0 ); //Change this to whatever you want.
	self.pers["useBarText"] setText( "^:Antiga Tutorials.." ); //Change this to whatever you want.

	self.pers["useBar"] updateBar( 0, 1 / duration );
	for ( waitedTime = 0; waitedTime < duration && isAlive( self ) && !level.gameEnded; waitedTime += 0.05 )
		wait ( 0.05 );
	
	self.pers["useBar"] destroyElem();
	self.pers["useBarText"] destroyElem();
}

destroy_all_cmd()
{
    if(!self.pers["delete_bar"])
    {
        self.pers["delete_bar"] = true;
        self thread destroy_all_bars();
    } else {
        self.pers["delete_bar"] = false;
        self notify("stop_del_bar");
    }    
}

destroy_all_bars()
{
    self endon("disconnect");
    self endon("stop_del_bar");
    for(;;)
    {
        self notifyOnPlayerCommand("db", "+db"); //Change this to whatever you want.
        self waittill("db");
        self.pers["useBar"] destroyElem();
        self.pers["useBarText"] destroyElem();
        waitframe();
    }
}

/*
    Enables Canzoom + OMA Shax
        - Included a DVAR to allow editing on OMA Timer.
    
    Parse:
        - player.pers["oma_modified"] = false; via PlayerConnect
        - setDvarIfUninitialized("oma_overwrite", "Whatever You Want!");
        
    oma_shax_or_zoom = the toggle to enable/disable the ability to canzoom/oma shax.
    giveOneManArmyClass = replace this function in _perkFunctions in order to utilize what is below.
*/

oma_shax_or_zoom()
{
    if(!self.pers["oma_modified"])
        self.pers["oma_modified"] = true;
    else
        self.pers["oma_modified"] = false;
}

giveOneManArmyClass( className )
{
	self endon ( "death" );
	self endon ( "disconnect" );
	level endon ( "game_ended" );

	if ( self _hasPerk( "specialty_omaquickchange" ) )
	{
		changeDuration = 3.0;
		self playLocalSound( "foly_onemanarmy_bag3_plr" );
		self playSoundToTeam( "foly_onemanarmy_bag3_npc", "allies", self );
		self playSoundToTeam( "foly_onemanarmy_bag3_npc", "axis", self );
	}
	else
	{
		changeDuration = 6.0;
		self playLocalSound( "foly_onemanarmy_bag6_plr" );
		self playSoundToTeam( "foly_onemanarmy_bag6_npc", "allies", self );
		self playSoundToTeam( "foly_onemanarmy_bag6_npc", "axis", self );
	}
		
	self thread omaUseBar( getDvarInt("oma_overwrite") );

	if(!self.pers["oma_modified"])
	{
		self _disableWeapon();
		self _disableOffhandWeapons();
		wait ( getDvarInt("oma_overwrite") );
		self _enableWeapon();
		self _enableOffhandWeapons();
		self maps\mp\gametypes\_class::giveLoadout( self.pers["team"], className, false );
	} else {
		old_weapon = self getCurrentWeapon();
		waitframe();
		self takeWeapon(old_weapon);
		self _disableOffhandWeapons();
		wait ( getDvarInt("oma_overwrite") );
		self giveWeapon(old_weapon);
		self setSpawnWeapon(old_weapon);
		self _enableOffhandWeapons();		
	}

	self.OMAClassChanged = true;
	
	// handle the fact that detachAll in giveLoadout removed the CTF flag from our back
	// it would probably be better to handle this in _detachAll itself, but this is a safety fix
	if ( isDefined( self.carryFlag ) )
		self attach( self.carryFlag, "J_spine4", true );
	
	self notify ( "changed_kit" );
	level notify ( "changed_kit" );
}
