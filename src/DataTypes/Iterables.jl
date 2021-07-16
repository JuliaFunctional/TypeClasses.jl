# DEPRECATED, no longer needed
module Iterables
export IterateEmpty, IterateSingleton, Iterable
import ProxyInterfaces
using DataTypesBasic
using TypeClasses.Utils


# Iterable Wrapper
# ================

# TODO get rid of TypeTag ElemType
"""
wrapper to clearly indicate that something should be treated as an Iterable
"""
struct Iterable{IterType}
  iter::IterType  # we follow the naming of Base.Generator
end
Iterable() = Iterable(IterateEmpty())  # empty iter
Iterable(it::Iterable) = it  # don't nest Iterable wrappers

ProxyInterfaces.iterator(::Type{Iterable{IterT}}) where {IterT} = IterT
ProxyInterfaces.iterator(it::Iterable) = it.iter
ProxyInterfaces.@iterator Iterable  # includes map

# generic convert method
Base.convert(::Type{Iterable{T}}, x::Iterable{T}) where T = x
function Base.convert(::Type{<:Iterable}, x)
  @assert(isiterable(x), "Only iterables can be converted to Iterable, please overload `Base.isiterable` respectively")
  Iterable(x)
end



# Iterable Helpers
# ================

struct IterateEmpty{ElType} end
# Union{} makes most sense as default type, as it has no element at all
# also typeinference should work correctly as `promote_type(Union{}, Int) == Int`
IterateEmpty() = IterateEmpty{Union{}}()

Base.iterate(::IterateEmpty) = nothing

Base.IteratorSize(::Type{<:IterateEmpty}) = Base.HasLength()
Base.length(::IterateEmpty) = 0
Base.IteratorEltype(::Type{<:IterateEmpty}) = Base.HasEltype()
Base.eltype(::Type{IterateEmpty{T}}) where T = T


struct IterateSingleton{T}
  value::T
end
Base.iterate(iter::IterateSingleton) = iter.value, nothing
Base.iterate(iter::IterateSingleton, state) = nothing

Base.IteratorSize(::Type{<:IterateSingleton}) = Base.HasLength()
Base.length(::IterateSingleton) = 1
Base.IteratorEltype(::Type{<:IterateSingleton}) = Base.HasEltype()
Base.eltype(::Type{IterateSingleton{T}}) where T = T

end # module
