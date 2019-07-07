# Monoid Instances
# ================

# generic neutral for Dict
neutral(::Traitsof, ::Type{Dict{K, V}}) where {K, V} = Dict{K, V}()

# generic combine/⊕ for Dict
function combine_traits_dict_Combine(traitsof::Traitsof, d1::Dict{K, V1}, d2::Dict{K,V2}) where {K, V1, V2}
  d3 = Dict{K,promote_type(V1, V2)}(d1)
  for (k, v) ∈ d2
    if k ∈ keys(d3)
      d3[k] = combine(traitsof, d3[k], d2[k])
    else
      d3[k] = d2[k]
    end
  end
  d3
end

# we bind this to combine by adding a new traitsof dispatch specific for Dict
function combine(traitsof::Traitsof, d1::Dict{K, V1}, d2::Dict{K,V2}) where {K, V1, V2}
  # this has to follow standard convention of adding traitsof() for all type parameters in order
  # because other package may also use this
  combine_traits_dict(traitsof, d1, d2, traitsof(K), traitsof(promote_type(V1, V2)))
end
function combine_traits_dict(traitsof::Traitsof, d1::Dict{K}, d2::Dict{K}, _, Vtraits::TypeLB(Combine)) where K
  combine_traits_dict_Combine(traitsof, d1, d2)
end

# @traitsof_push! function(traitsof, ::Type{Dict{K,V}}) where K where V
#   if Combine <: traitsof(V)
#     Combine
#   end
# end


# FIter / Functor / Ap / FFlatten instance
# =======================================

feltype(::Traitsof, ::Type{Dict{K,V}}) where {K, V} = V
change_feltype(::Traitsof, ::Type{Dict{K, V}}, ::Type{V2}) where {K, V, V2} = Dict{K, V2}
change_feltype(::Traitsof, ::Type{Dict{K, V} where K}, ::Type{V2}) where {V, V2} = Dict{K, V2} where K
change_feltype(::Traitsof, ::Type{Dict{K, V} where V}, ::Type{K2}) where {K, K2} = Dict{K2, V} where V

change_feltype(::Traitsof, d::Dict{K, V}, ::Type{V2}) where {K, V, V2} = V == V2 ? d : Dict{K, V2}(d)

function fforeach(traitsof::Traitsof, f, d::Dict)
  for (k, v) in d
    f(v)
  end
end


# we follow the implementation in Scala Cats

# overloading is happening via normal julia types dispatch, and not using traits
# hence there not so much a need of giving the function a unique name
# as there won't be many conflicts
function fmap(traitsof::Traitsof, func, d::Dict{K,V}) where {K, V}
  Dict(k => func(v) for (k, v) in d)
end

function ap(traitsof::Traitsof, func::Dict{K}, d::Dict{K,V}) where {K, V}
  Dict(k => func[k](v) for (k, v) ∈ d if k ∈ keys(func))
end

function fflatten(traitsof::Traitsof, d::Dict{K,V}) where V <: Dict{K} where K
  Dict(k => subdict[k] for (k, subdict) ∈ d if k ∈ keys(subdict))
end

# traitsof[Dict] = Union{Functor, Ap, FFlatten}


# Sequence Instance
# =================

function sequence_traits_dict_Ap(traitsof::Traitsof, d::Dict{K,V}) where K where V
  dkeys = collect(keys(d))
  if length(dkeys) == 0
    # Pure is only needed for empty case
    pure(traitsof, V, Dict{K,V}())
  else
    dvalues = (d[k] for k in dkeys)
    function constructor(vs...)
      Dict(zip(dkeys, vs))
    end
    mapn(traitsof, constructor, dvalues...)  # this requires Ap
  end
end

# like for combine we build our default Dict traitsof dispatch
sequence(traitsof::Traitsof, d::Dict{K,V}) where K where V = sequence_traits_dict(traitsof, d, traitsof(K), traitsof(V))
function sequence_traits_dict(traitsof::Traitsof, d::Dict{K,V}, KeyTraits, ValueTraits::TypeLB(Ap)) where K where V
  sequence_traits_dict_Ap(traitsof, d)
end

# TODO add a similar functionality for Combine (like already existing in Sequence)

# @traitsof_push! function(traitsof, ::Type{Dict{K,V}}) where K where V
#   if Ap <: traitsof(V)
#     Sequence
#   end
# end
