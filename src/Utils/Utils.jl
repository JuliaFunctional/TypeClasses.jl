module Utils
export chain, isiterable, @ifsomething, iterate_named

# include("unionall_implementationdetails.jl")  # TODO do we need this?

chain(itr...) = Iterators.flatten(itr)

isiterable(value) = isiterable(typeof(value))
isiterable(type::Type) = Base.isiterable(type)


"""
    @ifsomething expr

If `expr` evaluates to `nothing`, equivalent to `return nothing`, otherwise the macro
evaluates to the value of `expr`. Not exported, useful for implementing iterators.
```jldoctest
julia> using TypeClasses.Utils

julia> @ifsomething iterate(1:2)
(1, 1)
julia> let elt, state = @ifsomething iterate(1:2, 2); println("not reached"); end
```
"""
macro ifsomething(ex)
  quote
    result = $(esc(ex))
    result === nothing && return nothing
    result
  end
end

"""
    result = iterate_named(iterable)
    result = iterate_named(iterable, state)

Exactly like `iterate`, with the addition that you can use `result.value` in addition to 'result[1]'
and `result.state` for `result[2]`. It will return a named tuple respectively if not nothing, hence also the name.

Can be used instead of `iterate`.

```jldoctest
julia> using TypeClasses.Utils

julia> iterate_named(["one", "two"])
(value = "one", state = 2)
```
"""
function iterate_named(iter, state...)
  value, state′ = @ifsomething iterate(iter, state...)
  (value=value, state=state′)
end


end # module
