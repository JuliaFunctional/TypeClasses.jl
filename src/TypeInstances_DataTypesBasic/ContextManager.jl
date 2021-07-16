# FunctorApplicativeMonad
# =======================

TypeClasses.pure(::Type{<:ContextManager}, x) = @ContextManager cont -> cont(x)

TypeClasses.flatmap(f, x::ContextManager) = flatten(map(f, x))
TypeClasses.flatten(c::ContextManager) = Iterators.flatten(c)


# we cannot overload this generically, because `Base.map(f, ::Vector...)` would get overwritten as well (even without warning surprisingly)
# hence we do it individually for ContextManager
Base.map(f, a::ContextManager, b::ContextManager, more::ContextManager...) = mapn(f, a, b, more...)


# FlipTypes
# =========

# does not make much sense as if I would flip_types ContextManager, I need to evaluate the context
# hence I could directly flatten instead
