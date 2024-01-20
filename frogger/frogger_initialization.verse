using { BoardExtensions }
using { MovementExtensions }
using { PlayerExtensions }
using { ProgressExtensions }
using { FroggerExtensions }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }

FroggerInitialization<public> := module:
    AspectRatio:tuple(int, int) = (16, 9)

    CreateBoard(Pivot:vector3, Lanes:int, Asset:asset)<transacts>:[][]space =
        for (X := 0..Lanes - 1, Width := Floor(Lanes * AspectRatio(0) / AspectRatio(1)) - 1):
            for:
                Y := 0..Width
                Translation := Pivot + Asset.Size * vector3{X := (Lanes - 1 - X) * 1.0, Y := (Width - Y) * 1.0, Z := 1.0}
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

    CreateFrog<public>(Asset:asset, Label:label, Player:player, State:state):respawnable_prop_figure =
        Frog := respawnable_prop_figure:
            Asset := Asset
            PlayerName := Label
            Player := Player
            PlacementRequest := State.PlacementRequest
            MoveRequest := State.MoveRequest
            RemovalRequest := State.RemovalRequest
        Frog.SetUp()
        Frog

    CreateFroggerState<public>(Pivot:vector3, Lanes:int, Asset:asset, ProgressReporter:progress_reporter)<transacts>:state =
        state:
            Board := CreateBoard(Pivot, Lanes, Asset)
            ProgressReporter := ProgressReporter
            GetSpawn := GetFroggerSpawn
            UpdateForMove := FroggerMove
            GetFinishedPieces := GetFroggerFinishedPlayers