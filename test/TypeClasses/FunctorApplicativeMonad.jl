@test feltype(Vector{Int}) == Int
@test change_feltype(Dict{Int, String}, Int) == Dict{Int, Int}
 # types without typeparameters should default to no change at all
@test change_feltype(typeof(+), Int) == typeof(+)
@test change_feltype(Dict{String}, Int) == Dict{Int}

# we use plain Identity Monads for testing

# Applicative defaults
# --------------------

struct TestApDefault
  x
end
TypeClasses.ap(::Traitsof, f::TestApDefault, x::TestApDefault) = TestApDefault(f.x(x.x))
TypeClasses.pure(::Traitsof, ::Type{TestApDefault}, x) = TestApDefault(x)

traitsof_refixate()
@test Functor <: traitsof(TestApDefault)
@test fmap(TestApDefault(4)) do x
  x*x
end == TestApDefault(4*4)


# Monad defaults
# --------------

struct TestDefaultFFlattenFunctor
  x
end
TypeClasses.fflatten(::Traitsof, x::TestDefaultFFlattenFunctor) = x.x
TypeClasses.fmap(::Traitsof, f, x::TestDefaultFFlattenFunctor) = TestDefaultFFlattenFunctor(f(x.x))

traitsof_refixate()
@test Ap <: traitsof(TestDefaultFFlattenFunctor)

@test mapn(TestDefaultFFlattenFunctor(3), TestDefaultFFlattenFunctor(4)) do x, y
  x + y
end == TestDefaultFFlattenFunctor(3 + 4)
