using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

raycasting_pool := class:
    Items:[]tuple(prop_mover_device, creative_prop)

    var IsAvailable<private>:[]logic = array{}
    Available<private>:event() = event(){}

    block:
        set IsAvailable = for (Item : Items):
            true

    Take()<suspends>:tuple(int, tuple(prop_mover_device, creative_prop)) =
        for (Index -> Item : Items, IsAvailable[Index]?, set IsAvailable[Index] = false):
            return (Index, Item)
        Available.Await()
        return Take()

    Return(BorrowedIndex:int)<suspends>:void =
        if (set IsAvailable[BorrowedIndex] = true):
            Available.Signal()

position_saver := interface:
    DeterminePosition(Character:fort_character)<suspends>:vector3

freezer := class(position_saver):
    DeterminePosition<override>(Character:fort_character)<suspends>:vector3 =
        Character.GetTransform().Translation

raycaster := class(position_saver):
    Pool:raycasting_pool

    DeterminePosition<override>(Character:fort_character)<suspends>:vector3 =
        Location := Character.GetViewLocation()
        Rotation := Character.GetViewRotation()
        Tuple := Pool.Take()
        Index := Tuple(0)
        PropMover := Tuple(1)(0)
        Prop := Tuple(1)(1)
        defer:
            branch:
                PropMover.Disable()
                Pool.Return(Index)
        if (PropMover.TeleportTo[Location, Rotation], Prop.TeleportTo[Location, IdentityRotation()]):
            PropMover.Reset()
            PropMover.Enable()
            PropMover.PropHitEvent.Await()
            Position := Prop.GetTransform().Translation
            vector3{X := Position.X, Y := Position.Y, Z := Position.Z + 50.0}
        else:
            Character.GetViewLocation()

teleporter := class:
    PositionSet<private>:event(vector3) = event(vector3){}
    TeleportTriggered<private>:event() = event(){}
    PositionSaver:position_saver
    Player:player

    Flow<private>(HearthPosition:vector3)<suspends>:void =
        Result:?vector3 := race:
            block:
                Position := PositionSet.Await()
                option{Position}
            block:
                TeleportTriggered.Await()
                false
        if (Position := Result?):
            Flow(Position)
        else if:
            Character := Player.GetFortCharacter[]
            Character.TeleportTo[HearthPosition, Character.GetViewRotation()]
        then:
            Flow(HearthPosition)

    Start()<suspends>:void =
        Position := PositionSet.Await()
        Flow(Position)
    
    OnPrimarySignal()<suspends>:void =
        if (Character := Player.GetFortCharacter[]):
            Position := PositionSaver.DeterminePosition(Character)
            PositionSet.Signal(Position)

    OnSecondarySignal():void =
        TeleportTriggered.Signal()

# A Verse-authored creative device that can be placed in a level
hearth := class(creative_device):

    @editable
    PlayerSpawners:[]player_spawner_device = array{}

    @editable
    SignalGranter:item_granter_device = item_granter_device{}

    @editable
    SignalReceiver:signal_remote_manager_device = signal_remote_manager_device{}

    @editable
    Props:[]creative_prop = array{}

    @editable
    PropMovers:[]prop_mover_device = array{}

    var Pool:raycasting_pool = raycasting_pool{Items := array{}}

    block:
        Pairs := for (Index -> PropMover : PropMovers, Prop := Props[Index]):
            (PropMover, Prop)
        set Pool = raycasting_pool{Items := Pairs}

    var TeleporterPerPlayer : [player]?teleporter = map{}

    OnPrimarySignal(Agent:agent):void =
        if (Player := player[Agent], Teleporter := TeleporterPerPlayer[Player]?):
            spawn{Teleporter.OnPrimarySignal()}

    OnSecondarySignal(Agent:agent):void =
        if (Player := player[Agent], Teleporter := TeleporterPerPlayer[Player]?):
            Teleporter.OnSecondarySignal()

    OnPlayerSpawn(NewAgent:agent):void =
        if:
            NewPlayer := player[NewAgent]
            Teleporter := teleporter{Player := NewPlayer, PositionSaver := raycaster{Pool := Pool}}
            set TeleporterPerPlayer[NewPlayer] = option{Teleporter}
        then:
            SignalGranter.GrantItem(NewPlayer)
            spawn{Teleporter.Start()}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for (PropMover : PropMovers):
            PropMover.Disable()
        SignalReceiver.PrimarySignalEvent.Subscribe(OnPrimarySignal)
        SignalReceiver.SecondarySignalEvent.Subscribe(OnSecondarySignal)
        for (PlayerSpawner : PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawn)