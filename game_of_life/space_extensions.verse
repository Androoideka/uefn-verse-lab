using { /UnrealEngine.com/Temporary/SpatialMath }

SpaceExtensions<public> := module:
    FromXYZ<public>(X:float, Y:float, Z:float)<computes>:vector3 =
        vector3{X := X, Y := Y, Z := Z}

    (Size:int).GetRangeWithCenter<public>()<decides><computes>:tuple(int, int) =
        (Ceil(-Size / 2), Floor(Size / 2))