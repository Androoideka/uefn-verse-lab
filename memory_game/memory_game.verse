using { GUIExtensions }
using { TileExtensions }
using { TimerExtensions }
using { XPExtensions }
using { GameExtensions }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/FortPlayerUtilities }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
memory_game := class(creative_device):

    @editable
    NumberOfCopies:int = 2

    @editable
    NumberOfRows:int = 4

    @editable
    NumberPerRow:int = 5

    @editable
    CountdownTime:float = 120.0

    @editable
    IncrementTime:float = 60.0

    @editable
    Streak:int = 5

    @editable
    FlipDelay:float = 0.8

    @editable
    PlayerSpawners:[]player_spawner_device = array{}

    @editable
    PairAccolade:accolades_device = accolades_device{}

    @editable
    RoundAccolade:accolades_device = accolades_device{}

    @editable
    StreakAccolade:accolades_device = accolades_device{}

    @editable
    TimeAccolade:accolades_device = accolades_device{}

    OnPlayerSpawn(Agent:agent):void =
        if (Player := player[Agent], PlayerUI := GetPlayerUI[Player]):
            spawn{StartGame(Player, PlayerUI)}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for (PlayerSpawner : PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawn)

    GrantXP(Player:player, Achievement:achievement):void =
        case(Achievement):
            achievement.Pair => PairAccolade.Award(Player)
            achievement.Round => RoundAccolade.Award(Player)
            achievement.Streak => StreakAccolade.Award(Player)
            achievement.Time => TimeAccolade.Award(Player)

    StartGame(Player:player, PlayerUI:player_ui)<suspends>:void =
        Exit := button_loud{DefaultText := ToUIMessage("Exit Game")}
        Timer := countdown_timer{RemainingTime := CountdownTime}
        Tiles := CreateTiles(NumberOfRows, NumberPerRow)
        UI := CreateUI(Exit, Timer.GetSlots() + array{Tiles.CreateOverlays().ArrangeGrid().StretchToScreenSize()})
        PlayerUI.AddWidget(UI, player_ui_slot{InputMode := ui_input_mode.All})
        Closure := xp_closure:
            Func := GrantXP
            Player := Player
            Achievement := achievement.Pair
        var Counter:int = 0
        race:
            block:
                loop:
                    RunRound(Closure, Tiles, NumberOfCopies, FlipDelay)
                    Timer.AddRemainingTime(IncrementTime)
                    set Counter += 1
                    GrantXP(Player, achievement.Round)
                    if (Floor(Counter / Streak) > Floor((Counter - 1) / Streak), Counter > 1):
                        GrantXP(Player, achievement.Streak)
            Exit.OnClick().Await()
            Timer.RunCountdown()
        GrantXP(Player, achievement.Time)
        Sleep(FlipDelay)
        Player.SendToLobby()