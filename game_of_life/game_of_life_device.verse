using { CollectionExtensions }
using { SpaceExtensions }
using { GoL }
using { /Verse.org/Assets }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

monitorable := interface:
    Update():void

ticker := class:
    Monitorables:[]monitorable

    Monitor()<suspends>:void =
        loop:
            Sleep(0.0)
            for (Monitorable : Monitorables):
                Monitorable.Update()

tile := class(monitorable):
    Cell:tuple(int, int)

    Model:creative_prop
    Asset:creative_prop_asset

    RegisterHit:type{_(:tuple(int, int))<transacts>:void}

    var Prop<private>:creative_prop = creative_prop{}

    Spawn<private>():void =
        Result := SpawnProp(Asset, Model.GetTransform().Translation + FromXYZ(0.0, 0.0, 50.1), IdentityRotation())
        if (set Prop = Result(0)?) {}

    Instantiate():void =
        SetDead()
        Spawn()

    Update<override>():void =
        if (not Prop.IsValid[]):
            RegisterHit(Cell)
            SetLiving()
            Spawn()

    SetLiving():void =
        Model.SetMaterial(LivingCell)

    SetDead():void =
        Model.SetMaterial(DeadCell)

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
    Button:button_device = button_device{}

    Reset:event() = event(){}

    var Hits:[]tuple(int, int) = array{}

    OnPress(Agent:agent):void =
        Reset.Signal()

    RegisterHit(Cell:tuple(int, int))<transacts>:void =
        if (not Contains(Hits, Cell)?):
            set Hits = Hits + array{Cell}

    Update(Board:board, Tiles:[]tile)<suspends>:void =
        NewBoard := race:
            block:
                Sleep(IterationDelay)
                Board.Update(Hits)
            block:
                Reset.Await()
                board{XRange := Board.XRange, YRange := Board.YRange}
        set Hits = array{}
        for (Tile : Tiles):
            if (Contains(NewBoard.LivingCells, Tile.Cell)?):
                Tile.SetLiving()
            else:
                Tile.SetDead()
        Update(NewBoard, Tiles)

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
        for (BorderTransform : BorderTransforms):
            Result := SpawnProp(BorderAsset, BorderTransform)
            if (not Result(0)?):
                Print("Fuck")

    OnBegin<override>()<suspends>:void =
        if (XRange := XSize.GetRangeWithCenter[], YRange := YSize.GetRangeWithCenter[]):
            Button.InteractedWithEvent.Subscribe(OnPress)
            GenerateBorders(XRange, YRange)
            Tiles := GenerateTiles(XRange, YRange)
            Ticker := ticker{Monitorables := Tiles}
            Board := board{XRange := XRange, YRange := YRange}
            spawn{Ticker.Monitor()}
            spawn{Update(Board, Tiles)}