using { GUIExtensions }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }

TileExtensions<public> := module:
    tile<public> := class:
        Button<public>:button_regular = button_regular{}
        Block<public>:color_block = color_block{DefaultColor := NamedColors.White, DefaultOpacity := 1.0}
        Text<public>:text_block = text_block{}

        SetValue<public>(Value:int):void =
            Text.SetText(ToUIMessage(Value))

        Reveal<public>():void =
            Button.SetVisibility(widget_visibility.Hidden)
            Block.SetVisibility(widget_visibility.Hidden)

        Close<public>():void =
            Button.SetVisibility(widget_visibility.Visible)
            Block.SetVisibility(widget_visibility.Visible)

        IsRevealed<public>():logic =
            Visibility := Button.GetVisibility()
            logic{Visibility = widget_visibility.Visible}

    CreateTiles<public>(Rows:int, Columns:int)<transacts>:[][]tile =
        for (RowIndex := 1..Rows):
            for (ColumnIndex := 1..Columns):
                tile{}

    (Tiles:[][]tile).CreateOverlays<public>()<transacts>:[][]overlay =
        for (Array : Tiles):
            for (Tile : Array):
                overlay:
                    Slots := array:
                        overlay_slot{Widget := Tile.Text}
                        overlay_slot{Widget := Tile.Block}
                        overlay_slot{Widget := Tile.Button}