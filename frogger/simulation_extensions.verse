using { /Verse.org/Simulation }

SimulationExtensions<public> := module:
    monitorable<public> := interface:
        Update<public>():void

    tasker<public> := interface:
        Run<public>()<suspends>:void

    ticker<public> := class(tasker):
        var Monitorables<public>:[]monitorable = array{}

        AddMonitorable<public>(Monitorable:monitorable)<transacts>:void =
            set Monitorables = Monitorables + array{Monitorable}

        Run<override>()<suspends>:void =
            loop:
                Sleep(0.0)
                for (Monitorable : Monitorables):
                    Monitorable.Update()