using TypeClasses
using Traits
using Test
using IsDef
using DataTypesBasic
using Suppressor

DataTypesBasic.@overwrite_Base
TypeClasses.@overwrite_Base
splitln(str) = split(strip(str), "\n")

# MonoidAlternative
# =================

@test !isCombine(Nothing)
@test_throws MethodError nothing ⊕ nothing
@test isCombine(String)
@test "hi" ⊕ "ho" == "hiho"

@test !isCombine(FunctorDict{String, Nothing})
@test isCombine(FunctorDict{Symbol, String})

d1 = FunctorDict(:a => "hi", :b => "ii")
d2 = FunctorDict(:a => "ho", :b => "jj", :c => "c")
@test d1 ⊕ d2 == FunctorDict(:a => "hiho", :b => "iijj", :c => "c")


# FunctorApplicativeMonad
# =======================

@test !isPure(FunctorDict{String, Nothing})

T = FunctorDict{String, FunctorDict{String, Nothing}}
@test isNeutral(T)
@test isFunctor(T)
@test isFlatten(T)
@test isAp(T)

# need same key-type for flatten
T = FunctorDict{String, FunctorDict{Int, Nothing}}
@test isNeutral(T)
@test isFunctor(T)
@test !isFlatten(T)
@test isAp(T)

# need nested dict for flatten
T = FunctorDict{String, Int}
@test isNeutral(T)
@test isFunctor(T)
@test !isFlatten(T)
@test isAp(T)


d1 = FunctorDict(:a => 1, :b => 2)
d2 = FunctorDict(:a => 11, :b => 12, :c => 13)

@test map(d1) do x
  x*x
end == FunctorDict(:a => 1, :b => 4)

applicative_sum = mapn(d1, d2) do x1, x2
  x1 + x2
end
@test applicative_sum == FunctorDict(:a => 12, :b => 14)

monadic_sum = @syntax_flatmap begin
  x1 = d1
  x2 = d2
  @pure x1 + x2
end
@test monadic_sum == FunctorDict(:a => 12, :b => 14)

@test applicative_sum == monadic_sum


# FlipTypes
# =========

# FunctorDict support FlipTypes on their own

a = [1,2]
b = [4,5]
d = FunctorDict(:a => a, :b => b)

flipped_types_d = [FunctorDict(:a => x, :b => y) for x ∈ a for y ∈ b]
@test flip_types(d) == flipped_types_d

# the standard iterables flip_types also works
flipped_flipped_d = FunctorDict(
  :a => [1,1,2,2],
  :b => [4,5,4,5]
)
@test flip_types(flipped_types_d) == flipped_flipped_d
