# Monoid instances
# ================

# this is standard Applicative combine implementation, however functions have a too complex type signature
# for the standard implementation to kick in
# hence we reimplement it for more relaxed types
TypeClasses.combine(a::Task, b::Task) = mapn(combine, a, b)
TypeClasses.orelse(a::Task, b::Task) = mapn(orelse, a, b)


# FunctorApplicativeMonad
# =======================

function TypeClasses.foreach(f, x::Task)
  f(fetch(x))
  nothing
end

TypeClasses.map(f, x::Task) = @async f(fetch(x))
TypeClasses.pure(::Type{<:Task}, x) = @async x

# we use the default implementation of ap which follows from flatten
# TypeClasses.ap
TypeClasses.ap(f::Task, x::Task) = @async fetch(f)(fetch(x))
# we don't use convert for typesafety, as fetch is more flexible and also enables typechecks
# e.g. this works seamlessly to combine a Future into a Task
TypeClasses.flatmap(f, x::Task) = @async fetch(f(fetch(x))))



# FlipTypes
# =========

# does not make much sense as this would need to execute the Task, and map over its returned value,
# creating a bunch dummy Tasks within.
