using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Fortnite.com/Characters }

SpaceExtensions<public> := module:
    direction<public> := enum{Up, Down, Left, Right}

    (Direction:direction).GetDirectionOffset<public>()<computes>:vector3 =
        Amount := 500.0
        case(Direction):
            direction.Up => vector3{X := -1.0 * Amount, Y := 0.0, Z := 0.0}
            direction.Down => vector3{X := 1.0 * Amount, Y := 0.0, Z := 0.0}
            direction.Left => vector3{X := 0.0, Y := 1.0 * Amount, Z := 0.0}
            direction.Right => vector3{X := 0.0, Y := -1.0 * Amount, Z := 0.0}

    (Rotation:rotation).GetDirection<public>()<decides><transacts>:vector3 =
        Angles := Rotation.GetYawPitchRollDegrees()
        Yaw := Angles[0]
        Pitch := Angles[1]
        Roll := Angles[2]
        YawRadians := DegreesToRadians(Yaw)
        PitchRadians := DegreesToRadians(Pitch)
        RollRadians := DegreesToRadians(Roll)
        X := Cos(YawRadians) * Cos(PitchRadians)
        Y := Sin(YawRadians) * Cos(PitchRadians)
        Z := Sin(PitchRadians)
        vector3{X := X, Y := Y, Z := Z}

    CastLine<public>(Character:fort_character, DebugDraw:debug_draw):void =
        Location := Character.GetViewLocation()
        Rotation := Character.GetViewRotation()
        if (Direction := Rotation.GetDirection[]):
            DebugDraw.DrawLine(Location, Location + (Direction * 500.0), ?DrawDurationPolicy := debug_draw_duration_policy.Persistent)