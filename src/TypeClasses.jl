# TODO add Foldable class to refer to the reduce, foldr, foldl

module TypeClasses
# we export only Types and special helpers which do not depend on traitsof
# all functionalities which depend on traitsof are collected into `traitsof_linkall` below
export FunctorDict,
  neutral, combine, ⊕, isNeutral, isCombine, isSemigroup, isMonoid, reduce, foldr, foldr,
  absorbing, orelse, ⊛, isAbsorbing, isOrElse, isAlternative,
  foreach, isForeach, @syntaxforeach,
  map, isFunctor, @syntax_map,
  pure, ap, isPure, isAp, isApplicative, curry, mapn, isMapN,
  flatten, isFlatten, isMonad, @pure, @syntax_flatmap, @syntax_flattenrec,
  flip_types, isFlipTypes,
  # Iterable, # special wrapper for Iterate to support TypeClasses on them
  unionall_implementationdetails  # special helper to get a generic type from a possible too concrete type

using Traits
using Suppressor: @suppress, @suppress_err, @suppress_out  # this is to surpress unnecessary method overwritten warnings

"""
  macro to import all functionality as using

this includes const values for those which are both in Base and TypeClasses
"""
macro overwrite_Base()
  esc(quote
    # MonoidAlternative
    const reduce = TypeClasses.reduce
    const foldr = TypeClasses.foldr
    const foldl = TypeClasses.foldl
    # FunctorApplicativeMonad
    const foreach = TypeClasses.foreach
    const map = TypeClasses.map
    const eltype = TypeClasses.eltype
    nothing  # for invisible output
  end)
end


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


# Instances
# =========

include("TypeInstances/Dict.jl")
include("TypeInstances/Function.jl")
include("TypeInstances/Iterable.jl")  # only supplies default functions, no actual dispatch is done (Reason: there had been too many conflicts with Dict already)
include("TypeInstances/Pair.jl")
include("TypeInstances/Tuple.jl")
include("TypeInstances/String.jl")
include("TypeInstances/Vector.jl")
include("TypeInstances/Vector.jl")


# DataTypesBasic
# TODO

end # module
