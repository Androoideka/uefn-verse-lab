using { /Verse.org/Simulation }
using { MovementExtensions }
using { SimulationExtensions }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices }

PlayerExtensions<public> := module:
    MakeAgentName<localizes>(Agent:agent):message= "{Agent}"

    figure<public> := class<abstract><unique>:
        Player<public>:player

        RequestMove<public>(Direction:direction):void

        Spawn<public>(SpawnTranslation:vector3)<decides><transacts>:dimensional

        Show<public>():void

        Move<public>(NewTranslation:vector3)<suspends>:void

    prop_figure<public> := class<abstract>(figure):
        Asset<public>:asset
        PlayerName<public>:label
        var Prop<protected>:dimensional = dimensional{}
        var IsMoving<protected>:logic = false

        SetUp<public>():void =
            PlayerName.Display.SetText(MakeAgentName(Player))

        Spawn<override>(SpawnTranslation:vector3)<decides><transacts>:dimensional =
            OldProp := Prop
            set Prop = Asset.SpawnOnSurface[SpawnTranslation]
            PlayerName.TeleportTo[Prop.ToSurface(SpawnTranslation)]
            OldProp

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
        MoveRequest<public>:event(tuple(respawnable_prop_figure, direction))
        RemovalRequest<public>:event(player)
        MoveComplete<public>:event(respawnable_prop_figure)

        Move<override>(NewTranslation:vector3)<suspends>:void =
            (super:)Move(NewTranslation)
            MoveComplete.Signal(Self)

        RequestMove<override>(Direction:direction):void =
            if (not IsMoving?):
                MoveRequest.Signal((Self, Direction))

        Update<override>():void =
            if (not Prop.Object.IsValid[]):
                PlayerName.Display.HideText()
                PlacementRequest.Signal(Self)