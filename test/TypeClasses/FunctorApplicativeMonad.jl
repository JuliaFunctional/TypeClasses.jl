
@test eltype(Vector{Int}) == Int

# we use plain Identity Monads for testing


# Applicative defaults
# --------------------

struct TestApDefault
  x
end

TypeClasses.isMap(::Type{TestApDefault}) = true
TypeClasses.isPure(::Type{TestApDefault}) = true
TypeClasses.isAp(::Type{TestApDefault}) = true

TypeClasses.map(f, x::TestApDefault) = TypeClasses.default_map_having_ap_pure(f, x)
TypeClasses.pure(::Type{TestApDefault}, x) = TestApDefault(x)
TypeClasses.ap(f::TestApDefault, x::TestApDefault) = TestApDefault(f.x(x.x))

@test isFunctor(TestApDefault)
@test map(TestApDefault(4)) do x
  x*x
end == TestApDefault(4*4)


# Monad defaults
# --------------

struct TestDefaultFFlattenFunctor
  x
end
TypeClasses.isMap(::Type{TestDefaultFFlattenFunctor}) = true
TypeClasses.isFlatMap(::Type{TestDefaultFFlattenFunctor}) = true
TypeClasses.isAp(::Type{TestDefaultFFlattenFunctor}) = true

TypeClasses.map(f, x::TestDefaultFFlattenFunctor) = TestDefaultFFlattenFunctor(f(x.x))
TypeClasses.flatmap(f, x::TestDefaultFFlattenFunctor) = f(x.x)
TypeClasses.ap(f::TestDefaultFFlattenFunctor, x::TestDefaultFFlattenFunctor) = TypeClasses.default_ap_having_map_flatmap(f, x)

@test isAp(TestDefaultFFlattenFunctor)
@test mapn(TestDefaultFFlattenFunctor(3), TestDefaultFFlattenFunctor(4)) do x, y
  x + y
end == TestDefaultFFlattenFunctor(3 + 4)
