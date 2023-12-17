using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }

MovementExtensions<public> := module:
    direction<public> := enum{Up, Down, Left, Right}

    (Direction:direction).GetDirectionIndex<public>()<computes>:tuple(int, int) =
        case(Direction):
            direction.Up => (0, 1)
            direction.Down => (0, -1)
            direction.Left => (-1, 0)
            direction.Right => (1, 0)

    AddTuple<public>(First:tuple(int, int), Second:tuple(int, int))<computes>:tuple(int, int) =
        (First(0) + Second(0), First(1) + Second(1))

    position<public> := class:
        Index<public>:tuple(int, int)
        Translation<public>:vector3

    space<public> := class:
        Offsets<public>:vector3
        Prop<public>:creative_prop

        var IsOccupied<public>:logic = false

        GetTranslation<public>()<transacts>:vector3 =
            Prop.GetTransform().Translation + Offsets