using { MathExtensions }
using { CollectionExtensions }

GoL<public> := module:
    point<public> := tuple(int, int)

    (Point:point).GetNeighboursClassic()<computes>:[]point =
        array:
            AddTuple(Point, (-1, -1))
            AddTuple(Point, (0, -1))
            AddTuple(Point, (1, -1))
            AddTuple(Point, (-1, 0))
            AddTuple(Point, (1, 0))
            AddTuple(Point, (-1, 1))
            AddTuple(Point, (0, 1))
            AddTuple(Point, (1, 1))

    LeavesBounds(Coordinate:int, Range:point)<decides><computes>:void =
        Coordinate >= Range(0) and Coordinate <= Range(1)

    LeavesBounds(Point:point, XRange:point, YRange:point)<decides><computes>:void =
        LeavesBounds[Point(0), XRange] and LeavesBounds[Point(1), YRange]

    GetNeighboursBounded(Point:point, XRange:point, YRange:point)<computes>:[]point =
        Neighbours := Point.GetNeighboursClassic()
        for (Neighbour : Neighbours, LeavesBounds[Neighbour, XRange, YRange]):
            Neighbour

    WrapToBounds(Coordinate:int, Range:point)<decides><computes>:int =
        Size := Range(1) - Range(0)
        Mod[Coordinate, Size] + Range(0)

    WrapToBounds(Point:point, XRange:point, YRange:point)<decides><computes>:tuple(int, int) =
        (WrapToBounds[Point(0), XRange], WrapToBounds[Point(1), YRange])

    GetNeighboursWrapped(Point:point, XRange:point, YRange:point)<computes>:[]point =
        Neighbours := Point.GetNeighboursClassic()
        for (Neighbour : Neighbours, WrappedNeighbour := WrapToBounds[Neighbour, XRange, YRange]):
            WrappedNeighbour

    ShouldStayAliveClassic(LivingCells:[]point, Cell:point, Occurrences:int)<decides><computes>:void =
        Occurrences = 3 or (Occurrences = 2 and Contains(LivingCells, Cell)?)

    board<public> := class:
        XRange<public>:point
        YRange<public>:point

        GetNeighbours:type{_(:tuple(point, point, point))<computes>:[]point} = GetNeighboursBounded
        ShouldStayAlive:type{_(:[]point, :point, :int)<decides><computes>:void} = ShouldStayAliveClassic

        LivingCells<public>:[]point = array{}

        Update<public>(AddedCells:[]point)<transacts>:board =
            Cells := AddedCells + for (Cell : LivingCells, not Contains(AddedCells, Cell)?):
                Cell
            Neighbours := for:
                Cell : Cells
                CellNeighbours := GetNeighbours(Cell, XRange, YRange)
                Neighbour : CellNeighbours
            do:
                Neighbour
            Hashes := for (Neighbour : Neighbours):
                Szudzik(Neighbour)
            HashMap := CreateHashMap(Neighbours, Szudzik)
            FrequencyMap := Hashes.CreateFrequencyMap()
            NewLivingCells := GetFromMaps(Cells, FrequencyMap, HashMap)
            board{LivingCells := NewLivingCells, XRange := XRange, YRange := YRange}

        GetFromMaps(Cells:[]point, FrequencyMap:[int]int, HashMap:[int]point)<computes>:[]point =
            for:
                Hash->Occurrences : FrequencyMap
                Cell := HashMap[Hash]
                ShouldStayAlive[Cells, Cell, Occurrences]
            do:
                Cell