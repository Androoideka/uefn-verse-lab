using { CollectionExtensions }
using { PlayerExtensions }
using { MovementExtensions }

FroggerExtensions<public> := module:
    GetFroggerSpawn<public>(Frog:respawnable_prop_figure, Board:[][]space, Slots:[respawnable_prop_figure]?space)<decides><transacts>:space =
        AvailablePositions := for:
            Index -> Space : Board[0]
            not Slots[Space]?
        do:
            Space
        AvailablePositions[0]

    FroggerMove<public>(Frog:respawnable_prop_figure, NewSpace:space, Slots:[respawnable_prop_figure]?space)<decides><transacts>:[respawnable_prop_figure]?space =
        Space := Slots[Frog]?
        Offset := Zip(Space.Position, NewSpace.Position, Subtract)
        Abs(Offset[0]) + Abs(Offset[1]) = 1
        var NewSlots:[respawnable_prop_figure]?space = Slots
        set NewSlots[Frog] = option{NewSpace}
        NewSlots

    GetFroggerFinishedPlayers<public>(Board:[][]space, Slots:[respawnable_prop_figure]?space)<computes>:[]respawnable_prop_figure =
        InCompletionArea := for (Key -> Value : Slots, Space := Value?, Space.Position(0) = Board.Length - 1):
            Key