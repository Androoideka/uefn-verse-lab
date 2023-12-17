using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }

SpaceExtensions<public> := module:
    FromXYZ<public>(X:float, Y:float, Z:float)<computes>:vector3 =
        vector3{X := X, Y := Y, Z := Z}

    (Size:int).GetRangeWithCenter<public>()<decides><computes>:tuple(int, int) =
        (Ceil(-Size / 2), Floor(Size / 2))

    monitorable<public> := interface:
        Update():void

    ticker<public> := class:
        Monitorables<public>:[]monitorable

        Monitor<public>()<suspends>:void =
            loop:
                Sleep(0.0)
                for (Monitorable : Monitorables):
                    Monitorable.Update()

    tile<public> := class(monitorable):
        Cell<public>:tuple(int, int)

        Model<public>:creative_prop
        Asset<public>:creative_prop_asset

        RegisterHit<public>:type{_(:tuple(int, int))<transacts>:void}

        var Prop<private>:creative_prop = creative_prop{}

        Spawn<private>():void =
            Result := SpawnProp(Asset, Model.GetTransform().Translation + FromXYZ(0.0, 0.0, 50.1), IdentityRotation())
            if (set Prop = Result(0)?) {}

        Instantiate<public>():void =
            SetDead()
            Spawn()

        Update<override>():void =
            if (not Prop.IsValid[]):
                RegisterHit(Cell)
                SetLiving()
                Spawn()

        SetLiving<public>():void =
            Model.SetMaterial(LivingCell)

        SetDead<public>():void =
            Model.SetMaterial(DeadCell)