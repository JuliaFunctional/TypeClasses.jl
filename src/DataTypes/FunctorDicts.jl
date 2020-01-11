module FunctorDicts
export FunctorDict
import ProxyInterface

struct FunctorDict{K, V}
  dict::Dict{K, V}
  FunctorDict{K, V}(dict::Dict{K, V}) where {K, V} = new{K, V}(dict)
end
FunctorDict{K}(dict::Dict{K, V}) where {K, V} = new{K, V}(dict)
FunctorDict(dict::Dict{K, V}) where {K, V} = new{K, V}(dict)

FunctorDict{K, V}(args...; kwargs...) where {K, V} = FunctorDict{K, V}(Dict{K, V}(args...; kwargs...))
FunctorDict{K}(args...; kwargs...) where {K} = FunctorDict{K}(Dict{K, V}(args...; kwargs...))
FunctorDict(args...; kwargs...) = FunctorDict(Dict(args...; kwargs...))

ProxyInterface.dict(d::FunctorDict) = d.dict
ProxyInterface.dict(::Type{FunctorDict{T}}) where T = T
ProxyInterface.@dict FunctorDict

end # module
