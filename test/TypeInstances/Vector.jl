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


# FlipTypes
# ========

v = [FunctorDict(:a => 2, :b => 3, :c => 1),
     FunctorDict(:a => 5, :c => 6),
     FunctorDict(:a => 8, :c => 9)]

@test flip_types(v) == FunctorDict(:a=>[2, 5, 8], :b=>[3], :c=>[1, 6, 9])
