using { MathExtensions }
using { CollectionExtensions }

SimulationExtensions<public> := module:
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

    GetNeighboursBounded(Point:point, XRange:point, YRange:point)<computes>:[]point =
        Neighbours := Point.GetNeighboursClassic()
        for (Neighbour : Neighbours, LeavesBounds[Neighbour, XRange, YRange]):
            Neighbour

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