using { /Verse.org/Simulation }

XPExtensions<public> := module:
    achievement<public> := enum{Pair, Round, Streak, Time}

    xp_closure<public> := class:
        Func<public>:type{_(:player, :achievement):void}
        Player<public>:player
        Achievement<public>:achievement

        Grant<public>():void =
            Func(Player, Achievement)