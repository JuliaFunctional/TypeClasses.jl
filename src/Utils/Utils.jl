module Utils
export chain, isiterable, @ifsomething, iterate_named, ∨

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

# alias for promote_type to deal with types more compact
# we choose the symbol for join `∨` because promote_type is kind of a maximum (in type-hierarchy, with Any being the top)
# see https://en.wikipedia.org/wiki/Join_and_meet
@doc raw"""
    TypeA ∨ TypeB = promote_type(TypeA, TypeB)
    ∨(values...) = ∨(typeof.(values)...)

`∨` (latex `\vee`) is alias for `promote_type`.

When called on values, the values will be cast to types via use of `typeof` for convenience.
"""
function ∨ end
T1::Type ∨ T2::Type = promote_type(T1, T2)
∨(Ts::Type...) = promote_type(Ts...)
val1 ∨ val2 = typeof(val1) ∨ typeof(val2)
∨(values...) = ∨(typeof.(values)...)


end # module
