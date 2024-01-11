using { /Verse.org/Simulation }
using { SimulationExtensions }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices }

PlayerExtensions<public> := module:
    figure<public> := class<abstract><unique>:
        Player<public>:player

        RequestMove<public>(Position:tuple(int, int)):void

        Spawn<public>(SpawnTranslation:vector3)<decides><transacts>:void

        Move<public>(NewTranslation:vector3)<suspends>:void

    prop_figure<public> := class<abstract>(figure):
        Asset<public>:creative_prop_asset
        var Prop<protected>:creative_prop = creative_prop{}

        Spawn<override>(SpawnTranslation:vector3)<decides><transacts>:void =
            Result := SpawnProp(Asset, SpawnTranslation, IdentityRotation())
            set Prop = Result(0)?

        Move<override>(NewTranslation:vector3)<suspends>:void =
            Rotation := MakeShortestRotationBetween(Prop.GetTransform().Translation, NewTranslation)
            Prop.MoveTo(NewTranslation, Rotation, 0.5)

    respawnable_prop_figure<public> := class(prop_figure, monitorable):
        PlacementRequest<public>:event(respawnable_prop_figure)
        DisplacementRequest<public>:event(respawnable_prop_figure)
        MoveRequest<public>:event(tuple(respawnable_prop_figure, int, int))
        RemovalRequest<public>:event(player)

        RequestMove<override>(Position:tuple(int, int)):void =
            MoveRequest.Signal((Self, Position(0), Position(1)))

        Update<override>():void =
            if (not Prop.IsValid[]):
                PlacementRequest.Signal(Self)