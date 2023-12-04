using { /Verse.org/Random }

Extensions<public> := module:
    (Items:[][]t where t:type).Flatten<public>()<computes>:[]t =
        for (NestedArray : Items, Item : NestedArray):
            Item

    Map<public>(Array:[]input, Func:type{_(:input):result} where input:type, result:type):[]result =
        for (Element : Array):
            Func(Element)

    MMap<public>(Matrix:[][]input, Func:type{_(:input):result} where input:type, result:type):[][]result =
        for (Array : Matrix):
            for (Element : Array):
                Func(Element)

    Reduce<public>(Array:[]input, Func:type{_(:tuple(input, result))<transacts>:result}, Accumulator:result where input:type, result:type)<transacts>:result =
        var AccumulatorVariable:result = Accumulator
        for (Element : Array):
            set AccumulatorVariable = Func(Element, AccumulatorVariable)
        AccumulatorVariable

    (Array:[]t where t:subtype(comparable)).IsAllEqual<public>()<transacts>:logic =
        if (FirstElement := Array[0]):
            Result := Reduce(Array, IsEqual, (FirstElement, true))
            Result(1)
        else:
            false
    
    IsEqual(Item:t, Accumulator:tuple(t, logic) where t:subtype(comparable))<computes>:tuple(t, logic) =
        if (Accumulator(1)?):
            (Item, logic{Item = Accumulator(0)})
        else:
            (Item, false)
        