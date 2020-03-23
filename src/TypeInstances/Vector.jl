using TypeClasses
using Traits
using IsDef

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

@traits function TypeClasses.map(f, v::Vector)
  # standard map forgets type already with 2 different element types
  # with manual type-inference we can do better
  neweltype = Out(f, eltype(v))
  out = similar(v, neweltype)
  for i in eachindex(v)
    out[i] = f(v[i])
  end
  out
end
@traits TypeClasses.pure(::Type{<:Vector}, a) = [a]
@traits TypeClasses.ap(fs::Vector, v::Vector) = [f(a) for f ∈ fs for a ∈ v]
# TODO this function is not typesafe unfortunately... due to empty Array
@traits TypeClasses.flatten(v::Vector{<:Vector}) = vcat(v...)
@traits function TypeClasses.flatten(v::Vector{Any})
  flatten(fix_type(v))
end


# flip_types
# ==========

# flip_types follows from applicative and iterable

# here only the type-fix
@traits function TypeClasses.flip_types(v::Vector{Any})
  flip_types(fix_type(v))
end


# fix_type
# ========

function TypeClasses.fix_type(v::Vector{Any})
  types = typeof.(v)
  newtype = Union{types...}
  convert(Vector{newtype}, v)
end
