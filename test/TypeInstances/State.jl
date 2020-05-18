using Test
using TypeClasses
using Traits
using IsDef
using DataTypesBasic
using Suppressor


splitln(str) = split(strip(str), "\n")

# Combine
# =======

a = State(s -> ("hello $s", s+1))
b = State(s -> ("!", s+10))

@test (a ⊕ b)(4) == ("hello 4!", 15)

# FunctorApplicativeMonad
# =======================

g = State(s -> (s*2, s+1))
f = State(s -> (s*s, s))

# just function composition
fg = map(f, g)
@test fg(3) == ((36, 6), 4)

fPLUSg = mapn(f, g) do x1, x2
  x1 + x2
end

@test fPLUSg(3) == (9+6, 4)

fPRODg = @syntax_flatmap begin
  x1 = f
  x2 = g
  @pure x1 * x2
end

@test fPRODg(3) == (9*6, 4)


putget = @syntax_flatmap begin
  putstate(4)
  x = getstate
  @pure x
end
@test putget(()) == (4, 4)


# FlipTypes
# =========

# this only works because of the general `combine` implementation for State
# so be cautious as the eltypes need to support `combine` to not get a MethodError in runtime

a = State.([s -> (s, s), s -> (2s, s*s), s -> (s*s, 4)])
a2 = [map(x -> pure(Vector, x), v) for v in a]
@test flip_types(a)(3) == ([3, 6, 81], 4)
