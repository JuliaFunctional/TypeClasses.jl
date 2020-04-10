# MonoidAlternative
# =================

a = Writer("a", [1])
b = Writer("b", [2,3,4])

@test a ⊕ b == Writer("ab", [1,2,3,4])

# FunctorApplicativeMonad
# =======================

@test eltype(Writer{Int, String}) == String
@test change_eltype(Writer{String, Int}, String) == Writer{String, String}



@test map(x -> [x; x], a) == Writer("a", [1,1])

product_ab = Writer("ab", [1,2,3,4])
@test mapn(a, b) do x, y
  [x; y]
end == product_ab

h = @syntax_flatmap begin
  x = a
  y = b
  @pure [x; y]
end
@test h == product_ab

@test pure(Writer{String}, 3) == Writer("", 3)


# FlipTypes
# =========

v = Writer("first", [:a, :b, :c])
@test flip_types(v) == [Writer("first", :a), Writer("first", :b), Writer("first", :c)]
