using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/SpatialMath}
using { SimulationExtensions }
using { MovementExtensions }

TimerExtensions<public> := module:
    ToUIMessage<public><localizes>(Text:string)<varies>:message = "{Text}"

    countdown_timer<public> := class(tasker):
        TimerTickPeriod<public>:float = 1.0
        var RemainingTime<public>:float
        var Labels<public>:[]label = array{}

        Configure<public>(Label:label, Board:[][]space)<decides><transacts>:void =
            LeftSpace := Board[Board.Length - 1][Floor((Board[0].Length - 1) / 2)]
            RightSpace := Board[Board.Length - 1][Ceil((Board[0].Length - 1) / 2)]
            Center := (RightSpace.GetSurface() + LeftSpace.GetSurface()) / 2.0
            Label.TeleportTo[Center]
            set Labels = Labels + array{Label}

        Run<override>()<suspends>:void =
            if (Time := GetHumanReadable[RemainingTime]):
                UpdateUI(Time)
            loop:
                Sleep(TimerTickPeriod)
                set RemainingTime -= TimerTickPeriod

                if (Time := GetHumanReadable[RemainingTime]):
                    UpdateUI(Time)

                if (RemainingTime <= 0.0):
                    break

        GetHumanReadable(Time:float)<decides><varies>:tuple(int, int) =
            IntTime := Int[Time]
            Minutes := Floor(IntTime / 60)
            Seconds := Mod[IntTime, 60]
            (Minutes, Seconds)
        
        UpdateUI(Minutes:int, Seconds:int):void =
            SecondsText := if ("{Seconds}".Length < 2):
                "0{Seconds}"
            else:
                "{Seconds}"
            for (Label : Labels):
                Label.Display.SetText(ToUIMessage("{Minutes}:{SecondsText}"))