
using Traits
@test eltype(Vector{Int}) == Int
@test change_eltype(FunctorDict{Int, String}, Int) == FunctorDict{Int, Int}

# we use plain Identity Monads for testing


# Applicative defaults
# --------------------

struct TestApDefault
  x
end
# we need to define change_eltype, as the default version assumes to have `map` already defined
TypeClasses.change_eltype(::Type{TestApDefault}, E) = TestApDefault
TypeClasses.ap(f::TestApDefault, x::TestApDefault) = TestApDefault(f.x(x.x))
TypeClasses.pure(::Type{TestApDefault}, x) = TestApDefault(x)
TypeClasses.map(f, x::TestApDefault) = TypeClasses.default_map(f, x)

@test isFunctor(TestApDefault)
@test map(TestApDefault(4)) do x
  x*x
end == TestApDefault(4*4)


# Monad defaults
# --------------

struct TestDefaultFFlattenFunctor
  x
end
TypeClasses.flatten(x::TestDefaultFFlattenFunctor) = x.x
TypeClasses.map(f, x::TestDefaultFFlattenFunctor) = TestDefaultFFlattenFunctor(f(x.x))
TypeClasses.ap(f::TestDefaultFFlattenFunctor, x::TestDefaultFFlattenFunctor) = TypeClasses.default_ap(f, x)

@test isAp(TestDefaultFFlattenFunctor)
@test mapn(TestDefaultFFlattenFunctor(3), TestDefaultFFlattenFunctor(4)) do x, y
  x + y
end == TestDefaultFFlattenFunctor(3 + 4)
