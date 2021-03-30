# TODO add Foldable class to refer to the reduce, foldr, foldl?

module TypeClasses
export Iterable, IterateEmpty, IterateSingleton,
  Callable, Writer,
  State, getstate, putstate,
  neutral, combine, ⊕, reduce_monoid, foldr_monoid, foldl_monoid,
  orelse, ⊛,
  foreach, @syntax_foreach,
  map, @syntax_map,
  pure, ap, curry, mapn, @mapn, sequence, tupled,
  flatten, flatmap, @syntax_flatmap,
  flip_types

# re-export
export @pure

using DataTypesBasic
using Monadic


include("Utils/Utils.jl")
using .Utils

include("DataTypes/DataTypes.jl")
using .DataTypes

# TypeClasses
# ===========
# (they may already include default implementations in terms of other typeclasses)

# we decided for a flat module without submodules to simplify overloading the functions
include("TypeClasses/MonoidAlternative.jl")
include("TypeClasses/FunctorApplicativeMonad.jl")
include("TypeClasses/FlipTypes.jl")  # depends on both Monoid and Applicative
# TODO add Arrow typeclass (composition)


# Instances
# =========

include("TypeInstances/Dict.jl")
include("TypeInstances/Callable.jl")
include("TypeInstances/State.jl")
include("TypeInstances/Iterable.jl")  # only supplies default functions, no actual dispatch is done (Reason: there had been too many conflicts with Dict already)
include("TypeInstances/Pair.jl")
include("TypeInstances/Tuple.jl")
include("TypeInstances/String.jl")
include("TypeInstances/Tuple.jl")
include("TypeInstances/Vector.jl")
include("TypeInstances/Monoid.jl")
include("TypeInstances/Writer.jl")
include("TypeInstances/Task.jl")
include("TypeInstances/Future.jl")

include("TypeInstances_DataTypesBasic/Const.jl")
include("TypeInstances_DataTypesBasic/Identity.jl")
include("TypeInstances_DataTypesBasic/Either.jl")
include("TypeInstances_DataTypesBasic/MultipleExceptions.jl")
include("TypeInstances_DataTypesBasic/ContextManager.jl")

# extra interactions between ContainerTypes
include("convert.jl")
end # module
