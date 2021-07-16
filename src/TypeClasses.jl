# TODO add Foldable class to refer to the reduce, foldr, foldl?

module TypeClasses
export neutral, combine, ⊕, reduce_monoid, foldr_monoid, foldl_monoid,
  orelse, ⊘,
  foreach, @syntax_foreach,
  map, @syntax_map,
  pure, ap, curry, mapn, @mapn, tupled, neutral_applicative, combine_applicative, orelse_applicative,
  flatmap, flatten, ↠, @syntax_flatmap,
  flip_types

using Compat
using Reexport
using Requires

using Monadic
export @pure  # a user only needs @pure from Monadi

@reexport using DataTypesBasic

include("Utils/Utils.jl")
using .Utils

include("DataTypes/DataTypes.jl")
@reexport using .DataTypes

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

include("TypeInstances/AbstractVector.jl")
include("TypeInstances/Callable.jl")
include("TypeInstances/Dict.jl")
include("TypeInstances/Future.jl")
include("TypeInstances/Iterable.jl")  # only supplies default functions, no actual dispatch is done (Reason: there had been too many conflicts with Dict already)
include("TypeInstances/Monoid.jl")
include("TypeInstances/Pair.jl")
include("TypeInstances/State.jl")
include("TypeInstances/String.jl")
include("TypeInstances/Task.jl")
include("TypeInstances/Tuple.jl")
include("TypeInstances/Writer.jl")

include("TypeInstances_DataTypesBasic/Const.jl")
include("TypeInstances_DataTypesBasic/Identity.jl")
include("TypeInstances_DataTypesBasic/Either.jl")
include("TypeInstances_DataTypesBasic/MultipleExceptions.jl")
include("TypeInstances_DataTypesBasic/ContextManager.jl")

# extra interactions between ContainerTypes
include("convert.jl")

function __init__()
  # there are known issues with require. See this issue for updates https://github.com/JuliaLang/Pkg.jl/issues/1285
  @require Dictionaries="85a47980-9c8c-11e8-2b9f-f7ca1fa99fb4" include("TypeInstances/AbstractDictionary.jl")
end

end # module
