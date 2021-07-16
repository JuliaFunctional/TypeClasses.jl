# MonoidAlternative
# =================

a = Writer("a", [1])
b = Writer("b", [2,3,4])

# monoid is supported for convenience
a ⊕ b == Writer("ab", [1,2,3,4])


# FunctorApplicativeMonad
# =======================

@test eltype(Writer{Int, String}) == String

@test map(x -> [x; x], a) == Writer("a", [1,1])

product_ab = Writer("ab", [1,2,3,4])
@test mapn(a, b) do x, y
  [x; y]
end == product_ab

h = @syntax_flatmap begin
  x = a
  y = b
  @pure [x; y]
end
@test h == product_ab

@test pure(Writer{String}, 3) == Writer("", 3)

# working with TypeClasses.pure
@test (@syntax_flatmap begin
  a = pure(Writer{String}, 5)
  Writer("hi")
  @pure a
end) == Writer("hi", 5)

@test (@syntax_flatmap begin
  a = pure(Writer, 5)
  Writer(Option("hi"))
  @pure a
end) == Writer(Option("hi"), 5)


# FlipTypes
# =========

v = Writer("first", [:a, :b, :c])
@test flip_types(v) == [Writer("first", :a), Writer("first", :b), Writer("first", :c)]

vs = [Writer("first", :a), Writer("second", :b), Writer("third", :c)]
@test flip_types(vs) == Writer("firstsecondthird", [:a, :b, :c])