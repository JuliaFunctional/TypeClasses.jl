module States
export State, getstate, putstate

"""
    State(func)

    State() do state
      ....
      return value, newstate
    end

State monad, which capsulate a state within a monadic type for monadic encapsulation of the state-handling.

You can run a state by either calling it, or by using `Base.run`. If no initial state is given, `nothing` is used.
"""
struct State{T}
  "s -> (a, s)"
  func::T
end

# running a State
function (s::State)(state = nothing)
  s.func(state)
end
Base.run(state::State, initial_state = nothing) = state(initial_state)


@doc raw"""
    getstate

Standard value for returning the hidden state of the `State` Monad.

Examples
--------

```jldoctest
julia> using TypeClasses

julia> mystate = @syntax_flatmap begin
         state = getstate
         @pure println("state = $state")
       end;

julia> mystate(42)
state = 42
(nothing, 42)
```
"""
const getstate = State() do state
  state, state
end

@doc raw"""
    putstate(x)

`putstate` is a standard constructor for `State` objects which changes the underlying state to the given value. 


Examples
--------

```jldoctest
julia> using TypeClasses

julia> mystate = @syntax_flatmap begin
         putstate(10)
         state = getstate
         @pure println("The state is $state, and should be 10")
       end;

julia> mystate()
The state is 10, and should be 10
(nothing, 10)
```
"""
putstate(x) = State() do state
  (), x
end

end # module
