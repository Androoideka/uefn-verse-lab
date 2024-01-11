CollectionExtensions<public> := module:
    RemoveKeyFromMap<public>(Map:[key]val, ElementToRemove:key where key:subtype(comparable), val:type)<transacts>:[key]val=
        if (not Map[ElementToRemove]):
            return Map
        var NewMap:[key]val = map{}
        for (Key -> Value : Map, Key <> ElementToRemove):
            set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
        return NewMap

    RemoveValFromMap<public>(Map:[key]val, ElementToRemove:val where key:subtype(comparable), val:subtype(comparable))<transacts>:[key]val=
        var NewMap:[key]val = map{}
        for (Key -> Value : Map, Value <> ElementToRemove):
            set NewMap = ConcatenateMaps(NewMap, map{Key => Value})
        return NewMap

    Zip<public>(FirstOperand:[]input, SecondOperand:[]input, Operation:type{_(:input, :input)<transacts>:result} where input:type, result:type)<transacts>:[]result =
        for (Index -> FirstValue : FirstOperand, SecondValue := SecondOperand[Index]):
            Operation(FirstValue, SecondValue)

    Add<public>(First:int, Second:int)<computes>:int =
        First + Second

    Subtract<public>(First:int, Second:int)<computes>:int =
        First - Second