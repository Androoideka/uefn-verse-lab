using { /Verse.org/Random }

CollectionExtensions<public> := module:
    (Array:[]t where t:subtype(comparable)).IsAllEqual<public>()<decides><transacts>:void =
        AllUnequal := for (Index -> Element : Array, Index <> 0, Element <> Array[0]):
            Index
        AllUnequal.Length = 0

    CreateRandomValues<public>(Count:int, Copies:int)<transacts>:[]int =
        Values := for (Number := 1..Floor(Count/Copies), Copy := 1..Copies):
            Number
        Shuffle(Values)