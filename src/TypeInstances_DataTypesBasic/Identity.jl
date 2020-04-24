# MonoidAlternative
# =================

# just forward definitions from wrapped type

@traits TypeClasses.neutral(::Type{Identity{A}}) where {A, isNeutral(A)} = Identity(TypeClasses.neutral(A))
@traits TypeClasses.absorbing(::Type{Identity{A}}) where {A, isAbsorbing(A)} = Identity(TypeClasses.absorbing(A))
@traits TypeClasses.combine(a::Identity{T}, b::Identity{T}) where {T, isCombine(T)} = Identity(a.value ⊕ b.value)
@traits TypeClasses.orelse(a::Identity{T}, b::Identity{T}) where {T, isOrElse(T)} = Identity(orelse(a.value, b.value))


# FunctorApplicativeMonad
# =======================

@traits TypeClasses.pure(::Type{<:Identity}, a) = Identity(a)
@traits TypeClasses.ap(f::Identity, a::Identity) = Identity(f.value(a.value))

TypeClasses.flatmap(f, x::Identity) = flatten(map(f, x))
TypeClasses.flatten(a::Identity) = Iterators.flatten(a)


# FlipTypes
# =========

@traits TypeClasses.flip_types(i::Identity) where {isMap(i.value)} = TypeClasses.map(Identity, i.value)
