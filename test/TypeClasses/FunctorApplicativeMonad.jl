
@test eltype(Vector{Int}) == Int

# we use plain Identity Monads for testing


# Applicative defaults
# --------------------

struct TestApDefault
  x
end

TypeClasses.map(f, x::TestApDefault) = TypeClasses.default_map_having_ap_pure(f, x)
TypeClasses.pure(::Type{TestApDefault}, x) = TestApDefault(x)
TypeClasses.ap(f::TestApDefault, x::TestApDefault) = TestApDefault(f.x(x.x))

@test map(TestApDefault(4)) do x
  x*x
end == TestApDefault(4*4)


# Monad defaults
# --------------

struct TestDefaultFFlattenFunctor
  x
end

TypeClasses.map(f, x::TestDefaultFFlattenFunctor) = TestDefaultFFlattenFunctor(f(x.x))
TypeClasses.flatmap(f, x::TestDefaultFFlattenFunctor) = f(x.x)

@test mapn(TestDefaultFFlattenFunctor(3), TestDefaultFFlattenFunctor(4)) do x, y
  x + y
end == TestDefaultFFlattenFunctor(3 + 4)
