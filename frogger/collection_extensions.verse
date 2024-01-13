CollectionExtensions<public> := module:
    Zip<public>(Operand1:[]input, Operand2:[]input, Operation:type{_(:input, :input)<transacts>:result} where input:type, result:type)<transacts>:[]result =
        for (Index -> Value1 : Operand1, Value2 := Operand2[Index]):
            Operation(Value1, Value2)

    Add<public>(Value1:int, Value2:int)<computes>:int =
        Value1 + Value2

    Subtract<public>(Value1:int, Value2:int)<computes>:int =
        Value1 - Value2

    Pair<public>(Array1:[]t1, Array2:[]t2, ProximityFunction:type{_(:t1, :t2)<transacts>:float} where t1:type, t2:type)<decides><transacts>:[]tuple(t1, t2) =
        for (Element1 : Array1):
            var Closest:?t2 = false
            for (Element2 : Array2, not Closest? or ProximityFunction(Element1, Element2) < ProximityFunction(Element1, Closest?)):
                set Closest = option{Element2}
            (Element1, Closest?)

    Reshape<public>(Matrix:[][]t1, Array:[]t2 where t1:type, t2:type)<transacts>:[][]t2 =
        var Index:int = 0
        for (Row : Matrix):
            for (Element : Row, ElementFromArray := Array[Index]):
                set Index = Index + 1
                ElementFromArray

    (Array:[]t where t:type).Pop<public>()<decides><transacts>:tuple([]t, t) =
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
        for (ArrayItem : Array):
            if (ArrayItem = Item):
                return true
        false