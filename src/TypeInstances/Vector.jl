using TypeClasses
using Traits

# MonoidAlternative
# =================

@traits TypeClasses.neutral(::Type{<:Vector{A}}) where A = Vector{A}(undef, 0)
@traits TypeClasses.neutral(::Type{<:Vector}) = Vector{Any}(undef, 0)
@traits TypeClasses.combine(v1::Vector, v2::Vector) = [v1; v2]

# FunctorApplicativeMonad
# =======================

@traits TypeClasses.change_eltype(::Type{Array{E1, N}}, ::Type{E2}) where {N, E1, E2} = Array{E2, N}

@traits function TypeClasses.foreach(f, v::Vector)
  for a in v
    f(a)
  end
end

@traits TypeClasses.map(f, v::Vector) = Base.map(f, v)
@traits TypeClasses.pure(::Type{<:Vector}, a) = [a]
@traits TypeClasses.ap(fs::Vector, v::Vector) = [f(a) for f ∈ fs for a ∈ v]
@traits TypeClasses.flatten(v::Vector{<:Vector}) = vcat(v...)


# flip_types
# ==========

# flip_types follows from applicative and iterable
