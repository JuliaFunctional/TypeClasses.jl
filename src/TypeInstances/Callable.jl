using TypeClasses


# Monoid instances
# ================

# this is standard Applicative combine implementation
# there is no other sensible definition for combine and hence if this does fail, it fails correctly
TypeClasses.combine(a::Callable, b::Callable) = mapn(combine, a, b)
TypeClasses.orelse(a::Callable, b::Callable) = mapn(orelse, a, b)

# it is not possible to implement neutral, as we do not know the element type without executing the function


# Monad instances
# ===============

# there is no definition for Base.foreach, as a callable is not runnable without knowing the arguments
TypeClasses.map(f, g::Callable) = Callable((args...; kwargs...) -> f(g(args...; kwargs...)))

TypeClasses.pure(::Type{<:Callable}, a) = (args...; kwargs...) -> a
TypeClasses.ap(f::Callable, g::Callable) = Callable((args...; kwargs...) -> f(args...; kwargs...)(g(args...; kwargs...)))
# we don't use convert, but directly use function call,
# which should give readable errors that a something is not callable, and is a bit more flexible
TypeClasses.flatmap(f, g::Callable) = Callable((args...; kwargs...) -> f(g(args...; kwargs...))(args...; kwargs...))


# FlipTypes instance
# ==================

# there cannot be any flip_types for functions
