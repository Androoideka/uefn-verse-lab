using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Fortnite.com/Devices }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { Extensions }
using { GUIExtensions }
using { ConcurrencyExtensions }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

game_state := class:
    Tiles:[]tile
    NumberOfCopies:int
    NotifText:text_block
    FlipDelay:float

    PlayGame()<suspends> : void =
        Values := Map(Tiles, GetTileValue)
        Closures := Map(Tiles, GetTileAsyncClosure)
        loop:
            OpenedTiles := for (OpenCount := 1..NumberOfCopies):
                MaybeTile := Closures.DynamicRace()
                if (Tile := MaybeTile?):
                    Tile.Button.SetVisibility(widget_visibility.Hidden)
                    Tile
                else:
                    break
            OpenedValues := Map(OpenedTiles, GetTileValue)
            if(OpenedValues.IsAllEqual()?):
                Visibility := Map(Tiles, GetTileButtonVisibility)
                if (Visibility.IsAllEqual()?):
                    NotifText.SetText(ToUIMessage("Congratulations!"))
                    break
            else:
                Sleep(FlipDelay)
                for (Tile : OpenedTiles):
                    Tile.Button.SetVisibility(widget_visibility.Visible)

countdown_timer := class:
    RemainingTimeWidget:text_block
    NotifText:text_block
    TimerTickPeriod:float = 1.0
    var RemainingTime:float

    RunCountdown()<suspends> : void =
        UpdateUI()
        loop:
            Sleep(TimerTickPeriod)
            set RemainingTime -= TimerTickPeriod

            UpdateUI()

            if (RemainingTime <= 0.0):
                NotifText.SetText(ToUIMessage("Time is up!"))
                break
    
    UpdateUI() : void =
        if (RoundedTime := Int[RemainingTime]):
            RemainingTimeWidget.SetText(ToUIMessage(RoundedTime))

gui := class:
    PlayerUI:player_ui
    Grid:canvas

    Remove():void =
        PlayerUI.RemoveWidget(Grid)

CreateGUI<constructor>(Exit:button_loud, Timer:text_block, Widgets:[][]widget, NotifText:text_block)<transacts> :=
    canvas:
        Slots := array:
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.85, Y := 0.05}, Maximum := vector2{X := 0.95, Y := 0.1}}
                Widget := Exit
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.0}, Maximum := vector2{X := 0.5, Y := 0.0}}
                Alignment := vector2{X := 0.5, Y := 0.0}
                Widget := Timer
            MakeCanvasSlot(CreateBackground(NamedColors.Beige), vector2{X := 0.0, Y := 0.0}, ?Size := vector2{X := 1920.0, Y := 1080.0})
            MakeCanvasSlot(Widgets.ArrangeGrid(), vector2{X := 0.0, Y := 0.0}, ?Size := vector2{X := 1920.0, Y := 1080.0})
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.1}, Maximum := vector2{X := 0.5, Y := 0.1}}
                Alignment := vector2{X := 0.5, Y := 0.0}
                Widget := NotifText

# A Verse-authored creative device that can be placed in a level
memory_game := class(creative_device):

    @editable
    StartButton:button_device = button_device{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        StartButton.InteractedWithEvent.Subscribe(HandleStartButton)
    
    HandleStartButton(Agent:agent):void =
        if (InPlayer := player[Agent], PlayerUI := GetPlayerUI[InPlayer]):
            spawn{StartGame(InPlayer, PlayerUI)}

    @editable
    FlipDelay:float = 0.8

    @editable
    NumberOfCopies:int = 2

    @editable
    NumberOfRows:int = 4

    @editable
    NumberPerRow:int = 5

    @editable
    CountdownTime:float = 120.0

    StartGame(Player:player, PlayerUI:player_ui)<suspends>:void =
        if (Config := CreateConfig[NumberOfRows, NumberPerRow, NumberOfCopies]):
            Exit := button_loud{DefaultText := ToUIMessage("Exit")}
            NotifText := text_block{}
            Tiles := Config.CreateTilesFromConfig()
            Widgets := MMap(Tiles.ToMatrix(), CreateGUIFromTile)
            State := game_state{Tiles := Tiles.ToArray(), NumberOfCopies := NumberOfCopies, NotifText := NotifText, FlipDelay := FlipDelay}
            TimerText := text_block{}
            Timer := countdown_timer{RemainingTimeWidget := TimerText, NotifText := NotifText, RemainingTime := CountdownTime}
            Grid := CreateGUI(Exit, TimerText, Widgets, NotifText)
            GUI := gui{PlayerUI := PlayerUI, Grid := Grid}
            PlayerUI.AddWidget(Grid, player_ui_slot{InputMode := ui_input_mode.All})
            ExecuteGameLoop(Exit, State, Timer, GUI)

    ExecuteGameLoop(State:game_state, Timer:countdown_timer)<suspends>:void =
        race:
            State.PlayGame()
            Timer.RunCountdown()
        Sleep(10.0)

    ExecuteGameLoop(Exit:button_loud, State:game_state, Timer:countdown_timer, GUI:gui)<suspends>:void =
        race:
            Exit.OnClick().Await()
            ExecuteGameLoop(State, Timer)
        GUI.Remove()
