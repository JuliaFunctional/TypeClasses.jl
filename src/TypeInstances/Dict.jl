using TypeClasses
using Traits

# Monoid Instances for standard Dict
# ===================================

# generic neutral for Dict
@traits TypeClasses.neutral(::Type{Dict{K, V}}) where {K, V} = Dict{K, V}()

# generic combine/⊕ for Dict
@traits TypeClasses.combine(d1::Dict, d2::Dict) = merge(d1, d2)



# Monoid Instances for FunctorDict
# ================================

# generic neutral for Dict
@traits TypeClasses.neutral(::Type{FunctorDict{K, V}}) where {K, V} = FunctorDict{K, V}()

# generic combine/⊕ for Dict
@traits function TypeClasses.combine(d1::FunctorDict{K, V1}, d2::FunctorDict{K, V2}) where {K, V1, V2, isCombine(promote_type(V1, V2))}
  d1′ = d1.dict
  d2′ = d2.dict
  d3′ = Dict{K, promote_type(V1, V2)}(d1′)
  for (k, v) ∈ d2′
    if k ∈ keys(d3′)
      d3′[k] = TypeClasses.combine(d3′[k], d2′[k])
    else
      d3′[k] = d2′[k]
    end
  end
  FunctorDict(d3′)
end


# FIter / Functor / Ap / FFlatten instance
# =======================================

@traits TypeClasses.eltype(::Type{FunctorDict{K,V}}) where {K, V} = V
@traits TypeClasses.eltype(::Type{<:FunctorDict}) = Any
@traits TypeClasses.change_eltype(::Type{<:FunctorDict{K}}, ::Type{V}) where {K, V} = Dict{K, V}

@traits function TypeClasses.foreach(f, d::FunctorDict)
  for (k, v) in d.dict
    f(v)
  end
end


# we follow the implementation in Scala Cats

# overloading is happening via normal julia types dispatch, and not using traits
# hence there not so much a need of giving the function a unique name
# as there won't be many conflicts
@traits function TypeClasses.map(func, d::FunctorDict)
  FunctorDict(Dict(k => func(v) for (k, v) in d.dict))
end

@traits function TypeClasses.ap(func::FunctorDict{K}, d::FunctorDict{K}) where {K}
  FunctorDict(k => func[k](v) for (k, v) ∈ d.dict if k ∈ keys(func))
end

@traits function TypeClasses.flatten(d::FunctorDict{K,V}) where {K, V <: FunctorDict{K}}
  FunctorDict(k => subdict[k] for (k, subdict) ∈ d.dict if k ∈ keys(subdict))
end


# FlipTypes Instance
# ==================

@traits function TypeClasses.flip_types(d::FunctorDict{K,V}) where {K, V, isAp(V)}
  dkeys = collect(keys(d))
  if length(dkeys) == 0
    # Pure is only needed for empty case, hence we don't dispatch on it
    # we could alternatively dispatch on length(keys(d)), however this would be a runtime-dispatch
    TypeClasses.pure(V, FunctorDict{K,V}())
  else
    dvalues = (d[k] for k in dkeys)
    function constructor(vs...)
      FunctorDict(zip(dkeys, vs))
    end
    TypeClasses.mapn(constructor, dvalues...)  # this requires Ap
  end
end
