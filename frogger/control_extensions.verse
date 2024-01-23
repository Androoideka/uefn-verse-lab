using { /Verse.org/Simulation }
using { MovementExtensions }
using { PlayerExtensions }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }

ControlExtensions<public> := module:
    controller<public> := class<abstract>:
        var Selected:[player]figure = map{}

        Join<public>(Figure:figure):void

        Select(Player:player, Figure:figure)<decides><transacts>:void =
            set Selected[Figure.Player] = Figure

        Move(Player:player, Direction:direction):void =
            if (Figure := Selected[Player]):
                Figure.RequestMove(Direction)

    key_controller<public> := class(controller):
        Buttons<public>:[]button_device
        SignalReceiver<public>:signal_remote_manager_device

        block:
            for (Button : Buttons):
                Button.InteractedWithEvent.Subscribe(OnInteract)
            SignalReceiver.PrimarySignalEvent.Subscribe(OnLeftSignal)
            SignalReceiver.SecondarySignalEvent.Subscribe(OnRightSignal)

        Join<override>(Figure:figure):void =
            if:
                Select[Figure.Player, Figure]
                Character := Figure.Player.GetFortCharacter[]
            then:
                Character.CrouchedEvent().Subscribe(OnCrouch)

        OnInteract(Agent:agent):void =
            if (Player := player[Agent]):
                Move(Player, direction.Up)

        OnLeftSignal(Agent:agent):void =
            if (Player := player[Agent]):
                Move(Player, direction.Left)

        OnRightSignal(Agent:agent):void =
            if (Player := player[Agent]):
                Move(Player, direction.Right)

        OnCrouch(Payload:tuple(fort_character, logic)):void =
            if (Player := player[Payload(0).GetAgent[]]):
                Move(Player, direction.Down)