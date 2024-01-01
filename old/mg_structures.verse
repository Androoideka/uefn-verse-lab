using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { ConcurrencyExtensions }
using { GUIExtensions }

ConcurrencyExtensions<public> := module:
    async_closure<public>(t : type) := class:
        Execute<public>:type{_()<suspends>:t}

    (Closures:[]async_closure(t) where t:type).DynamicRace<public>()<suspends>:?t =
        if (Closure := Closures[0]):
            WinningResult := RecursiveRace(Closure, Closures, 0)
            option{WinningResult}
        else:
            false

    RecursiveRace(Closure:async_closure(t), Closures:[]async_closure(t), Index:int where t:type)<suspends>:t =
        if (NextClosure := Closures[Index + 1]):
            race:
                Closure.Execute()
                RecursiveRace(NextClosure, Closures, Index + 1)
        else:
            Closure.Execute()

rectangular_array(t:type) := class:
    UnderlyingArray:[]t
    Rows:int
    Columns:int

    ToMatrix()<computes>:[][]t =
        for (Row := 0..Rows - 1):
            for (Column := 0..Columns - 1, Element := GetElement[Row, Column]):
                Element

    ToArray()<computes>:[]t =
        UnderlyingArray
    
    GetElement(Row:int, Column:int)<computes><decides>:t =
        UnderlyingArray[Column + Row * Columns]

game_configuration := class:
    TileValues:rectangular_array(int)
    NumberOfCopies:int

CreateConfig<constructor>(Rows:int, Columns:int, Copies:int)<transacts><decides> :=
    game_configuration:
        TileValues := rectangular_array(int):
            Rows := Rows
            Columns := Columns
            UnderlyingArray := Shuffle(for (Counter := 1..Rows*Columns):
                Floor((Counter - 1) / Copies)
            )
        NumberOfCopies := Copies

(Config:game_configuration).CreateTilesFromConfig<constructor>()<transacts> :=
    rectangular_array(tile):
        Rows := Config.TileValues.Rows
        Columns := Config.TileValues.Columns
        UnderlyingArray := for (Row := 0..Config.TileValues.Rows - 1, Column := 0..Config.TileValues.Columns - 1, Value := Config.TileValues.GetElement[Row, Column]):
            tile:
                Button := button_regular{}
                Value := Value

tile := class:
    Button:button_regular
    Value:int

    OpenTile()<suspends>:tile =
        Button.OnClick().Await()
        Self

CreateGUIFromTile(Tile:tile):widget =
    (text_block{DefaultText := ToUIMessage(Tile.Value)}, Tile.Button).Stack()

GetTileAsyncClosure(Tile:tile)<transacts>:async_closure(tile) =
    async_closure(tile):
        Execute := Tile.OpenTile

GetTileValue(Tile:tile)<computes>:int =
    Tile.Value

GetTileButtonVisibility(Tile:tile):widget_visibility =
    Tile.Button.GetVisibility()