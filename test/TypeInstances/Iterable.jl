a = Iterable(i for i ∈ [1,2,3])
b = Iterable([4,5,6])

@test Union{Ap, Functor, Neutral, Combine, Pure, Sequence, FFlatten} <: traitsof(Iterable)

# MonoidAlternative
# =================

@test collect(a ⊕ b) == [collect(a); collect(b)]


# FunctorApplicativeMonad
# =======================

@test fmap(x -> x*x, a) |> collect == [1, 4, 9]

product_ab = [5, 6, 7, 6, 7, 8, 7, 8, 9]

@test mapn(a, b) do x, y
  x + y
end |> collect == product_ab

h = @syntax_fflatmap begin
  x = a
  y = b
  @pure x + y
end
@test h |> collect == product_ab


# Sequence
# ========

it = Iterable(Dict(:a => i, :b => i+1, :c => i+2) for i ∈ 1:3:7)
@test fmap(collect, sequence(it)) == Dict(:a => [1, 4, 7], :b => [2,5,8], :c => [3, 6, 9])
# note that the concrete implementation even uses Vectors, so that collect is redundant
# however that is an implementation detail which may change
