module DataTypes
export FunctorDict, IterateEmpty, IterateSingleton, Iterable, Callable

include("FunctorDicts.jl")
using .FunctorDicts

include("Iterables.jl")
using .Iterables

include("Callable.jl")
end
