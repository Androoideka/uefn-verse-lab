CollectionExtensions<public> := module:
    CreateHashMap<public>(Array:[]t, Func:type{_(:t)<transacts>:int} where t:type)<transacts>:[int]t =
        var HashMap:[int]t = map{}
        for (Element : Array):
            if (set HashMap[Func(Element)] = Element) {}
        HashMap

    GetOrDefault<public>(Map:[key]val, Item:key, Default:val where key:subtype(comparable), val:type)<computes>:val =
        if (Val := Map[Item]):
            Val
        else:
            Default

    Contains<public>(Array:[]t, Item:t where t:subtype(comparable))<computes>:logic =
        for (ArrayItem : Array):
            if (ArrayItem = Item):
                return true
        false

    Reduce<public>(Array:[]input, Func:type{_(:tuple(input, result))<transacts>:result}, Accumulator:result where input:type, result:type)<transacts>:result =
        var AccumulatorVariable:result = Accumulator
        for (Element : Array):
            set AccumulatorVariable = Func(Element, AccumulatorVariable)
        AccumulatorVariable

    InsertOrIncrement<public>(Item:t, FrequencyMap:[t]int where t:subtype(comparable))<transacts>:[t]int =
        CurrentOccurrences := GetOrDefault(FrequencyMap, Item, 0)
        var NewFrequencyMap:[t]int = FrequencyMap
        if (set NewFrequencyMap[Item] = CurrentOccurrences + 1):
            NewFrequencyMap
        else:
            FrequencyMap

    (Array:[]t where t:subtype(comparable)).CreateFrequencyMap<public>()<transacts>:[t]int =
        Reduce(Array, InsertOrIncrement, map{})

    AddTuple<public>(Tuple1:tuple(int, int), Tuple2:tuple(int, int))<computes>:tuple(int, int) =
        (Tuple1(0) + Tuple2(0), Tuple1(1) + Tuple2(1))