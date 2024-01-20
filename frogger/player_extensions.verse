using { /Verse.org/Simulation }
using { MovementExtensions }
using { SimulationExtensions }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices }

PlayerExtensions<public> := module:
    MakeAgentName<localizes> (Agent:agent):message= "{Agent}"

    label<public> := class:
        Display<public>:billboard_device
        CameraTransform<public>:transform

        block:
            Rotation := IdentityRotation().ApplyWorldRotationX(DegreesToRadians(90.0)).ApplyWorldRotationZ(DegreesToRadians(-90.0))
            if (Display.TeleportTo[Display.GetTransform().Translation, Rotation]) {}

        ToSurface(Surface:vector3)<transacts>:vector3 =
            RelativeTranslation := Surface + vector3{X := 384.0, Y := 0.0, Z := 128.0} - CameraTransform.Translation
            NameHeight := -1024.0
            Factor := Abs(NameHeight / RelativeTranslation.Z)
            CameraTransform.Translation + RelativeTranslation * Factor

        TeleportTo<public>(Surface:vector3)<decides><transacts>:void =
            Display.TeleportTo[ToSurface(Surface), Display.GetTransform().Rotation]

        MoveTo<public>(Surface:vector3, Time:float)<suspends>:void =
            Display.MoveTo(ToSurface(Surface), Display.GetTransform().Rotation, Time)

    figure<public> := class<abstract><unique>:
        Player<public>:player

        RequestMove<public>(Position:tuple(int, int)):void

        Spawn<public>(SpawnTranslation:vector3)<decides><transacts>:void

        Show<public>():void

        Move<public>(NewTranslation:vector3)<suspends>:void

    prop_figure<public> := class<abstract>(figure):
        Asset<public>:asset
        PlayerName<public>:label
        var Prop<protected>:dimensional = dimensional{}
        var IsMoving<protected>:logic = false

        SetUp<public>():void =
            PlayerName.Display.SetText(MakeAgentName(Player))

        Spawn<override>(SpawnTranslation:vector3)<decides><transacts>:void =
            set Prop = Asset.SpawnOnSurface[SpawnTranslation]
            PlayerName.TeleportTo[Prop.ToSurface(SpawnTranslation)]

        Show<override>():void =
            PlayerName.Display.ShowText()

        Move<override>(NewTranslation:vector3)<suspends>:void =
            set IsMoving = true
            sync:
                Prop.MoveToSurface(NewTranslation, 0.4)
                PlayerName.MoveTo(Prop.ToSurface(NewTranslation), 0.4)
            set IsMoving = false

    respawnable_prop_figure<public> := class(prop_figure, monitorable):
        PlacementRequest<public>:event(respawnable_prop_figure)
        MoveRequest<public>:event(tuple(respawnable_prop_figure, int, int))
        RemovalRequest<public>:event(player)

        RequestMove<override>(Position:tuple(int, int)):void =
            if (not IsMoving?):
                MoveRequest.Signal((Self, Position(0), Position(1)))

        Update<override>():void =
            if (not Prop.Object.IsValid[]):
                PlayerName.Display.HideText()
                PlacementRequest.Signal(Self)