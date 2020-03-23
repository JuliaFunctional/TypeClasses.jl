# DEPRECATED, no longer needed
module Iterables
export IterateEmpty, IterateSingleton, Iterable
using TypeClasses.Utils
using Traits
import ProxyInterface
using IsDef

struct IterateEmpty{ElType} end
IterateEmpty() = IterateEmpty{Any}()

Base.iterate(::IterateEmpty) = nothing

Base.IteratorSize(::Type{<:IterateEmpty}) = Base.HasLength()
Base.length(::IterateEmpty) = 0
Base.IteratorEltype(::Type{IterateEmpty{T}}) where T = T


struct IterateSingleton{T}
  value::T
end
Base.iterate(iter::IterateSingleton) = iter.value, nothing
Base.iterate(iter::IterateSingleton, state) = nothing

Base.IteratorSize(::Type{IterateSingleton{T}}) where T = Base.HasLength()
Base.length(::IterateSingleton) = 1
Base.IteratorEltype(::Type{IterateSingleton{T}}) where T = Base.HasEltype()
Base.eltype(::Type{IterateSingleton{T}}) where T = T


# Iterable Wrapper
# ================

# TODO get rid of TypeTag ElemType
"""
wrapper to clearly indicate that something should be treated as an Iterable

also handles element type by using TypeInference on iterate
"""
struct Iterable{ElemType, IterType}
  iter::IterType  # we follow the naming of Base.Generator
  Iterable{ElemType}(iter::IterType) where {ElemType, IterType} = new{ElemType, IterType}(iter)
end
ProxyInterface.iterator(::Type{Iterable{ElemT, IterT}}) where {ElemT, IterT} = IterT
ProxyInterface.iterator(it::Iterable) = it.iter

function Iterable(it::T) where T
  if Base.IteratorEltype(it) isa Base.HasEltype
    Iterable{eltype(T)}(it)
  else
    # we try automatic type inference
    # because for instance ``eltype(i for i in 1:3)`` already does not work without
    Iterable{Out(Base.first, T)}(it)
  end
end
Iterable() = Iterable(IterateEmpty())  # empty iter
Iterable{ElemT}() where ElemT = Iterable{ElemT}(IterateEmpty{ElemT}())
Iterable(it::Iterable) = it  # don't nest Iterable wrappers
Iterable{ET}(it::Iterable) where ET = Iterable{ET}(it.iter) # switch typetag easily

#=
# the following special cases are no longer needed for typeinference as Julia's inference on iterate is strong enough
function Iterable(it::Base.Generator{I, F}) where {I, F}  # type-support for standard iterator
  E = Core.Compiler.return_type(it.f, Tuple{eltype(I)})
  Iterable{E}(it)
end
Iterable(it::Iterators.Flatten{I}) where I = Iterable{eltype(eltype(I))}(it)
Iterable(it::Vector{T}) where T = Iterable{T}(it)
Iterable(it::AbstractRange{T}) where T = Iterable{T}(it)
Iterable(iter::IterateSingleton{T}) where T = Iterable{T}(iter)  # singleton iter
=#

# pass through whole iterator interface https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-iteration-1

Base.iterate(it::Iterable) = Base.iterate(it.iter)
Base.iterate(it::Iterable, state) = Base.iterate(it.iter, state)

#= Typed Versions of iterate
# we don't use these right now because the cast is a big overhead for fast iterators
# and the tag

function Base.iterate(it::Iterable{T}) where T
  first, state = @ifsomething Base.iterate(it.iter)
  first::T, state
end
function Base.iterate(it::Iterable{T}, state) where T
  next, state = @ifsomething Base.iterate(it.iter, state)
  next::T, state
end
=#

Base.IteratorEltype(::Type{<:Iterable}) = Base.HasEltype()
Base.eltype(::Type{Iterable{T}}) where T = T
Base.eltype(::Type{Iterable}) = Any

Base.IteratorSize(it::Type{Iterable{E, I}}) where {E, I} = Base.IteratorSize(I)  # this is the one reason why I = IterType is included in the type definition
Base.length(it::Iterable) = Base.length(it.iter)
Base.size(it::Iterable) = Base.size(it.iter)
Base.size(it::Iterable, d) = Base.size(it.iter, d)
Base.axes(it::Iterable) = Base.axes(it.iter)  # analog to Base.Generator
Base.ndims(it::Iterable) = Base.ndims(it.iter)

end # module
