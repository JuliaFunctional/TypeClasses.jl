module DataTypes
export IterateEmpty, IterateSingleton, Iterable, Callable, Writer,
  State, getstate, putstate

include("Iterables.jl")
using .Iterables

include("Callable.jl")

include("Writer.jl")

include("States.jl")
using .States
end
