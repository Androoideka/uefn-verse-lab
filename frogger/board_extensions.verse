using { CollectionExtensions }
using { TimerExtensions }
using { MovementExtensions }
using { SimulationExtensions }
using { ProgressExtensions }
using { PlayerExtensions }
using { /Verse.org/Simulation }
using { /Verse.org/Random }

BoardExtensions<public> := module:
    board := [][]space

    state<public> := class(tasker):
        Board<public>:board
        ProgressReporter<public>:progress_reporter
        Timer<public>:countdown_timer = countdown_timer{RemainingTime := 900.0}

        PlacementRequest<public>:event(respawnable_prop_figure) = event(respawnable_prop_figure){}
        MoveRequest<public>:event(tuple(respawnable_prop_figure, direction)) = event(tuple(respawnable_prop_figure, direction)){}
        RemovalRequest<public>:event(player) = event(player){}
        MoveComplete<public>:event(respawnable_prop_figure) = event(respawnable_prop_figure){}

        Reset<private>(Piece:respawnable_prop_figure, Slots:[respawnable_prop_figure]?space)<decides><transacts>:[respawnable_prop_figure]?space =
            var NewSlots:[respawnable_prop_figure]?space = Slots
            set NewSlots[Piece] = false
            NewSlots

        Spawn<private>(Piece:respawnable_prop_figure, Slots:[respawnable_prop_figure]?space)<decides><transacts>:[respawnable_prop_figure]?space =
            var NewSlots:[respawnable_prop_figure]?space = Reset[Piece, Slots]
            OccupiedPositions := for (MaybeSpace : Slots, Space := MaybeSpace?, Space.Position(0) = 0):
                Space
            AvailablePositions := for:
                Index -> Space : Board[0]
                not Contains(OccupiedPositions, Space)?
            do:
                Space
            SpawnSpace := Shuffle(AvailablePositions)[0]
            set NewSlots[Piece] = option{SpawnSpace}
            NewSlots

        Move<private>(Piece:respawnable_prop_figure, Direction:direction, Slots:[respawnable_prop_figure]?space, Props:[space]dimensional)<decides><transacts>:[respawnable_prop_figure]?space =
            Space := Slots[Piece]?
            NewPosition := Zip(Space.Position, Direction.GetDirectionIndex(), Add)
            NewSpace := Board[NewPosition[0]][NewPosition[1]]
            OverlapWithOccupiedSpaces := for (MaybeSpace : Slots, AnySpace := MaybeSpace?, AnySpace = NewSpace):
                false
            OverlapWithOccupiedSpaces.Length = 0
            not Props[NewSpace]
            var NewSlots:[respawnable_prop_figure]?space = Slots
            set NewSlots[Piece] = option{NewSpace}
            NewSlots

        HasPieceFinished<private>(Piece:respawnable_prop_figure, Slots:[respawnable_prop_figure]?space)<decides><computes>:void =
            Space := Slots[Piece]?
            Space.Position(0) = Board.Length - 1

        Leave<private>(Player:player, Slots:[respawnable_prop_figure]?space)<transacts>:[respawnable_prop_figure]?space =
            var NewSlots:[respawnable_prop_figure]?space = Slots
            for (Key -> Value : NewSlots, Key.Player <> Player):
                set NewSlots = ConcatenateMaps(NewSlots, map{Key => Value})
            NewSlots

        RunGameFlow()<suspends>:void =
            var Slots:[respawnable_prop_figure]?space = map{}
            var Props:[space]dimensional = map{}
            loop:
                MaybeNewSlots:?[respawnable_prop_figure]?space := race:
                    block:
                        NewPiece := PlacementRequest.Await()
                        if:
                            SlotsWithPlacement := Spawn[NewPiece, Slots]
                            Space := SlotsWithPlacement[NewPiece]?
                            NewPiece.Spawn[Space.GetSurface()]
                        then:
                            ProgressReporter.RegisterDeath(NewPiece.Player)
                            NewPiece.Show()
                            option{SlotsWithPlacement}
                        else:
                            false
                    block:
                        Result := MoveRequest.Await()
                        Piece := Result(0)
                        Direction := Result(1)
                        if (SlotsWithMove := Move[Piece, Direction, Slots, Props], Space := SlotsWithMove[Piece]?):
                            spawn{Piece.Move(Space.GetSurface())}
                            ProgressReporter.RegisterJump(Piece.Player)
                            option{SlotsWithMove}
                        else:
                            false
                    block:
                        Player := RemovalRequest.Await()
                        option{Leave(Player, Slots)}
                    block:
                        Piece := MoveComplete.Await()
                        if:
                            HasPieceFinished[Piece, Slots]
                            SlotsWithPlacement := Spawn[Piece, Slots]
                            Space := SlotsWithPlacement[Piece]?
                            Prop := Piece.Spawn[Space.GetSurface()]
                            OldSpace := Slots[Piece]?
                            set Props[OldSpace] = Prop
                        then:
                            ProgressReporter.RegisterFinish(Piece.Player)
                            option{SlotsWithPlacement}
                        else:
                            false
                if (NewSlots := MaybeNewSlots?):
                    set Slots = NewSlots
                if (Props.Length = Board[0].Length):
                    for (Prop : Props):
                        Prop.Object.Dispose()
                    set Props = map{}

        Run<override>()<suspends>:void =
            race:
                RunGameFlow()
                Timer.Run()
            ProgressReporter.Complete()