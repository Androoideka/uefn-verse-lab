using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }

MovementExtensions<public> := module:
    axis<public> := enum{MX, PX, MY, PY}

    CalculateAngle<public>(Vector:vector2, Axis:axis)<varies>:float =
        Val := case(Axis):
            axis.PX => Vector.Y / Vector.X
            axis.PY => Vector.X / Vector.Y
            axis.MX => Vector.Y / -Vector.X
            axis.MY => -Vector.Y / Vector.X
        ArcTan(Val)

    asset<public> := class<unique>:
        Offset<public>:vector3
        Size<public>:vector3
        Facing<public>:axis
        PropAsset<public>:creative_prop_asset

    dimensional<public> := class<unique>:
        Offset<public>:vector3
        Size<public>:vector3
        Facing<public>:axis
        Object<public>:creative_object

        GetCentroid<public>()<transacts>:vector3 =
            Object.GetTransform().Translation + Size * Offset * 0.5

        GetSurface<public>()<transacts>:vector3 =
            Object.GetTransform().Translation + Size * Offset * vector3{X := 0.5, Y := 0.5, Z := 0.0}

    space<public> := class(dimensional):
        Position<public>:tuple(int, int)

    direction<public> := enum{Up, Down, Left, Right}

    (Direction:direction).GetDirectionIndex<public>()<computes>:tuple(int, int) =
        case(Direction):
            direction.Up => (1, 0)
            direction.Down => (-1, 0)
            direction.Left => (0, -1)
            direction.Right => (0, 1)