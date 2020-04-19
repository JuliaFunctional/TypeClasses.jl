module DataTypes
export IterateEmpty, IterateSingleton, Iterable, Callable, Writer,
  State, Get, Put

include("Iterables.jl")
using .Iterables

include("Callable.jl")

include("Writer.jl")

include("State.jl")
end
