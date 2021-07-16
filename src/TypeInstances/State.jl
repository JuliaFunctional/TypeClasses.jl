using TypeClasses

# Monoid instances
# ================

# this is standard Applicative combine implementation
# there is no other sensible definition for combine and hence if this does fail, it fails correctly
TypeClasses.combine(a::State, b::State) = mapn(combine, a, b)

# we don't do the same for orelse, as orelse lives on the container level, but there is  no default definition of orelse for State

# FunctorApplicativeMonad
# =======================

# there is no implementation of foreach for State, as we cannot look into the state function

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

# we cannot overload this generically, because `Base.map(f, ::Vector...)` would get overwritten as well (even without warning surprisingly)
TypeClasses.map(f, a::State, b::State, more::State...) = mapn(f, a, b, more...)


TypeClasses.flatmap(f, a::State) = State() do state0
  value, state1 = a(state0)
  convert(State, f(value))(state1)
end


# FlipTypes
# =========

# flip_types does not makes sense for State, as we cannot evalute the State without running the statefunctions on top
# of a given initial state
