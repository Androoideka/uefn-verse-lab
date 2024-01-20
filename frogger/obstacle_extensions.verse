using { /Verse.org }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { CollectionExtensions }
using { MovementExtensions }
using { SimulationExtensions }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Devices }

ObstacleExtensions<public> := module:
    PropMoverAxis:axis = axis.PX

    linear_obstacle<public> := class(tasker):
        StartSpace<public>:space
        EndSpace<public>:space
        Time<public>:float
        Phases<public>:[]int
        Obstacles<public>:[]tuple(dimensional, prop_mover_device)

        Run<override>()<suspends>:void =
            DirectionVector := (EndSpace.GetCentroid() - StartSpace.GetCentroid()).ToVector2()
            InDistance := EndToEndDistance(StartSpace, EndSpace)
            Speed := InDistance / Time
            for:
                Index -> Obstacle : Obstacles
                Phase := Phases[Index]
                Prop := Obstacle(0)
                PropMover := Obstacle(1)
            do:
                Sleep(Prop.GetBoundedDirectionVector(DirectionVector).Length() * Phase * 3 / Speed)
                if:
                    Prop.TeleportToSurface[StartSpace.GetSurface(?DirectionVector := DirectionVector), DirectionVector]
                    PropMover.TeleportTo[Prop.GetCentroid(), PropMoverAxis, DirectionVector]
                then:
                    PropMover.SetTargetDistance(InDistance / 100.0)
                    PropMover.SetTargetSpeed(Speed / 100.0)
                    PropMover.Enable()

    Proximity(Dimensional:dimensional, PropMover:prop_mover_device)<transacts>:float =
        Distance(Dimensional.Object.GetTransform().Translation, PropMover.GetTransform().Translation)

    CreateObstacles<public>(Board:[][]space, TaggedObjects:[]creative_object_interface, Offset:vector3, Size:vector3)<decides><transacts>:[]linear_obstacle =
        TaggedProps := for (Object : TaggedObjects, Prop := creative_prop[Object]):
            dimensional:
                Offset := Offset
                Size := Size
                Facing := axis.PY
                Object := Prop
        TaggedPropMovers := for (Object : TaggedObjects, PropMover := prop_mover_device[Object]):
            PropMover
        CarsPerLane := CombinationSumTo(Board.Length - 2, TaggedProps.Length)
        Phases := for:
            Amount : CarsPerLane
            StartSpace := Board[0][0]
            EndSpace := Board[0][Board[0].Length - 1]
            DirectionVector := (EndSpace.GetCentroid() - StartSpace.GetCentroid()).ToVector2()
            InDistance := EndToEndDistance(StartSpace, EndSpace)
            CarLength := TaggedProps[0].GetBoundedDirectionVector(DirectionVector).Length() * 3
            MaxCars := Floor[InDistance / CarLength]
        do:
            GetRandomNumbersFrom1(MaxCars, Amount)
        Obstacles := Reshape(Phases, Pair[TaggedProps, TaggedPropMovers, Proximity])
        for:
            Index -> ObstacleBatch : Obstacles
            PhaseBatch := Phases[Index]
            Row := Board[Index + 1]
            Range := Shuffle((Row[0], Row[Row.Length - 1]))
            StartSpace := Range[0]
            EndSpace := Range[1]
        do:
            linear_obstacle:
                StartSpace := StartSpace
                EndSpace := EndSpace
                Time := Random.GetRandomFloat(5.0, 15.0)
                Phases := PhaseBatch
                Obstacles := ObstacleBatch