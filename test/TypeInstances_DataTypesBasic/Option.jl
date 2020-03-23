using TypeClasses
TypeClasses.@overwrite_Base
using DataTypesBasic
DataTypesBasic.@overwrite_Base
using Test

# MonoidAlternative
# =================

@test neutral(Option) == Option(nothing)

@test Option(3) ⊛ Option(4) == Option(3)  # take the first non-nothing
@test Option{Int}(nothing) ⊛ Option(4) == Option(4)  # take the first non-nothing
@test Option(nothing) ⊛ Option(4) == Option(4)  # take the first non-nothing

@test Option{String}("hi") ⊕ Option{String}("ho") == Option{String}("hiho")


# FunctorApplicativeMonad
# =======================

@test eltype(Option{Int}) == Int
@test eltype(Some{Int}) == Int
@test eltype(None{Int}) == Int
@test change_eltype(Some{Int}, Bool) == Some{Bool}
@test change_eltype(Option{Int}, Bool) == Option{Bool}

# TODO
@test map(Option(3)) do x
  x*x
end == Option(9)

@test map(Option(nothing)) do x
  x*x
end == Option(nothing)

@test mapn(Option(3), Option("hi")) do x, y
  "$x, $y"
end == Option("3, hi")

@test mapn(Option(3), Option(nothing)) do x, y
  "$x, $y"
end == Option(nothing)

ho = @syntax_flatmap begin
  a = Option(3)
  b = Option("hi")
  @pure "$a, $b"
end
@test ho == Option("3, hi")

ho = @syntax_flatmap begin
  a = Option(3)
  b = Option(nothing)
  @pure "$a, $b"
end
@test ho == Option{String}(nothing)


@test pure(Option, 4) == Option(4)

# FlipTypes
# =========

# TODO
