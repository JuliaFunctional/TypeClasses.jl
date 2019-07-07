
# MonoidAlternative
# =================

@test !(Combine <: traitsof(Dict{String, Nothing}))

@test "hi" ⊕ "ho" == "hiho"

@test !(typeof(⊕) <: traitsof(Dict{Symbol, String}))  # this should fail as we are referring to a locally linked version of ⊕ (linked to our traitsof)
@test typeof(TypeClasses.:⊕) <: traitsof(Dict{Symbol, String})

d1 = Dict(:a => "hi", :b => "ii")
d2 = Dict(:a => "ho", :b => "jj", :c => "c")
@test d1 ⊕ d2 == Dict(:a => "hiho", :b => "iijj", :c => "c")


# FunctorApplicativeMonad
# =======================


@fiter begin
  a = d1
  @pure @show a
  b = d2
  @pure @show a * b
end

@test !(Pure <: traitsof(Dict{String, Nothing}))

@test Union{Neutral, Functor, FFlatten, Ap} <: traitsof(Dict{String, Dict{String, Nothing}})
# need same key-type
# TODO generic sequence definition kicks in... that seems unwanted... at least the one without further call to flatten
@test !(Union{Neutral, Functor, FFlatten, Ap} <: traitsof(Dict{String, Dict{Int, Nothing}}))
# need nested dict
@test !(Union{Neutral, Functor, FFlatten, Ap} <: traitsof(Dict{String, Int}))

flatten(Dict("hi" => Dict(1 => nothing)))

d1 = Dict(:a => 1, :b => 2)
d2 = Dict(:a => 11, :b => 12, :c => 13)

@test fmap(d1) do x
  x*x
end == Dict(:a => 1, :b => 4)

applicative_sum = mapn(d1, d2) do x1, x2
  x1 + x2
end
@test applicative_sum == Dict(:a => 12, :b => 14)

monadic_sum = @syntax_fflatmap begin
  x1 = d1
  x2 = d2
  @pure x1 + x2
end
@test monadic_sum == Dict(:a => 12, :b => 14)

@test applicative_sum == monadic_sum


# Sequence
# ========

a = [1,2]
b = [4,5]
d = Dict(:a => a, :b => b)

sequence_d = [Dict(:a => x, :b => y) for x ∈ a for y ∈ b]
@test sequence(d) == sequence_d
