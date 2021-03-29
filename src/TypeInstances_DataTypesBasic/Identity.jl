# MonoidAlternative
# =================

# just forward definitions from wrapped type

TypeClasses.neutral(::Type{Identity{T}}) where {T} = Identity(TypeClasses.neutral(T))
TypeClasses.combine(a::Identity, b::Identity) = Identity(a.value ⊕ b.value)
TypeClasses.orelse(a::Identity, b::Identity) = a  # should return first correct value


# FunctorApplicativeMonad
# =======================

TypeClasses.pure(::Type{<:Identity}, a) = Identity(a)
TypeClasses.ap(f::Identity, a::Identity) = Identity(f.value(a.value))
TypeClasses.flatmap(f, x::Identity) = convert(Identity, f(x.value))


# FlipTypes
# =========

TypeClasses.flip_types(i::Identity) = TypeClasses.map(Identity, i.value)