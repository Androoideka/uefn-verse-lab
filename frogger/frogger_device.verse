using { /Verse.org/Simulation }
using { MovementExtensions }
using { SimulationExtensions }
using { ControlExtensions }
using { BoardExtensions }
using { PlayerExtensions }
using { ObstacleExtensions }
using { FroggerInitialization }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
frogger_device := class(creative_device):
    AspectRatio:tuple(int, int) = (16, 9)

    @editable
    PlayerSpawners:[]player_spawner_device = array{}

    @editable
    Lanes:int = 16

    @editable
    StreetPropAsset:creative_prop_asset = DefaultCreativePropAsset

    @editable
    StreetOffset:vector3 = vector3{X := -1.0, Y := 1.0, Z := -1.0}

    @editable
    StreetSize:vector3 = vector3{X := 1024.0, Y := 1024.0, Z := 128.0}

    @editable
    FrogPropAsset:creative_prop_asset = DefaultCreativePropAsset

    @editable
    Camera:gameplay_camera_fixed_point_device = gameplay_camera_fixed_point_device {}

    @editable
    SignalReceiver:signal_remote_manager_device = signal_remote_manager_device{}

    @editable
    MoveButtons:[]button_device = array{}

    @editable
    Phases:[]int = array{}

    @editable
    CarOffset:vector3 = vector3{X := 0.0, Y := 0.0, Z := 1.1}

    @editable
    CarSize:vector3 = vector3{X := 128.0, Y := 512.0, Z := 128.0}
    
    @editable
    Cars:[]creative_prop = array{}

    @editable
    CarMovers:[]prop_mover_device = array{}

    @editable
    Marker:creative_prop = creative_prop{}

    Ticker:ticker = ticker{}

    var MaybeState:?state = false

    var MaybeController:?key_controller = false

    GetDimensional(Car:creative_prop):dimensional =
        dimensional:
            Offset := CarOffset
            Size := CarSize
            Facing := axis.PY
            Object := Car

    RepositionCamera():void =
        XCenter := 9 * StreetOffset.Y - 1000.0
        YCenter := 16 * StreetOffset.Y
        Size := 16 * StreetOffset.Y * 2.05
        FieldOfView := 120.0
        ViewDistance := Size / (2 * Tan(DegreesToRadians(FieldOfView / 2.0)))
        Translation := Marker.GetTransform().Translation + vector3{X := XCenter, Y := YCenter, Z := ViewDistance}
        Print("{Translation.X}, {Translation.Y}, {Translation.Z}")
        if (Camera.TeleportTo[Translation, Camera.GetTransform().Rotation]) {}

    OnPlayerSpawn(Agent:agent):void =
        if (Player := player[Agent], Controller := MaybeController?, State := MaybeState?):
            Frog := CreateFrog(FrogPropAsset, Player, State)
            Controller.Join(Frog)
            Ticker.AddMonitorable(Frog)

    OnBegin<override>()<suspends>:void =
        StreetAsset := asset:
            Offset := StreetOffset
            Size := StreetSize
            Facing := axis.PY
            PropAsset := StreetPropAsset
        State := CreateFroggerState(Marker.GetTransform().Translation, Lanes, StreetAsset)
        set MaybeState = option{State}
        Controller := key_controller{Buttons := MoveButtons, SignalReceiver := SignalReceiver}
        set MaybeController = option{Controller}
        CarDimensionals := for (Car : Cars):
            GetDimensional(Car)
        Obstacles := CreateObstacles(State.Board, CarMovers, CarDimensionals, Phases)
        spawn{Ticker.Run()}
        spawn{State.Run()}
        for (Obstacle : Obstacles):
            spawn{Obstacle.Run()}
        RepositionCamera()
        for (PlayerSpawner : PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawn)