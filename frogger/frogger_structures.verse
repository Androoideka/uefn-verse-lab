using { MovementExtensions }
using { SimulationExtensions }
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }

FroggerStructures<public> := module:
    frogger_tile<public> := class(space):
        IsEnd<public>:logic
        IsStart<public>:logic

    frogger_board<public> := class:
        Tiles<public>:[][]frogger_tile = array{}

        Spawn<private>()<decides><transacts>:position =
            AvailableTiles := for:
                RowIndex -> TileRow : Tiles
                ColumnIndex -> Tile : TileRow
                Tile.IsStart?
                not Tile.IsOccupied?
            do:
                (Tile, RowIndex, ColumnIndex)
            SpawnData := AvailableTiles[0]
            SpawnTile := SpawnData(0)
            set SpawnTile.IsOccupied = true
            NewIndex := (SpawnData(1), SpawnData(2))
            NewTranslation := SpawnTile.GetTranslation()
            position{Index := NewIndex, Translation := NewTranslation}

        Respawn<public>(Index:tuple(int, int))<decides><transacts>:position =
            Tile := Tiles[Index(0)][Index(1)]
            set Tile.IsOccupied = false
            Spawn[]

        Move<public>(Index:tuple(int, int), Direction:direction)<decides><transacts>:position =
            NewIndex := AddTuple(Index, Direction.GetDirectionIndex())
            NewTile := Tiles[NewIndex(0)][NewIndex(1)]
            OldTile := Tiles[Index(0)][Index(1)]
            not NewTile.IsOccupied?
            set NewTile.IsOccupied = true
            set OldTile.IsOccupied = false
            NewTranslation := NewTile.GetTranslation()
            position{Index := NewIndex, Translation := NewTranslation}

        HasReachedEnd<public>(Index:tuple(int, int))<decides><transacts>:void =
            Tiles[Index(0)][Index(1)].IsEnd?

    controller<public> := class(tasker, monitorable):
        Board<public>:frogger_board
        Asset<public>:creative_prop_asset
        Player<public>:player

        KeyPressed<public>:event(direction) = event(direction){}
        Finish<public>:event(player) = event(player){}

        var Prop<private>:creative_prop = creative_prop{}
        var Index<private>:tuple(int, int) = (0, 0)

        Respawn<private>()<transacts>:void =
            if:
                NewPosition := Board.Respawn[Index]
                Result := SpawnProp(Asset, NewPosition.Translation, IdentityRotation())
                set Prop = Result(0)?
            then:
                set Index = NewPosition.Index

        block:
            Respawn()

        Update<override>():void =
            if (not Prop.IsValid[]):
                Respawn()

        Start<override>()<suspends>:void =
            race:
                block:
                    loop:
                        Direction := KeyPressed.Await()
                        Move(Direction)
                block:
                    Finish.Await()

        Move(Direction:direction)<suspends>:void =
            if (Prop.IsValid[], Position := Board.Move[Index, Direction]):
                set Index = Position.Index
                Prop.MoveTo(Position.Translation, IdentityRotation(), 0.5)
                if (Prop.IsValid[] and Board.HasReachedEnd[Index]):
                    Finish.Signal(Player)