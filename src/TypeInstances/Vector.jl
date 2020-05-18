using TypeClasses
using Traits
using IsDef

# TODO AbstractVector??

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

# flip_types
# ==========

# flip_types follows from applicative and iterable
