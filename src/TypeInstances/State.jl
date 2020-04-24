using TypeClasses

# Monoid instances
# ================

# this is standard Applicative combine implementation, however functions have a too complex type signature
# for the standard implementation to kick in
# hence we reimplement it for more relaxed types
TypeClasses.combine(a::State, b::State) = mapn(combine, a, b)
TypeClasses.orelse(a::State, b::State) = mapn(orelse, a, b)


# FunctorApplicativeMonad
# =======================

TypeClasses.map(f, a::State) = State() do state
  value, newstate = a(state)
  f(value), newstate
end

TypeClasses.pure(::Type{<:State}, a) = State() do state
  a, state
end

TypeClasses.ap(f::State, a::State) = State() do state0
  func, state1 = f(state0)
  value, state2 = a(state1)
  func(value), state2
end

TypeClasses.flatmap(f, a::State) = State() do state0
  value, state1 = a(state0)
  convert(State, f(value))(state1)
end

# neither flip_types nor fix_type is possible or makes sense
