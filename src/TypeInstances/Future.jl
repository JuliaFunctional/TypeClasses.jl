import Distributed: Future, @spawnat

# Monoid instances
# ================

# this is standard Applicative combine implementation, however functions have a too complex type signature
# for the standard implementation to kick in
# hence we reimplement it for more relaxed types
TypeClasses.combine(a::Future, b::Future) = mapn(combine, a, b)
TypeClasses.orelse(a::Future, b::Future) = mapn(orelse, a, b)


# FunctorApplicativeMonad
# =======================

function TypeClasses.foreach(f, x::Future)
  f(fetch(x))
  nothing
end

TypeClasses.map(f, x::Future) = @spawnat :any f(fetch(x))
TypeClasses.pure(::Type{<:Future}, x) = @spawnat :any x

# we use the default implementation of ap which follows from flatten
# TypeClasses.ap
TypeClasses.ap(f::Future, x::Future) = @spawnat :any fetch(f)(fetch(x))
# Note that there is no way for a Task to know its eltype
TypeClasses.flatten(x::Future) = @spawnat :any fetch(fetch(x))



# FlipTypes
# =========

# does not make much sense as this would need to execute the Future, and map over its returned value,
# creating a bunch dummy Futures within.
