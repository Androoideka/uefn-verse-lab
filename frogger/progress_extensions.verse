using { CollectionExtensions }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }

ProgressExtensions<public> := module:
    GetOrdinalNumber(Number:int)<computes>:string =
        Extension := if (Number >= 10 and Number <= 20):
            "th"
        else if (Remainder := Mod[Number, 10]):
            case(Remainder):
                1 => "st"
                2 => "nd"
                3 => "rd"
                _ => "th"
        else:
            "th"
        "{Number}{Extension}"

    CompareScores(First:tuple(int, player), Second:tuple(int, player))<computes>:int =
        if (First(0) > Second(0)):
            1
        else if (First(0) = Second(0)):
            0
        else:
            -1

    progress_reporter<public> := class:
        PlacementAccolades<public>:[]accolades_device
        ScoreAccolades<public>:[]accolades_device
        ScoreTracker<public>:score_manager_device
        EndGameDevice<public>:end_game_device
        var Places:[]player = array{}

        RegisterJump<public>(Player:player):void =
            ScoreTracker.SetScoreAward(1)
            ScoreTracker.Activate(Player)

        RegisterDeath<public>(Player:player):void =
            ScoreTracker.SetScoreAward(-1)
            ScoreTracker.Activate(Player)

        RegisterFinish<public>(Players:[]player):void =
            NewPlayers := for (Player : Players, not Contains(Places, Player)?):
                Player
            set Places = Places + NewPlayers
            
        Complete<public>():void =
            Scores := for:
                Index -> Player : Places
                Accolade := PlacementAccolades[Index]
                Score := ScoreTracker.GetCurrentScore(Player)
            do:
                Accolade.Award(Player)
                (Score, Player)
            SortedScores := Sort(Scores, false, CompareScores)
            for (Index -> Score : SortedScores, Accolade := ScoreAccolades[Index]):
                Accolade.Award(Score(1))
            if (First := Places[0]):
                EndGameDevice.Activate(First)