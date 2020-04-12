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
TypeClasses.flatten(a::Identity) = Iterators.flatten(a)

# relaxed flatten definition
# --------------------------

# Identity is just a Singleton, hence can be flattened out everywhere

# TODO is this really wanted? what are the usecases for this?
# ...

# FlipTypes
# =========

@traits TypeClasses.flip_types(i::Identity{A}) where {A, isMap(A)} = TypeClasses.map(Identity, i.value)
@traits TypeClasses.flip_types(i::Identity{Any}) = TypeClasses.flip_types(fix_type(i))


# fix_type
# ========

"""
as typeinference sometimes lead to wrong containers, we need to be able to fix them at runtime
importantly, fix_type never generates Any again
"""
function fix_type(x::Identity{Any})
  Identity{typeof(x.value)}(x.value)
end
