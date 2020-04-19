# TODO add Foldable class to refer to the reduce, foldr, foldl?

module TypeClasses
export Iterable, IterateEmpty, IterateSingleton,
  Callable, Writer,
  State, getstate, putstate,
  neutral, combine, ⊕, isNeutral, isCombine, isSemigroup, isMonoid, reduce_monoid, foldr_monoid, foldl_monoid,
  absorbing, orelse, ⊛, isAbsorbing, isOrElse, isAlternative,
  foreach, isForeach, @syntax_foreach,
  map, isMap, isFunctor, @syntax_map, eltype, isEltype, change_eltype, ⫙,
  pure, ap, isPure, isAp, isMapN, isApplicative, curry, gmapn, mapn, @mapn, sequence, tupled,
  flatten, isFlatten, flatmap, isMonad, @pure, @syntax_flatmap,
  flip_types, isFlipTypes,
  fix_type

using Traits
using DataTypesBasic
DataTypesBasic.@overwrite_Some


include("Utils/Utils.jl")
using .Utils

include("DataTypes/DataTypes.jl")
using .DataTypes

# TypeClasses
# ===========
# (they may already include default implementations in terms of other typeclasses)

# we decided for a flat module without submodules to simplify overloading the functions
include("TypeClasses/fix_type.jl")
include("TypeClasses/MonoidAlternative.jl")
include("TypeClasses/FunctorApplicativeMonad.jl")
include("TypeClasses/FlipTypes.jl")  # depends on both Monoid and Applicative


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
include("TypeInstances_DataTypesBasic/ContextManager.jl")
include("TypeInstances_DataTypesBasic/Either.jl")
include("TypeInstances_DataTypesBasic/Flatten.jl")
include("TypeInstances_DataTypesBasic/Identity.jl")
include("TypeInstances_DataTypesBasic/Option.jl")
include("TypeInstances_DataTypesBasic/Try.jl")

end # module
