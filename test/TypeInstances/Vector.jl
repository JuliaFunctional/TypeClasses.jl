# MonoidAlternative
# =================

a = [1,2,3]
b = [4,5,6]

@test a ⊕ b == [a; b]

# FunctorApplicativeMonad
# =======================

@test eltype(Vector{Int}) == Int
@test change_eltype(Vector{Int}, String) == Vector{String}

@test map(x -> x*x, a) == [1, 4, 9]

product_ab = [5, 6, 7, 6, 7, 8, 7, 8, 9]
@test mapn(a, b) do x, y
  x + y
end == product_ab

h = @syntax_flatmap begin
  x = a
  y = b
  @pure x + y
end
@test h == product_ab

@test pure(Vector{Int}, 3) == [3]

# flatten combinations with other Monads
# --------------------------------------

@test flatten([Identity(3), Identity(4)]) == [3, 4]
@test flatten([Option(3), Option(nothing), Option(4)]) == [3, 4]
@test flatten([Try(4), (@Try error("hi")), Try(5)]) == [4, 5]
@test flatten([Either{String}(4), either("left", false, 3), Either{Int, String}("right")]) == [4, "right"]

h1 = @syntax_flatmap begin
 a, b = [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)]
 iftrue(a % 2 == 0) do
   a + b
 end
end
@test h1 == [5, 9]

# FlipTypes
# ========

v = [Option(:a),
     Option(:b),
     Option(:c)]

@test flip_types(v) == Option([:a, :b, :c])
