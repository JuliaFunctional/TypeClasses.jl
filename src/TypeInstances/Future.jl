import Distributed: Future, @spawnat

# Monoid instances
# ================

# this is standard Applicative combine implementation
# there is no other sensible definition for combine and hence if this does fail, it fails correctly
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
# we don't use convert for typesafety, as fetch is more flexible and also enables typechecks
# e.g. this works seamlessly to combine a Task into a Future
TypeClasses.flatmap(f, x::Future) = @spawnat :any fetch(f(fetch(x)))



# FlipTypes
# =========

# does not make much sense as this would need to execute the Future, and map over its returned value,
# creating a bunch dummy Futures within.
