module States
export State, getstate, putstate

"""
defining state monad, which capsulate a state within a monadic type
"""
struct State{T}
  "s -> (a, s)"
  func::T
end
function (s::State)(state)
  s.func(state)
end

getstate = State() do state
  state, state
end

putstate(x) = State() do state
  (), x
end
end # module
