# FunctorApplicativeMonad
# =======================

TypeClasses.pure(::Type{<:ContextManager}, x) = @ContextManager cont -> cont(x)

# we use the default implementation of ap which follows from flatten
# TypeClasses.ap
TypeClasses.ap(f::ContextManager, a::ContextManager) = TypeClasses.default_ap_having_map_flatmap(f, a)

TypeClasses.flatten(c::ContextManager) = Iterators.flatten(c)


# FlipTypes
# =========

# does not make much sense as if I would flip_types ContextManager, I need to evaluate the context
# hence I could directly flatten instead
