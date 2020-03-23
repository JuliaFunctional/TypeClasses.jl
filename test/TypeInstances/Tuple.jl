@test ("hi", "b") ⊕ ("!", ".") == ("hi!", "b.")
@test neutral(Tuple{String, String, String}) == ("", "", "")
