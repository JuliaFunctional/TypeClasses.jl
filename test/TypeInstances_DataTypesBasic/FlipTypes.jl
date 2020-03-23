using TypeClasses
TypeClasses.@overwrite_Base
using DataTypesBasic
DataTypesBasic.@overwrite_Base
using Test


# Maybe Dict
# ==========

@test isCombine(None{String})
@test isCombine(Option{String})
@test isCombine(Option)
m = FunctorDict(
  :a => Option(4),
  :b => Option(6))

@test flip_types(m) == Option(FunctorDict(:a => 4, :b => 6))

m2 = FunctorDict(
  :a => Option(4),
  :b => Option(nothing))
@test flip_types(m2) == Option()

# Either Dict
# ===========

e = FunctorDict(
  :a => Either{String}(4),
  :b => Either{String}(6))

@test flip_types(e) == Right{String}(FunctorDict(:a => 4, :b => 6))

e2 = FunctorDict(
  :a => Either{String}(4),
  :b => Either{String, Int}("hi"))
@test flip_types(e2) == Left("hi")


e3 = FunctorDict(
  :a => Either{String, Int}("a"),
  :b => Either{String, Int}("b"))

@test flip_types(e3) == Left("a")


# Try Dict
# ==========

t = FunctorDict(
  :a => @Try(4),
  :b => @Try(6))

@test flip_types(t) == Try(FunctorDict(:a => 4, :b => 6))

t2 = FunctorDict(
  :a => Try(4),
  :b => @Try(error("hi")))

@test typeof(flip_types(t2)) == typeof(@Try(error("hi")))


t3 = FunctorDict(
  :a => @Try(error("a")),
  :b => @Try(error("b")))

@test typeof(flip_types(t3)) == typeof(@Try(error("a")))
