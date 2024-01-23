using { /Verse.org/Random }

CollectionExtensions<public> := module:
    Zip<public>(Operand1:[]input, Operand2:[]input, Operation:type{_(:input, :input)<computes>:result} where input:type, result:type)<computes>:[]result =
        for (Index -> Value1 : Operand1, Value2 := Operand2[Index]):
            Operation(Value1, Value2)

    Add<public>(Value1:int, Value2:int)<computes>:int =
        Value1 + Value2

    Compare<public>(Value1:int, Value2:int)<computes>:int =
        if (Value1 > Value2):
            1
        else if (Value1 = Value2):
            0
        else:
            -1

    MinProximity(Value1:tuple(t, float), Value2:tuple(t, float) where t:type)<computes>:tuple(t, float) =
        if (Min(Value1(1), Value2(1)) = Value1(1)):
            Value1
        else:
            Value2

    MinRec(Array:[]t, Index:int, MinSoFar:t, ComparisonFunction:type{_(:t, :t)<computes>:t} where t:type)<computes>:t =
        if (Index <> 0, Item := Array[Index]):
            MinRec(Array, Index - 1, ComparisonFunction(Item, MinSoFar), ComparisonFunction)
        else:
            MinSoFar

    MinInList<public>(Array:[]t, ComparisonFunction:type{_(:t, :t)<computes>:t} where t:type)<decides><computes>:t =
        MinRec(Array, Array.Length - 1, Array[0], ComparisonFunction)

    Pair<public>(Array1:[]t1, Array2:[]t2, ProximityFunction:type{_(:t1, :t2)<transacts>:float} where t1:type, t2:type)<decides><transacts>:[]tuple(t1, t2) =
        for (Element1 : Array1):
            Proximities := for (Element2 : Array2):
                (Element2, ProximityFunction(Element1, Element2))
            (Element1, MinInList[Proximities, MinProximity](0))

    Reshape<public>(Matrix:[][]t1, Array:[]t2 where t1:type, t2:type)<transacts>:[][]t2 =
        var Index:int = 0
        for (Row : Matrix):
            for (Element : Row, ElementFromArray := Array[Index]):
                set Index = Index + 1
                ElementFromArray

    (Array:[]t where t:type).Pop<public>()<decides><computes>:tuple([]t, t) =
        PoppedElement := Array[0]
        NewArray := for (Index -> Element : Array, Index <> 0):
            Element
        (NewArray, PoppedElement)

    Sort<public>(Items:[]t, IsAscending:logic, Comparer:type {_(:t, :t)<computes>:int} where t:type)<computes>:[]t = 
        if (Items.Length > 1, Pivot := Items[Floor(Items.Length/2)]):
            Left := for (Item:Items, Comparer(Item, Pivot) < 0) do Item
            Middle := for (Item:Items, Comparer (Item, Pivot) = 0) do Item
            Right := for (Item:Items, Comparer (Item, Pivot) > 0) do Item
            if (IsAscending?):
                Sort (Left, IsAscending, Comparer) + Middle + Sort (Right, IsAscending, Comparer)
            else:
                Sort (Right, IsAscending, Comparer) + Middle + Sort (Left, IsAscending, Comparer)
        else:
            Items

    Contains<public>(Array:[]t, Item:t where t:subtype(comparable))<computes>:logic =
        for (ArrayItem : Array, ArrayItem = Item):
            return true
        false

    GetRandomNumbersFrom1<public>(MaxValue:int, Length:int)<transacts>:[]int =
        Range := for (N := 1..MaxValue):
            N
        ShuffledRange := Shuffle(Range)
        for (Index -> Element : ShuffledRange, Index < Length):
            Element

    #https://stackoverflow.com/questions/3589214/generate-random-numbers-summing-to-a-predefined-value
    CombinationSumTo<public>(NumbersInCombination:int, Sum:int)<transacts>:[]int =
        Dividers := Sort(GetRandomNumbersFrom1(Sum - 1, NumbersInCombination - 1), true, Compare)
        for (Index -> A : Dividers + array{Sum}, B := (array{0} + Dividers)[Index]):
            A - B