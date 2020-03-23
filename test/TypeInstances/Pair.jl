# MonoidAlternative
# =================

a = "a" => [1]
b = "b" => [2,3,4]

@test a ⊕ b == ("ab" => [1,2,3,4])

# FunctorApplicativeMonad
# =======================

@test eltype(Pair{Int, String}) == String
@test change_eltype(Pair{String, Int}, String) == Pair{String, String}



@test map(x -> [x; x], a) == ("a" => [1,1])

product_ab = ("ab" => [1,2,3,4])
@test mapn(a, b) do x, y
  [x; y]
end == product_ab

h = @syntax_flatmap begin
  x = a
  y = b
  @pure [x; y]
end
@test h == product_ab

@test pure(Pair{String}, 3) == Pair("", 3)


# FlipTypes
# =========

v = "first" => FunctorDict(:a => 2, :b => 3, :c => 1)
@test flip_types(v) == FunctorDict(
  :a => Pair("first", 2),
  :b=>Pair("first", 3),
  :c=>Pair("first", 1))
