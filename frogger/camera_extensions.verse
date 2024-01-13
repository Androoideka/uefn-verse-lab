using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices }
using { MovementExtensions }

CameraExtensions<public> := module:
    RepositionCamera<public>(Pivot:vector3, Board:[][]space, Camera:gameplay_camera_fixed_point_device)<decides><transacts>:vector3 =
        Space := Board[0][0]
        ColumnsWidth := Board.Length * Space.Size.X
        RowLength := if (AmountOfSpaces := Board[0].Length):
            AmountOfSpaces * Space.Size.X
        else:
            16.0 * Space.Size.X
        FieldOfView := 120.0
        ViewDistance := RowLength / (2 * Tan(DegreesToRadians(FieldOfView / 2.0)))
        Translation := Pivot + vector3{X := ColumnsWidth / 2.0, Y := RowLength / 2.0, Z := ViewDistance}
        Camera.TeleportTo[Translation, Camera.GetTransform().Rotation]
        Translation