a = Iterable(i for i ∈ [1,2,3])
b = Iterable([4,5,6])

@test isAp(Iterable)
@test isFunctor(Iterable)
@test isNeutral(Iterable)
@test isCombine(Iterable)
@test isPure(Iterable)
@test isFlatten(Iterable)

@test isFlipTypes(Iterable{FunctorDict{Symbol, String}})
@test isFlipTypes(Iterable{Vector{String}})


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


# FlipTypes
# =========

it = Iterable(FunctorDict(:a => i, :b => i+1, :c => i+2) for i ∈ 1:3:7)
@test map(collect, flip_types(it)) == FunctorDict(:a => [1, 4, 7], :b => [2,5,8], :c => [3, 6, 9])


# it2 = Iterable([i, i+2] for i ∈ 1:4)
# collect(it2)
# map(collect, flip_types(it2))
