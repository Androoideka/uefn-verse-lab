using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath }

MovementExtensions<public> := module:
    axis<public> := enum{MX, PX, MY, PY}

    (Vector:vector3).ToVector2<public>()<computes>:vector2 =
        vector2{X := Vector.X, Y := Vector.Y}

    (Vector:vector2).ToVector3<public>()<computes>:vector3 =
        vector3{X := Vector.X, Y := Vector.Y}

    (Object:creative_object).TeleportTo<public>(Translation:vector3, Facing:axis, DirectionVector:vector2)<decides><transacts>:void =
        Angle := CalculateAngle(DirectionVector, Facing)
        Rotation := IdentityRotation().ApplyWorldRotationZ(Angle)
        Object.TeleportTo[Translation, Rotation]

    CalculateAngle(Vector:vector2, Axis:axis)<varies>:float =
        #TODO: Check formulas for MX and MY better
        Arguments := case(Axis):
            axis.PX => (Vector.Y, Vector.X)
            axis.PY => (-Vector.X, Vector.Y)
            axis.MX => (-Vector.Y, -Vector.X)
            axis.MY => (Vector.X, -Vector.Y)
        ArcTan(Arguments)

    GetBoundedDirectionVector(DirectionVector:vector2, RectWidth:float, RectHeight:float)<computes>:vector2 =
        if (DirectionVector.X = 0, DirectionVector.Y = 0):
            return DirectionVector
        XFactor := if (Value := RectWidth / Abs(DirectionVector.X), Value <> 1.0/0.0):
            Value
        else:
            0.0
        YFactor := if (Value := RectHeight / Abs(DirectionVector.Y), Value <> 1.0/0.0):
            Value
        else:
            0.0
        Factor := Max(XFactor, YFactor)
        DirectionVector * Factor

    asset<public> := class<unique>:
        Offset<public>:vector3
        Size<public>:vector3
        Facing<public>:axis
        PropAsset<public>:creative_prop_asset
        Scale<public>:vector3 = vector3{X := 1.0, Y := 1.0, Z := 1.0}

        ToSurface<public>(Surface:vector3)<computes>:vector3 =
            Surface + Size * Scale * (Offset + vector3{X := 0.0, Y:= 0.0, Z := -0.92}) * 0.5

        SpawnOnSurface<public>(Surface:vector3)<decides><transacts>:dimensional =
            Transform := transform{Translation := ToSurface(Surface), Rotation := IdentityRotation(), Scale := Scale}
            Result := SpawnProp(PropAsset, Transform)
            dimensional:
                Offset := Offset
                Size := Size * Scale
                Facing := Facing
                Object := Result(0)?

    dimensional<public> := class<unique>:
        Offset<public>:vector3 = vector3{}
        Size<public>:vector3 = vector3{}
        Facing<public>:axis = axis.PX
        Object<public>:creative_prop = creative_prop{}

        GetBoundedDirectionVector<public>(DirectionVector:vector2)<computes>:vector3 =
            GetBoundedDirectionVector(-DirectionVector, Size.X / 2.0, Size.Y / 2.0).ToVector3()

        GetCentroid<public>()<transacts>:vector3 =
            Object.GetTransform().Translation + 0.5 * Size * Offset

        GetSurface<public>(?DirectionVector:vector2=vector2{})<transacts>:vector3 =
            Object.GetTransform().Translation + 0.5 * Size * (Offset + vector3{X := 0.0, Y:= 0.0, Z := 1.0}) + GetBoundedDirectionVector(DirectionVector)

        ToSurface<public>(Surface:vector3)<computes>:vector3 =
            Surface + Size * (Offset + vector3{X := 0.0, Y := 0.0, Z := -0.92}) * 0.5

        TeleportToSurface<public>(Surface:vector3, DirectionVector:vector2)<decides><transacts>:void =
            Object.IsValid[]
            Translation := ToSurface(Surface)
            Object.TeleportTo[Translation, Facing, DirectionVector]

        MoveToSurface<public>(Surface:vector3, Time:float)<suspends>:void =
            if (Object.IsValid[]):
                Translation := ToSurface(Surface)
                DirectionVector := (Translation - Object.GetTransform().Translation).ToVector2()
                Angle := CalculateAngle(DirectionVector, Facing)
                Rotation := IdentityRotation().ApplyWorldRotationZ(Angle)
                Object.MoveTo(Translation, Rotation, Time)

    EndToEndDistance<public>(StartProp:dimensional, EndProp:dimensional)<transacts>:float =
        DirectionVector := (EndProp.GetCentroid() - StartProp.GetCentroid()).ToVector2()
        DirectionVector.Length() + StartProp.GetBoundedDirectionVector(DirectionVector).Length() + EndProp.GetBoundedDirectionVector(-DirectionVector).Length()

    space<public> := class(dimensional):
        Position<public>:tuple(int, int)

    label<public> := class:
        Display<public>:billboard_device
        CameraTransform<public>:transform
        DistanceFromCamera<public>:float = 512.0

        block:
            Rotation := IdentityRotation().ApplyWorldRotationX(DegreesToRadians(90.0)).ApplyWorldRotationZ(DegreesToRadians(-90.0))
            if (Display.TeleportTo[Display.GetTransform().Translation, Rotation]) {}

        ToSurface(Surface:vector3)<transacts>:vector3 =
            Offset := vector3{X := 128.0, Y := 0.0, Z := 0.0}
            RelativeTranslation := Surface - CameraTransform.Translation
            NameHeight := -DistanceFromCamera
            Factor := Abs(NameHeight / RelativeTranslation.Z)
            CameraTransform.Translation + RelativeTranslation * Factor + Offset

        TeleportTo<public>(Surface:vector3)<decides><transacts>:void =
            Display.TeleportTo[ToSurface(Surface), Display.GetTransform().Rotation]

        MoveTo<public>(Surface:vector3, Time:float)<suspends>:void =
            Display.MoveTo(ToSurface(Surface), Display.GetTransform().Rotation, Time)

    direction<public> := enum{Up, Down, Left, Right}

    (Direction:direction).GetDirectionIndex<public>()<computes>:tuple(int, int) =
        case(Direction):
            direction.Up => (1, 0)
            direction.Down => (-1, 0)
            direction.Left => (0, -1)
            direction.Right => (0, 1)