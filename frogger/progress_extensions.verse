using { CollectionExtensions }
using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }

ProgressExtensions<public> := module:
    CompareScores(First:tuple(int, player), Second:tuple(int, player))<computes>:int =
        if (First(0) > Second(0)):
            1
        else if (First(0) = Second(0)):
            0
        else:
            -1

    progress_reporter<public> := class:
        ScoreAccolades<public>:[]accolades_device
        ScoreTracker<public>:score_manager_device
        EndGameDevice<public>:end_game_device

        RegisterJump<public>(Player:player):void =
            ScoreTracker.SetScoreAward(1)
            ScoreTracker.Activate(Player)

        RegisterDeath<public>(Player:player):void =
            ScoreTracker.SetScoreAward(-1)
            ScoreTracker.Activate(Player)

        RegisterFinish<public>(Player:player):void =
            ScoreTracker.SetScoreAward(10)
            ScoreTracker.Activate(Player)
            
        Complete<public>(Players:[]player)<suspends>:void =
            Scores := for:
                Index -> Player : Players
                Accolade := ScoreAccolades[Index]
                Score := ScoreTracker.GetCurrentScore(Player)
            do:
                Accolade.Award(Player)
                (Score, Player)
            SortedScores := Sort(Scores, false, CompareScores)
            for (Index -> Score : SortedScores, Accolade := ScoreAccolades[Index]):
                Accolade.Award(Score(1))
            Sleep(5.0)
            if (First := SortedScores[0]):
                EndGameDevice.Activate(First(1))