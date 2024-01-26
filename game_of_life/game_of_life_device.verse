using { CollectionExtensions }
using { SpaceExtensions }
using { SimulationExtensions }
using { /Verse.org/Assets }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
game_of_life_device := class(creative_device):

    @editable
    XSize:int = 15

    @editable
    YSize:int = 15

    @editable
    IterationDelay:float = 2.0

    @editable
    TileAsset:creative_prop_asset = DefaultCreativePropAsset

    @editable
    HitAsset:creative_prop_asset = DefaultCreativePropAsset

    @editable
    BorderAsset:creative_prop_asset = DefaultCreativePropAsset

    @editable
    ResetButton:button_device = button_device{}

    @editable
    PauseSwitch:switch_device = switch_device{}

    var Hits:[]tuple(int, int) = array{}

    RegisterHit(Cell:tuple(int, int))<transacts>:void =
        if (not Contains(Hits, Cell)?):
            set Hits = Hits + array{Cell}

    ResetHits(Board:board, Tiles:[]tile):void =
        set Hits = array{}
        for (Tile : Tiles):
            if (Contains(Board.LivingCells, Tile.Cell)?):
                Tile.SetLiving()
            else:
                Tile.SetDead()

    Update(Board:board, Tiles:[]tile)<suspends>:void =
        NextBoard := race:
            block:
                Sleep(IterationDelay)
                if (not PauseSwitch.GetCurrentState[]):
                    PauseSwitch.TurnedOnEvent.Await()
                Board.Update(Hits)
            block:
                ResetButton.InteractedWithEvent.Await()
                board{XRange := Board.XRange, YRange := Board.YRange}
        ResetHits(NextBoard, Tiles)
        Update(NextBoard, Tiles)

    GenerateTiles(XRange:tuple(int, int), YRange:tuple(int, int)):[]tile =
        for:
            X := XRange(0)..XRange(1)
            Y := YRange(0)..YRange(1)
            Result := SpawnProp(TileAsset, FromXYZ(X * 100.0, Y * 100.0, 900.0), IdentityRotation())
            Model := Result(0)?
        do:
            Tile := tile{Cell := (X, Y), Model := Model, Asset := HitAsset, RegisterHit := RegisterHit}
            Tile.Instantiate()
            Tile

    GenerateBorders(XRange:tuple(int, int), YRange:tuple(int, int)):void =
        BorderTransforms := array:
            transform{Translation := FromXYZ((XRange(0) - 1) * 100.0, 0.0, 900.0), Scale := FromXYZ(1.0, YSize * 1.0, 20.0)}
            transform{Translation := FromXYZ((XRange(1) + 1) * 100.0, 0.0, 900.0), Scale := FromXYZ(1.0, YSize * 1.0, 20.0)}
            transform{Translation := FromXYZ(0.0, (YRange(0) - 1) * 100.0, 900.0), Scale := FromXYZ(XSize * 1.0, 1.0, 20.0)}
            transform{Translation := FromXYZ(0.0, (YRange(1) + 1) * 100.0, 900.0), Scale := FromXYZ(XSize * 1.0, 1.0, 20.0)}
        for:
            BorderTransform : BorderTransforms
            Result := SpawnProp(BorderAsset, BorderTransform)
            Border := Result(0)?
        do {}

    OnBegin<override>()<suspends>:void =
        if (XRange := XSize.GetRangeWithCenter[], YRange := YSize.GetRangeWithCenter[]):
            GenerateBorders(XRange, YRange)
            Tiles := GenerateTiles(XRange, YRange)
            Ticker := ticker{Monitorables := Tiles}
            Board := board{XRange := XRange, YRange := YRange}
            spawn{Ticker.Monitor()}
            spawn{Update(Board, Tiles)}