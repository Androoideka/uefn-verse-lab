using { /Verse.org/Simulation }
using { /Verse.org/Simulation/Tags }
using { CollectionExtensions }
using { MovementExtensions }
using { SimulationExtensions }
using { CameraExtensions }
using { ControlExtensions }
using { ProgressExtensions }
using { BoardExtensions }
using { PlayerExtensions }
using { ObstacleExtensions }
using { FroggerInitialization }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

playertag := class(tag){}

cartag := class(tag){}

# A Verse-authored creative device that can be placed in a level
frogger_device := class(creative_device):
    @editable
    PlayerSpawners:[]player_spawner_device = array{}

    @editable
    StreetPropAsset:creative_prop_asset = DefaultCreativePropAsset

    @editable
    StreetOffset:vector3 = vector3{X := -1.0, Y := 1.0, Z := -1.0}

    @editable
    StreetSize:vector3 = vector3{X := 1024.0, Y := 1024.0, Z := 133.0}
    
    @editable
    FrogPropAsset:creative_prop_asset = DefaultCreativePropAsset

    @editable
    FrogOffset:vector3 = vector3{X := 0.0, Y := 0.0, Z := 1.0}

    @editable
    FrogSize:vector3 = vector3{X := 118.0, Y := 119.0, Z := 47.0}

    @editable
    CarOffset:vector3 = vector3{X := 0.0, Y := 0.0, Z := 1.0}

    @editable
    CarSize:vector3 = vector3{X := 197.0, Y := 487.0, Z := 209.0}

    @editable
    Camera:gameplay_camera_fixed_point_device = gameplay_camera_fixed_point_device {}

    @editable
    SignalReceiver:signal_remote_manager_device = signal_remote_manager_device{}

    @editable
    MoveButtons:[]button_device = array{}

    @editable
    PlacementAccolades:[]accolades_device = array{}

    @editable
    ScoreAccolades:[]accolades_device = array{}

    @editable
    ScoreTracker:score_manager_device = score_manager_device{}

    @editable
    Pivot:vector3 = vector3{}

    @editable
    EndGameDevice:end_game_device = end_game_device{}

    @editable
    Lanes:int = 9

    Ticker:ticker = ticker{}

    var MaybeState:?state = false

    var MaybeController:?key_controller = false

    var Labels:[]label = array{}

    OnPlayerSpawn(Agent:agent):void =
        if:
            Player := player[Agent]
            Controller := MaybeController?
            State := MaybeState?
            Result := Labels.Pop[]
            Label := Result(1)
        then:
            set Labels = Result(0)
            FrogAsset := asset:
                Offset := FrogOffset
                Size := FrogSize
                Scale := vector3{X := 3.5, Y := 3.5, Z := 3.5}
                Facing := axis.PY
                PropAsset := FrogPropAsset
            Frog := CreateFrog(FrogAsset, Label, Player, State)
            Controller.Join(Frog)
            Ticker.AddMonitorable(Frog)

    OnBegin<override>()<suspends>:void =
        StreetAsset := asset:
            Offset := StreetOffset
            Size := StreetSize
            Facing := axis.PY
            PropAsset := StreetPropAsset
        ProgressReporter := progress_reporter:
            PlacementAccolades := PlacementAccolades
            ScoreAccolades := ScoreAccolades
            ScoreTracker := ScoreTracker
            EndGameDevice := EndGameDevice
        State := CreateFroggerState(Pivot, Lanes, StreetAsset, ProgressReporter)
        set MaybeState = option{State}
        Controller := key_controller{Buttons := MoveButtons, SignalReceiver := SignalReceiver}
        set MaybeController = option{Controller}
        if:
            CameraPosition := RepositionCamera[State.Board, Camera]
            Camera.TeleportTo[CameraPosition, Camera.GetTransform().Rotation]
        then {}
        set Labels = for (Object : GetCreativeObjectsWithTag(playertag{}), Billboard := billboard_device[Object]):
            label:
                Display := Billboard
                CameraTransform := Camera.GetTransform()
        for (Obstacle : CreateObstacles[State.Board, GetCreativeObjectsWithTag(cartag{}), CarOffset, CarSize]):
            spawn{Obstacle.Run()}
        spawn{Ticker.Run()}
        spawn{State.Run()}
        for (PlayerSpawner : PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawn)