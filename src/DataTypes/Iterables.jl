# DEPRECATED, no longer needed
module Iterables
export IterateEmpty, IterateSingleton, Iterable
import ProxyInterface
using DataTypesBasic
@overwrite_Some
using Traits
import Traits.BasicTraits: isiterable

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

ProxyInterface.iterator(::Type{Iterable{IterT}}) where {IterT} = IterT
ProxyInterface.iterator(it::Iterable) = it.iter
ProxyInterface.@iterator Iterable

Base.map(f, it::Iterable) = Iterable(f(x) for x ∈ it.iter)
# generic convert method
@traits Base.convert(::Type{<:Iterable}, x) where {isiterable(x)} = Iterable(x)

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
