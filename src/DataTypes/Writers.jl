module Writers
export Writer, getaccumulator

using StructEquality
using TypeClasses
using DataTypesBasic

"""
like Pair, however assumes that `combine` is defined for the accumulator `acc`

Note that `neutral` may indeed be undefined
"""
struct Writer{Acc, Value}
  acc::Acc
  value::Value
  function Writer(acc, value=nothing)
    new{typeof(acc), typeof(value)}(acc, value)
  end
end

@struct_hash_equal Writer

"""
    getaccumulator(writer::Writer)

Returns the accumulator of the Writer value.


Examples
--------

```jldoctest
julia> using TypeClasses

julia> getaccumulator(Writer("example-accumulator"))
"example-accumulator"
```
"""
getaccumulator(writer::Writer) = writer.acc
Base.get(writer::Writer) = writer.value
Base.getindex(writer::Writer) = writer.value


Base.eltype(::Type{Writer{Acc, T}}) where {Acc, T} = T
Base.eltype(::Type{<:Writer}) = Any

end  # module