
"""
    fix_type(value)::ValueWithConcreteElementType

because of possibly inaccurate typeinference on container types like Vector{Any} and Some{Any}
we need to be able to fix types at runtime.

VERY IMPORTANT: To prepend infinite loops, `fix_type` has to return a type very the eltype is no longer `Any`!!!

# Example
```
a = Any[1,2]  # Vector{Any}
fix_type(a) # Vector{Int}
```
"""
fix_type(t) = t
