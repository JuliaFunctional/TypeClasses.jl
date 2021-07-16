module DataTypes
export Iterable, Callable, 
  Writer, getaccumulator,
  State, getstate, putstate

include("Iterables.jl")
using .Iterables

include("Callable.jl")

include("Writers.jl")
using .Writers

include("States.jl")
using .States
end
