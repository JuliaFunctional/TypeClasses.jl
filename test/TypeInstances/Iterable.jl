a = Iterable(i for i ∈ [1,2,3])
b = Iterable([4,5,6])

@test isAp(Iterable)
@test isFunctor(Iterable)
@test isNeutral(Iterable)
@test isCombine(Iterable)
@test isPure(Iterable)
@test isFlatten(Iterable)


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
@test h2 |> collect == [2, 12]

# However note that the following does not work
h3 = @syntax_flatmap begin
  x = a
  y = isodd(x) ? Option(x*x) : Option()
  z = b
  @pure x + y + z
end
# ERROR: MethodError: Cannot `convert` an object of type Iterable{Base.Generator{Array{Int64,1},var"#671#674"{Int64,Int64}}} to an object of type Option
@test_throws MethodError collect(h3)
# Tip: use ExtensibleEffects for such more complex multi effect interaction


# FlipTypes
# =========

it = Iterable(Option(i) for i ∈ [1, 4, 7])
@test map(collect, flip_types(it)) == Option([1, 4, 7])


# it2 = Iterable([i, i+2] for i ∈ 1:4)
# collect(it2)
# map(collect, flip_types(it2))
