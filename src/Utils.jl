module Utils
export @create_default, chain, @ifsomething, typediff_Nothing

typediff_Nothing(u::Union) = u.a === Nothing ? typediff_Nothing(u.b) : Union{u.a, typediff_Nothing(u.b)}
typediff_Nothing(t::Type) = t

macro create_default(funcname::Symbol)
  funcname_default = Symbol(funcname, "_default")
  esc(quote
    function $funcname_default end  # this definition is important to get descriptive errors if something is not defined at all
    $funcname(args...; kwargs...) = $funcname_default(args...; kwargs...)
  end)
end

chain(itr...) = Iterators.flatten(itr)
# fix length issue with FFlatten https://discourse.julialang.org/t/length-iterators-flatten-not-working/22846
Base.length(f::Iterators.Flatten) = sum(length, f.it)

"""
    IterTools.@ifsomething expr
If `expr` evaluates to `nothing`, equivalent to `return nothing`, otherwise the macro
evaluates to the value of `expr`. Not exported, useful for implementing iterators.
```jldoctest
julia> IterTools.@ifsomething iterate(1:2)
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

end # module
