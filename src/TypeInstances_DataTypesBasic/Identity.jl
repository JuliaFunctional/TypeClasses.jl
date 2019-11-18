# MonoidAlternative
# =================

# just forward definitions from wrapped type

TypeClasses.neutral(traitsof::Traitsof, ::Type{Identity{A}}) where A = Identity(TypeClasses.neutral(traitsof, A))

TypeClasses.absorbing(traitsof::Traitsof, ::Type{Identity{A}}) where A = Identity(TypeClasses.absorbing(traitsof, A))

TypeClasses.combine(traitsof::Traitsof, a::Identity{T}, b::Identity{T}) where T = Identity(TypeClasses.combine(traitsof, a.value, b.value))

TypeClasses.orelse(traitsof::Traitsof, a::Identity{T}, b::Identity{T}) where T = Identity(TypeClasses.orelse(traitsof, a.value, b.value))


# FunctorApplicativeMonad
# =======================

TypeClasses.fmap(traitsof::Traitsof, f, a::Identity) = Identity(f(a.value))
TypeClasses.pure(traitsof::Traitsof, ::Type{<:Identity}, a) = Identity(a)
TypeClasses.ap(traitsof::Traitsof, f::Identity, a::Identity) = Identity(f.value(a.value))
TypeClasses.fflatten(traitsof::Traitsof, a::Identity) = a.value

# relaxed flatten definition
# --------------------------

# Identity is just a Singleton, hence can be flattened out everywhere
function fflatten_traits_Functor_Identity(traitsof::Traitsof, a)
  TypeClasses.fmap(traitsof, b -> v.value, a)
end

TypeClasses.fflatten_traits_Functor(traitsof::Traitsof, a, B::Type{<:Identity}, _, _) = fflatten_traits_Functor_Identity(traitsof, a)

# Sequence
# ========

TypeClasses.sequence(traitsof::Traitsof, i::Identity{A}) where A = TypeClasses.fmap(traitsof, Identity, i.value)
