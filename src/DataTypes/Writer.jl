using StructEquality
using TypeClasses
using DataTypesBasic

"""
like Pair, however ensures that `combine` is defined for the accumulator `acc`

Note that `neutral` may indeed be undefined
"""
struct Writer{Acc, Value}
  acc::Acc
  value::Value
  function Writer(acc, value)
    @assert isCombine(acc) "The accumulater always has to be combineable"
    new{typeof(acc), typeof(value)}(acc, value)
  end
end

@def_structequal Writer

Base.eltype(::Type{Writer{Acc, T}}) where {Acc, T} = T
Base.eltype(::Type{<:Writer}) = Any
