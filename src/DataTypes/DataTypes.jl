module DataTypes
export IterateEmpty, IterateSingleton, Iterable, Callable, Writer

include("Iterables.jl")
using .Iterables

include("Callable.jl")

include("Writer.jl")
end
