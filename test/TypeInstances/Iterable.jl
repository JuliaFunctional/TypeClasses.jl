a = Iterable(i for i ∈ [1,2,3])
b = Iterable([4,5,6])

# MonoidAlternative
# =================

@test collect(a ⊕ b) == [collect(a); collect(b)]


# FunctorApplicativeMonad
# =======================

@test map(x -> x*x, a) |> collect == [1, 4, 9]

product_ab = [5, 6, 7, 6, 7, 8, 7, 8, 9]
@test mapn(a, b) do x, y
  x + y
end |> collect == product_ab

h = @syntax_flatmap begin
  x = a
  y = b
  @pure x + y
end
@test h |> collect == product_ab

# Everything Iterable works with Iterable
h2 = @syntax_flatmap begin
  x = a
  y = isodd(x) ? Option(x*x) : Option()
  @pure x + y
end
@test collect(h2) == [2, 12]

# However note that the following does not work
h3() = @syntax_flatmap begin
  x = a
  y = isodd(x) ? Option(x*x) : Option()
  z = b
  @pure x, y, z
end
@test collect(h3()) == [
  (x, x*x, z) for x in a for z in b if isodd(x)
]


# FlipTypes
# =========

it = Iterable(Option(i) for i ∈ [1, 4, 7])
@test map(collect, flip_types(it)) == Option([1, 4, 7])