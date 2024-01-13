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
            InDistance := (DirectionVector.Length() + StartSpace.GetBoundedDirectionVector(DirectionVector).Length() + EndSpace.GetBoundedDirectionVector(-DirectionVector).Length()) / 100.0
            Speed := InDistance / Time
            for:
                Index -> Obstacle : Obstacles
                Phase := Phases[Index]
                Prop := Obstacle(0)
                PropMover := Obstacle(1)
            do:
                Sleep(Prop.GetBoundedDirectionVector(DirectionVector).Length() * Phase * 0.03 / Speed)
                if:
                    Prop.TeleportToSurface[StartSpace.GetSurface(?DirectionVector := DirectionVector), DirectionVector]
                    PropMover.TeleportTo[Prop.GetCentroid(), PropMoverAxis, DirectionVector]
                then:
                    PropMover.SetTargetDistance(InDistance)
                    PropMover.SetTargetSpeed(Speed)
                    PropMover.Enable()

    Proximity(Dimensional:dimensional, PropMover:prop_mover_device)<transacts>:float =
        Distance(Dimensional.Object.GetTransform().Translation, PropMover.GetTransform().Translation)

    CreateObstacles<public>(Board:[][]space, Phases:[][]int, TaggedObjects:[]creative_object_interface, Offset:vector3, Size:vector3)<decides><transacts>:[]linear_obstacle =
        TaggedProps := for (Object : TaggedObjects, Prop := creative_prop[Object]):
            dimensional:
                Offset := Offset
                Size := Size
                Facing := axis.PY
                Object := Prop
        TaggedPropMovers := for (Object : TaggedObjects, PropMover := prop_mover_device[Object]):
            PropMover
        Obstacles := Reshape(Phases, Pair[TaggedProps, TaggedPropMovers, Proximity])
        for:
            Index -> PhaseBatch : Phases
            ObstacleBatch := Obstacles[Index]
            Row := Board[Index + 1]
            Range := Shuffle(array{Row[0], Row[Row.Length - 1]})
            StartSpace := Range[0]
            EndSpace := Range[1]
        do:
            linear_obstacle:
                StartSpace := StartSpace
                EndSpace := EndSpace
                Time := Random.GetRandomFloat(5.0, 15.0)
                Phases := PhaseBatch
                Obstacles := ObstacleBatch