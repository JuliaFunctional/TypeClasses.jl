# DEPRECATED, no longer needed
module Iterables
export IterateEmpty, IterateSingleton

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


#= TODO delete?

# Iterable Wrapper
# ================

"""
wrapper to clearly indicate that something should be treated as an Iterable

also handles element type by using TypeInference on iterate
"""
struct Iterable{ElemType, IterType}
  iter::IterType  # we follow the naming of Base.Generator
  Iterable{ElemType}(iter::IterType) where {ElemType, IterType} = new{ElemType, IterType}(iter)
end
Iterable() = Iterable(IterateEmpty)  # empty iter
Iterable(it::Iterable) = it  # don't nest Iterable wrappers
function Iterable(it)
  tupletype = typediff_Nothing(Core.Compiler.return_type(iterate, Tuple{typeof(it)}))
  if tupletype === Union{}  # only nothing returned
    Iterable{Any}(it)
  else
    # element returned (will always be a Tuple by convention)
    Iterable{tupletype.parameters[1]}(it)
  end
end
Iterable{ET}(it::Iterable) where ET = Iterable{ET}(it.iterable)
unionall_implementationdetails(::Type{Iterable{ET, IT}}) where {ET, IT} = Iterable{ET}


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
# unfortunately this does not seem to be enough for nested inference... not sure what is missing, see https://discourse.julialang.org/t/limits-of-type-inference/22868
function Base.iterate(it::Iterable{T}) where T
  first, state = @ifsomething Base.iterate(it.iter)
  first::T, state
end
function Base.iterate(it::Iterable{T}, state) where T
  next, state = @ifsomething Base.iterate(it.iter, state)
  next::T, state
end

Base.IteratorEltype(::Type{<:Iterable}) = Base.HasEltype()
Base.eltype(::Type{Iterable{T}}) where T = T
Base.eltype(::Type{Iterable}) = Any

Base.IteratorSize(it::Type{Iterable{E, I}}) where {E, I} = Base.IteratorSize(I)  # this is the one reason why I = IterType is included in the type definition
Base.length(it::Iterable) = Base.length(it.iter)
Base.size(it::Iterable) = Base.size(it.iter)
Base.size(it::Iterable, d) = Base.size(it.iter, d)
Base.axes(it::Iterable) = axes(it.iter)  # analog to Base.Generator
Base.ndims(it::Iterable) = ndims(it.iter)


=#

end # module
