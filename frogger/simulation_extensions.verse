using { /Verse.org/Simulation }

SimulationExtensions<public> := module:
    tasker<public> := interface:
        Start<public>()<suspends>:void
    
    monitorable<public> := interface:
        Update<public>():void

    ticker<public> := class(tasker):
        var Monitorables<public>:[]monitorable = array{}

        AddMonitorable<public>(Monitorable:monitorable)<transacts>:void =
            set Monitorables = Monitorables + array{Monitorable}

        Start<override>()<suspends>:void =
            loop:
                Sleep(0.0)
                for (Monitorable : Monitorables):
                    Monitorable.Update()