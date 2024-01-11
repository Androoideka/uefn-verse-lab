using { /Verse.org }
using { /Verse.org/Simulation }
using { MovementExtensions }
using { SimulationExtensions }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices }

ObstacleExtensions<public> := module:
    PropMoverAxis:axis = axis.PX

    parallel_obstacle<public> := class(tasker):
        StartSpace<public>:space
        EndSpace<public>:space
        Time<public>:float
        Obstacles<public>:[]tuple(prop_mover_device, dimensional, int)

        Run<override>()<suspends>:void =
            DirectionalVector := EndSpace.GetCentroid() - StartSpace.GetCentroid()
            Directional2DVector := vector2{X := DirectionalVector.X, Y := DirectionalVector.Y}
            PropMoverRotation := IdentityRotation().ApplyLocalRotationZ(CalculateAngle(Directional2DVector, PropMoverAxis))
            InDistance := Distance(EndSpace.GetCentroid(), StartSpace.GetCentroid()) + StartSpace.Size.X
            Speed := InDistance / Time
            for:
                Obstacle : Obstacles
                PropMover := Obstacle(0)
                Prop := Obstacle(1)
                Phase := Obstacle(2)
                PropRotation := Prop.Object.GetTransform().Rotation.ApplyLocalRotationZ(CalculateAngle(Directional2DVector, Prop.Facing))
                PropMover.TeleportTo[StartSpace.GetSurface(), PropMoverRotation]
                Prop.Object.TeleportTo[StartSpace.GetSurface() + Prop.Size * (Prop.Offset - vector3{X := 0.0, Y := 0.0, Z := 1.0}), PropRotation]
            do:
                Sleep(Prop.Size.X * Phase / Speed)
                PropMover.SetTargetDistance(InDistance)
                PropMover.SetTargetSpeed(Speed)
                Print("{InDistance}")
                PropMover.Enable()

    CreateObstacles<public>(Board:[][]space, CarMovers:[]prop_mover_device, Cars:[]dimensional, Phases:[]int)<transacts>:[]parallel_obstacle =
        ObstacleBatches := for:
            Index := 1..Board.Length - 2
            Length := Floor(Cars.Length / (Board.Length - 2 - 2))
            Leftover := Mod[Cars.Length, (Board.Length - 2 - 2)]
            Overflow := if (Leftover < Index):
                1
            else:
                0
            PreviousOverflows := Min(Index, Leftover)
        do:
            StartIndex := (Index * Length + PreviousOverflows)
            EndIndex := StartIndex + Length + Overflow
            for:
                ObstacleIndex := StartIndex..EndIndex
                CarMover := CarMovers[ObstacleIndex]
                Car := Cars[ObstacleIndex]
                Phase := Phases[ObstacleIndex]
            do:
                (CarMover, Car, Phase)
        for:
            Index -> ObstacleBatch : ObstacleBatches
            Row := Board[Index + 1]
            StartSpace := Row[0]
            EndSpace := Row[Row.Length - 1]
        do:
            parallel_obstacle:
                StartSpace := StartSpace
                EndSpace := EndSpace
                Time := Random.GetRandomFloat(5.0, 15.0)
                Obstacles := ObstacleBatch