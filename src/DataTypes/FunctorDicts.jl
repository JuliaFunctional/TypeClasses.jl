module FunctorDicts
export FunctorDict
import ProxyInterface
using StructEquality

struct FunctorDict{K, V}
  dict::Dict{K, V}
end

FunctorDict{K}(dict::Dict{K, V}) where {K, V} = FunctorDict{K, V}(dict)

FunctorDict{K, V}(args...; kwargs...) where {K, V} = FunctorDict{K, V}(Dict{K, V}(args...; kwargs...))
FunctorDict{K}(args...; kwargs...) where {K} = FunctorDict{K}(Dict{K, V}(args...; kwargs...))
FunctorDict(args...; kwargs...) = FunctorDict(Dict(args...; kwargs...))
FunctorDict(d::FunctorDict) = FunctorDict(d.dict)

# retype FunctorDict
FunctorDict{K, V}(d::FunctorDict) where {K, V} = FunctorDict(Dict{K, V}(d.dict))
FunctorDict{K}(d::FunctorDict{<:Any, V}) where {K, V} = FunctorDict(Dict{K, V}(d.dict))


ProxyInterface.dict(d::FunctorDict) = d.dict
ProxyInterface.dict(::Type{<:FunctorDict{T}}) where T = T
ProxyInterface.@dict FunctorDict

ProxyInterface.iterator(d::FunctorDict) = d.dict
ProxyInterface.iterator(::Type{<:FunctorDict{T}}) where T = T
ProxyInterface.@iterator FunctorDict

@def_structequal FunctorDict
end # module
