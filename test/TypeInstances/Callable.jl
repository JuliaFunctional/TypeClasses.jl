using TypeClasses
using Traits
using Test
using IsDef
using DataTypesBasic
using Suppressor

DataTypesBasic.@overwrite_Some
splitln(str) = split(strip(str), "\n")

# Combine
# =======

a = Callable(x -> "hello $x")
b = Callable(x -> "!")

(a ⊕ b)(:Albert)

# FunctorApplicativeMonad
# =======================

g = Callable(x -> x*2)
f = Callable(x -> x*x)

# just function composition
fg = map(g) do x2
  f(x2)
end
@test fg(3) == f(g(3))

fPLUSg = mapn(f, g) do x1, x2
  x1 + x2
end

@test fPLUSg(3) == f(3) + g(3)

fPRODg = @syntax_flatmap begin
  x1 = f
  x2 = g
  @pure x1 * x2
end

@test fPRODg(3) == f(3) * g(3)


# FlipTypes
# =========

# this only works because of the general `combine` implementation for callables
# so be cautious as the eltypes need to support `combine` to not get a MethodError in runtime

a = Callable.([x -> x, y -> 2y, z -> z*z])
a2 = [map(x -> pure(Vector, x), v) for v in a]
@test flip_types(a)(3) == [3, 6, 9]
