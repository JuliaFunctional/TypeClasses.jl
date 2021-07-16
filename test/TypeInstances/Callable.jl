using TypeClasses
using Test
using DataTypesBasic
using Suppressor

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

# this works because Callable implements `ap`

a = Callable.([x -> x, y -> 2y, z -> z*z])
@test flip_types(a)(3) == [3, 6, 9]
