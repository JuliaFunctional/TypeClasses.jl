module DataTypes
export FunctorDict, IterateEmpty, IterateSingleton

include("FunctorDicts.jl")
using .FunctorDicts

include("Iterables.jl")
using .Iterables
end
