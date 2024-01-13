using { /Verse.org/Simulation }
using { MovementExtensions }
using { SimulationExtensions }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices }

PlayerExtensions<public> := module:
    MakeAgentName<localizes> (Agent:agent):message= "{Agent}"

    figure<public> := class<abstract><unique>:
        Player<public>:player
        CameraPos<public>:vector3

        RequestMove<public>(Position:tuple(int, int)):void

        Spawn<public>(SpawnTranslation:vector3)<decides><transacts>:void

        Show<public>():void

        Move<public>(NewTranslation:vector3)<suspends>:void

    prop_figure<public> := class<abstract>(figure):
        Asset<public>:asset
        PlayerName<public>:billboard_device
        var Prop<protected>:dimensional = dimensional{}
        var IsMoving<protected>:logic = false
        var NameRotation<private>:rotation = IdentityRotation()

        block:
            set NameRotation = IdentityRotation().ApplyWorldRotationX(DegreesToRadians(90.0)).ApplyWorldRotationZ(DegreesToRadians(90.0))

        GetNameTranslation(PropTranslation:vector3)<transacts>:vector3 =
            RelativePropPos := PropTranslation - CameraPos
            NameHeight := -1024.0
            Factor := Abs(NameHeight / RelativePropPos.Z)
            CameraPos + RelativePropPos * Factor

        SetUp<public>():void =
            PlayerName.SetText(MakeAgentName(Player))

        Spawn<override>(SpawnTranslation:vector3)<decides><transacts>:void =
            set Prop = Asset.SpawnOnSurface[SpawnTranslation]
            NameTranslation := GetNameTranslation(Prop.Object.GetTransform().Translation)
            PlayerName.TeleportTo[NameTranslation, NameRotation]

        Show<override>():void =
            PlayerName.ShowText()

        Move<override>(NewTranslation:vector3)<suspends>:void =
            sync:
                Prop.MoveToSurface(NewTranslation, 0.4)
                block:
                    NameTranslation := GetNameTranslation(Prop.ToSurface(NewTranslation))
                    PlayerName.MoveTo(NameTranslation, NameRotation, 0.4)
            set IsMoving = false

    respawnable_prop_figure<public> := class(prop_figure, monitorable):
        PlacementRequest<public>:event(respawnable_prop_figure)
        DisplacementRequest<public>:event(respawnable_prop_figure)
        MoveRequest<public>:event(tuple(respawnable_prop_figure, int, int))
        RemovalRequest<public>:event(player)

        RequestMove<override>(Position:tuple(int, int)):void =
            if (not IsMoving?):
                set IsMoving = true
                MoveRequest.Signal((Self, Position(0), Position(1)))

        Update<override>():void =
            if (not Prop.Object.IsValid[]):
                PlayerName.HideText()
                PlacementRequest.Signal(Self)