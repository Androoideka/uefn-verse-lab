using { CollectionExtensions }
using { MovementExtensions }
using { SimulationExtensions }
using { PlayerExtensions }
using { /Verse.org/Simulation }

BoardExtensions<public> := module:
    board := [][]space

    state<public> := class(tasker):
        Board<public>:board

        GetSpawn<public>:type{_(:respawnable_prop_figure, :board, :[respawnable_prop_figure]?space)<decides><transacts>:space}
        UpdateForMove<public>:type{_(:respawnable_prop_figure, :space, :[respawnable_prop_figure]?space)<decides><transacts>:[respawnable_prop_figure]?space}
        IsComplete<public>:type{_(:board, :[respawnable_prop_figure]?space)<decides><transacts>:void}

        PlacementRequest<public>:event(respawnable_prop_figure) = event(respawnable_prop_figure){}
        DisplacementRequest<public>:event(respawnable_prop_figure) = event(respawnable_prop_figure){}
        MoveRequest<public>:event(tuple(respawnable_prop_figure, int, int)) = event(tuple(respawnable_prop_figure, int, int)){}
        RemovalRequest<public>:event(player) = event(player){}

        Reset<private>(Piece:respawnable_prop_figure, Slots:[respawnable_prop_figure]?space)<decides><transacts>:[respawnable_prop_figure]?space =
            var NewSlots:[respawnable_prop_figure]?space = Slots
            set NewSlots[Piece] = false
            NewSlots

        Spawn<private>(Piece:respawnable_prop_figure, Slots:[respawnable_prop_figure]?space)<decides><transacts>:[respawnable_prop_figure]?space =
            var NewSlots:[respawnable_prop_figure]?space = Reset[Piece, Slots]
            Space := GetSpawn[Piece, Board, Slots]
            Piece.Spawn[Space.GetSurface()]
            set NewSlots[Piece] = option{Space}
            NewSlots

        Move<private>(Piece:respawnable_prop_figure, Offset:tuple(int, int), Slots:[respawnable_prop_figure]?space)<decides><transacts>:[respawnable_prop_figure]?space =
            Space := Slots[Piece]?
            NewPosition := Zip(Space.Position, Offset, Add)
            NewSpace := Board[NewPosition[0]][NewPosition[1]]
            var NewSlots:[respawnable_prop_figure]?space = UpdateForMove[Piece, NewSpace, Slots]
            set NewSlots[Piece] = option{NewSpace}
            NewSlots

        Leave<private>(Player:player, Slots:[respawnable_prop_figure]?space)<transacts>:[respawnable_prop_figure]?space =
            var NewSlots:[respawnable_prop_figure]?space = Slots
            for (Key -> Value : NewSlots, Key.Player <> Player):
                set NewSlots = ConcatenateMaps(NewSlots, map{Key => Value})
            NewSlots

        Run<override>()<suspends>:void =
            var Slots:[respawnable_prop_figure]?space = map{}
            loop:
                set Slots = race:
                    block:
                        NewPiece := PlacementRequest.Await()
                        if (SlotsWithPlacement := Spawn[NewPiece, Slots]):
                            SlotsWithPlacement
                        else:
                            Slots
                    block:
                        Piece := DisplacementRequest.Await()
                        if (SlotsWithDisplacement := Reset[Piece, Slots]):
                            SlotsWithDisplacement
                        else:
                            Slots
                    block:
                        Result := MoveRequest.Await()
                        Piece := Result(0)
                        Offset := (Result(1), Result(2))
                        if (SlotsWithMove := Move[Piece, Offset, Slots], Space :=  SlotsWithMove[Piece]?):
                            spawn{Piece.Move(Space.GetSurface())}
                            SlotsWithMove
                        else:
                            Slots
                    block:
                        Player := RemovalRequest.Await()
                        Leave(Player, Slots)
                if (IsComplete[Board, Slots]):
                    break