MathExtensions<public> := module:
    AddTuple<public>(Tuple1:tuple(int, int), Tuple2:tuple(int, int))<computes>:tuple(int, int) =
        (Tuple1(0) + Tuple2(0), Tuple1(1) + Tuple2(1))

    #https://stackoverflow.com/questions/919612/mapping-two-integers-to-one-in-a-unique-and-deterministic-way
    Szudzik<public>(Pair:tuple(int, int))<computes>:int =
        A := if (Pair(0) >= 0):
            2 * Pair(0)
        else:
            -2 * Pair(0) - 1
        B := if (Pair(1) >= 0):
            2 * Pair(1)
        else:
            -2 * Pair(1) - 1
        C := if (A >= B, Result := StdDiv[A * A + A + B, 2]):
            Result
        else if (Result := StdDiv[A + B * B, 2]):
            Result
        else:
            0
        if ((Pair(0) < 0 and Pair(1) < 0) or (Pair(0) >= 0 and Pair(1) >= 0)):
            C
        else:
            -C - 1

    StdDiv<public>(Dividend:int, Divisor:int)<decides><computes>:int =
        Rational := Dividend / Divisor
        if ((Dividend < 0 and Divisor < 0) or (Dividend >= 0 and Divisor >= 0)):
            Floor(Rational)
        else:
            Ceil(Rational)

    LeavesBounds<public>(Coordinate:int, Range:tuple(int, int))<decides><computes>:void =
        Coordinate >= Range(0) and Coordinate <= Range(1)

    LeavesBounds<public>(Pair:tuple(int, int), XRange:tuple(int, int), YRange:tuple(int, int))<decides><computes>:void =
        LeavesBounds[Pair(0), XRange] and LeavesBounds[Pair(1), YRange]

    WrapToBounds<public>(Coordinate:int, Range:tuple(int, int))<decides><computes>:int =
        Size := Range(1) - Range(0)
        Mod[Coordinate, Size] + Range(0)

    WrapToBounds<public>(Pair:tuple(int, int), XRange:tuple(int, int), YRange:tuple(int, int))<decides><computes>:tuple(int, int) =
        (WrapToBounds[Pair(0), XRange], WrapToBounds[Pair(1), YRange])