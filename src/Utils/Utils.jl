module Utils
export chain, @ifsomething, return_type_FunctionType
using IsDef

# include("unionall_implementationdetails.jl")  # TODO do we need this?

chain(itr...) = Iterators.flatten(itr)
# fix length issue with flatten https://discourse.julialang.org/t/length-iterators-flatten-not-working/22846
Base.length(f::Iterators.Flatten) = sum(length, f.it)


"""
    @ifsomething expr

If `expr` evaluates to `nothing`, equivalent to `return nothing`, otherwise the macro
evaluates to the value of `expr`. Not exported, useful for implementing iterators.
```jldoctest
julia> @ifsomething iterate(1:2)
(1, 1)
julia> let elt, state = IterTools.@ifsomething iterate(1:2, 2); println("not reached"); end
```
"""
macro ifsomething(ex)
    quote
        result = $(esc(ex))
        result === nothing && return nothing
        result
    end
end


function return_type_FunctionType(F, TupleTypeArgs)
  if isdefined(F, :instance)
    IsDef._return_type(F.instance, TupleTypeArgs)
  else
    Any
  end
end

end # module
