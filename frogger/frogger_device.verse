using { MovementExtensions }
using { SimulationExtensions }
using { FroggerStructures }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
frogger_device := class(creative_device):

    @editable
    Marker:creative_prop = creative_prop{}

    @editable
    PlayerSpawners:[]player_spawner_device = array{}

    @editable
    StreetAsset:creative_prop_asset = DefaultCreativePropAsset

    @editable
    FrogAsset:creative_prop_asset = DefaultCreativePropAsset

    @editable
    SignalReceiver:signal_remote_manager_device = signal_remote_manager_device{}

    @editable
    MoveButtons:[]button_device = array{}

    @editable
    Camera:gameplay_camera_fixed_point_device  = gameplay_camera_fixed_point_device {}

    Offsets:vector3 = vector3{X := -500.0, Y := 500.0, Z := 16.0}

    Ticker:ticker = ticker{}

    var Board:frogger_board = frogger_board{}

    var ControllerPerPlayer : [player]?controller = map{}

    OnPrimarySignal(Agent:agent):void =
        if:
            Player := player[Agent]
            Controller := ControllerPerPlayer[Player]?
        then:
            Controller.KeyPressed.Signal(direction.Left)

    OnSecondarySignal(Agent:agent):void =
        if:
            Player := player[Agent]
            Controller := ControllerPerPlayer[Player]?
        then:
            Controller.KeyPressed.Signal(direction.Right)

    OnInteract(Agent:agent):void =
        if:
            Player := player[Agent]
            Controller := ControllerPerPlayer[Player]?
        then:
            Controller.KeyPressed.Signal(direction.Up)

    OnCrouch(Payload:tuple(fort_character, logic)):void =
        if:
            Player := player[Payload(0).GetAgent[]]
            Controller := ControllerPerPlayer[Player]?
        then:
            Controller.KeyPressed.Signal(direction.Down)

    OnPlayerSpawn(Agent:agent):void =
        if:
            Player := player[Agent]
            Character := Player.GetFortCharacter[]
            Controller := controller{Board := Board, Asset := FrogAsset, Player := Player}
            set ControllerPerPlayer[Player] = option{Controller}
        then:
            Ticker.AddMonitorable(Controller)
            Character.CrouchedEvent().Subscribe(OnCrouch)
            spawn{Controller.Start()}

    CreateTiles()<transacts>:[][]frogger_tile =
        MarkerTranslation := Marker.GetTransform().Translation
        for (X := 0..15):
            for:
                Y := 0..8
                Translation := MarkerTranslation + Offsets * vector3{X := Y * -2.05, Y := X * 2.05, Z := 8.0}
                Rotation := IdentityRotation().ApplyLocalRotationZ(DegreesToRadians(90.0))
                Result := SpawnProp(StreetAsset, Translation, Rotation)
                Prop := Result(0)?
            do:
                frogger_tile:
                    IsStart := logic{Y = 0}
                    IsEnd := logic{Y = 8}
                    Offsets := Offsets
                    Prop := Prop

    RepositionCamera():void =
        XCenter := 9 * Offsets.Y - 1000.0
        YCenter := 16 * Offsets.Y
        Size := 16 * Offsets.Y * 2.05
        FieldOfView := 120.0
        ViewDistance := Size / (2 * Tan(DegreesToRadians(FieldOfView / 2.0)))
        Translation := Marker.GetTransform().Translation + vector3{X := XCenter, Y := YCenter, Z := ViewDistance}
        Print("{Translation.X}, {Translation.Y}, {Translation.Z}")
        if (Camera.TeleportTo[Translation, Camera.GetTransform().Rotation]) {}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void =
        spawn{Ticker.Start()}
        set Board = frogger_board{Tiles := CreateTiles()}
        RepositionCamera()
        for (MoveButton : MoveButtons):
            MoveButton.InteractedWithEvent.Subscribe(OnInteract)
        SignalReceiver.PrimarySignalEvent.Subscribe(OnPrimarySignal)
        SignalReceiver.SecondarySignalEvent.Subscribe(OnSecondarySignal)
        for (PlayerSpawner : PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawn)