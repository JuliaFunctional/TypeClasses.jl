using TypeClasses
using Traits
using Traits.BasicTraits: iscallable

# Monoid instances
# ================

@traits TypeClasses.neutral(::typeof(+)) = zero
@traits TypeClasses.neutral(::typeof(*)) = one

_apply(f, x) = f(x)

# Monad instances
# ===============

# there is no general definition for eltype, as this depends on the argument parameters
# @traits eltype(T::Type) where {iscallable(T)} = Out(_apply, T, Any)
@traits TypeClasses.map(f, g) where {iscallable(g)} = (args...; kwargs...) -> f(g(args...; kwargs...))

# @traits TypeClasses.pure(G, a) where {iscallable(G)} = (args...; kwargs...) -> a
@traits TypeClasses.ap(f, g) where {iscallable(g)} = (args...; kwargs...) -> f(args...; kwargs...)(g(args...; kwargs...))
@traits TypeClasses.flatten(g) where {iscallable(g)} = (args...; kwargs...) -> g(args...; kwargs...)(args...; kwargs...)

# FlipTypes instance
# ==================

# there cannot be any flip_types for functions
