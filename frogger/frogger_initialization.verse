using { BoardExtensions }
using { MovementExtensions }
using { PlayerExtensions }
using { FroggerExtensions }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }

FroggerInitialization<public> := module:
    CreateBoard(Pivot:vector3, Lanes:int, Asset:asset)<transacts>:[][]space =
        for (X := 0..Lanes - 1):
            for:
                Y := 0..Floor(Lanes * 9 / 16) - 1
                Translation := Pivot + Asset.Size * vector3{X := X * 1.0, Y := Y * 1.0, Z := 1.0}
                Rotation := IdentityRotation().ApplyLocalRotationZ(DegreesToRadians(90.0))
                Result := SpawnProp(Asset.PropAsset, Translation, Rotation)
                Prop := Result(0)?
            do:
                space:
                    Position := (X, Y)
                    Offset := Asset.Offset
                    Size := Asset.Size
                    Facing := Asset.Facing
                    Object := Prop

    CreateFrog<public>(Asset:creative_prop_asset, Player:player, State:state):respawnable_prop_figure =
        respawnable_prop_figure:
            Asset := Asset
            Player := Player
            PlacementRequest := State.PlacementRequest
            DisplacementRequest := State.DisplacementRequest
            MoveRequest := State.MoveRequest
            RemovalRequest := State.RemovalRequest

    CreateFroggerState<public>(Pivot:vector3, Lanes:int, Asset:asset)<transacts>:state =
        state:
            Board := CreateBoard(Pivot, Lanes, Asset)
            GetSpawn := GetFroggerSpawn
            UpdateForMove := FroggerMove
            IsComplete := IsFroggerComplete