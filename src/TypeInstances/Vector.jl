
using TypeClasses

# TODO AbstractVector??
TypeClasses.isNeutral(::Type{<:Vector}) = true
TypeClasses.isCombine(::Type{<:Vector}) = true
TypeClasses.isPure(::Type{<:Vector}) = true
TypeClasses.isAp(::Type{<:Vector}) = true
TypeClasses.isFlatMap(::Type{<:Vector}) = true
TypeClasses.isFlipTypes(::Type{<:Vector}) = true

# MonoidAlternative
# =================

TypeClasses.neutral(::Type{<:Vector{A}}) where A = Vector{A}(undef, 0)
TypeClasses.neutral(::Type{<:Vector}) = Vector{Any}(undef, 0)
TypeClasses.combine(v1::Vector, v2::Vector) = [v1; v2]

# FunctorApplicativeMonad
# =======================

TypeClasses.pure(::Type{<:Vector}, a) = [a]
TypeClasses.ap(fs::Vector, v::Vector) = [f(a) for f ∈ fs for a ∈ v]
# for flattening we solve type-safety by converting to Vector elementwise
# this also gives well-understandable error messages if something goes wrong
TypeClasses.flatmap(f, v::Vector) = vcat((convert(Vector, f(x)) for x in v)...)


# FlipTypes
# =========

# we define flip_types for all Vector despite it only works if the underlying element defines `ap`
# as there is no other sensible definition for Iterable, an error that the element does not implement `ap`
# is actually the correct error
flip_types(v::Vector) = default_flip_types_having_pure_combine_apEltype(v)
