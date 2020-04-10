using TypeClasses
using IsDef
using Traits
import FunctionWrappers: FunctionWrapper

# TODO we encountered a couple of bad Errors, because this generically goes on all callable types, which still are
# too many it seems. We can do the same as for Iterable and provide a Callable wrapper

# Monoid instances
# ================


# this is standard Applicative combine implementation, however functions have a too complex type signature
# for the standard implementation to kick in
# hence we reimplement it for more relaxed types
TypeClasses.combine(a::Callable, b::Callable) = mapn(⊕, a, b)


# Monad instances
# ===============

# there is no general definition for eltype, as this depends on the argument parameters
# but for FunctionWrapper it is possible
TypeClasses.eltype(T::Type{Callable{FunctionWrapper{Return, Args}}}) where {Return, Args} = Return

TypeClasses.map(f, g::Callable) = Callable((args...; kwargs...) -> f(g(args...; kwargs...)))

TypeClasses.change_eltype(T::Callable, Elem) = Callable{FunctionWrapper{Elem, Tuple}}

TypeClasses.pure(::Type{<:Callable}, a) = (args...; kwargs...) -> a
TypeClasses.ap(f::Callable, g::Callable) = Callable((args...; kwargs...) -> f(args...; kwargs...)(g(args...; kwargs...)))
TypeClasses.flatten(g::Callable) = Callable((args...; kwargs...) -> g(args...; kwargs...)(args...; kwargs...))


# FlipTypes instance
# ==================

# there cannot be any flip_types for functions
