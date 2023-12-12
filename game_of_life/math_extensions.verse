MathExtensions<public> := module:
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