# MonoidAlternative
# =================

a = [1,2,3]
b = [4,5,6]

@test a ⊕ b == [a; b]

# FunctorApplicativeMonad
# =======================

@test feltype(Vector{Int}) == Int
@test change_feltype(Vector{Int}, String) == Vector{String}

@test fmap(x -> x*x, a) == [1, 4, 9]

product_ab = [5, 6, 7, 6, 7, 8, 7, 8, 9]

@test mapn(a, b) do x, y
  x + y
end == product_ab

h = @syntax_fflatmap begin
  x = a
  y = b
  @pure x + y
end
@test h == product_ab

@test pure(Vector{Int}, 3) == [3]

# Sequence
# ========

v = [Dict(:a => 2, :b => 3, :c => 1), Dict(:a => 5, :c => 6), Dict(:a => 8, :c => 9)]
sequence(v)
# Note that because Dict implements both Ap and Combine, Combine is used by default
# the Ap implementation would drop :b as it does not appear in all contexts and hence the Ap implementation does not know how to call a function on all Contexts with the one  missing
# Combine can work with all Contexts independently
@test sequence(v) == Dict(:a=>[2, 5, 8], :b=>[3], :c=>[1, 6, 9])
