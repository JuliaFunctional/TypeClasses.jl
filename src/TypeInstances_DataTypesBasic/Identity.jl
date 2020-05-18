# MonoidAlternative
# =================

# just forward definitions from wrapped type

@traits TypeClasses.neutral(::Type{Identity{T}}) where {T, isNeutral(T)} = Identity(TypeClasses.neutral(T))
@traits TypeClasses.absorbing(::Type{Identity{T}}) where {T, isAbsorbing(T)} = Identity(TypeClasses.absorbing(T))
@traits TypeClasses.combine(a::Identity, b::Identity) where {isCombine(a.value, b.value)} = Identity(a.value ⊕ b.value)
TypeClasses.orelse(a::Identity, b::Identity) = a  # should return first correct value


# FunctorApplicativeMonad
# =======================

TypeClasses.pure(::Type{<:Identity}, a) = Identity(a)
TypeClasses.ap(f::Identity, a::Identity) = Identity(f.value(a.value))

TypeClasses.flatten(a::Identity) = Iterators.flatten(a)
TypeClasses.flatmap(f, x::Identity) = flatten(map(f, x))


# FlipTypes
# =========

@traits TypeClasses.flip_types(i::Identity) where {isMap(i.value)} = TypeClasses.map(Identity, i.value)
