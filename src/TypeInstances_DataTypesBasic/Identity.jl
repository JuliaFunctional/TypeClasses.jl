# MonoidAlternative
# =================

# we don't define a Identity-only TypeClasses.neutral
# this could interfere with the more generic neutral definition within `Either` (every Const is neutral towards Identity)

# for convenience we forward Monoid definitions from the wrapped type
TypeClasses.combine(a::Identity, b::Identity) = Identity(a.value ⊕ b.value)

# Identity denotes success, and first success wins
TypeClasses.orelse(a::Identity, b::Identity) = a


# FunctorApplicativeMonad
# =======================

TypeClasses.pure(::Type{<:Identity}, a) = Identity(a)
TypeClasses.ap(f::Identity, a::Identity) = Identity(f.value(a.value))
# for convenience, Identity does not use convert, whatever monad is returned is valid, providing maximum flexibility.
TypeClasses.flatmap(f, a::Identity) = f(a.value)


# FlipTypes
# =========

TypeClasses.flip_types(a::Identity) = TypeClasses.map(Identity, a.value)