using { CollectionExtensions }
using { TileExtensions }
using { XPExtensions }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/UI }

GameExtensions<public> := module:
    card := class:
        Tile:tile
        Value:int
        Event:event(card)

        OpenCard(Message:widget_message):void =
            Event.Signal(Self)

    CreateCards(Tiles:[]tile, Values:[]int, Event:event(card))<transacts>:[]card =
        for (Index -> Tile : Tiles, Value := Values[Index]):
            card:
                Tile := Tile
                Value := Value
                Event := Event

    SetUpUI(Cards:[]card):[]cancelable =
        for (Card : Cards):
            Card.Tile.SetValue(Card.Value)
            Card.Tile.Close()
            Card.Tile.Button.OnClick().Subscribe(Card.OpenCard)

    CancelListeners(Listeners:[]cancelable)<transacts>:void =
        for (Listener : Listeners):
            Listener.Cancel()

    ExecuteRound(Event:event(card), LogRound:xp_closure, Cards:[]card, Copies:int, FlipDelay:float)<suspends>:void =
        loop:
            OpenedCards := for (OpenIndex := 1..Copies):
                Card := Event.Await()
                Card.Tile.Reveal()
                Card
            OpenedValues := for (Card : OpenedCards) { Card.Value }
            if(OpenedValues.IsAllEqual[]):
                LogRound.Grant()
                Visibility := for (Card : Cards) { Card.Tile.IsRevealed() }
                if (Visibility.IsAllEqual[]):
                    break
            else:
                Sleep(FlipDelay)
                for (Card : OpenedCards):
                    Card.Tile.Close()

    RunRound<public>(LogRound:xp_closure, Tiles:[][]tile, Copies:int, FlipDelay:float)<suspends>:void =
        Event := event(card){}
        FlattenedTiles := for (Array : Tiles, Tile : Array) { Tile }
        Values := CreateRandomValues(FlattenedTiles.Length, Copies)
        Cards := CreateCards(FlattenedTiles, Values, Event)
        Listeners := SetUpUI(Cards)
        ExecuteRound(Event, LogRound, Cards, Copies, FlipDelay)
        CancelListeners(Listeners)