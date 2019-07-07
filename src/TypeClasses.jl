# TODO add Foldable class to refer to the reduce, foldr, foldl

module TypeClasses
# we export only Types and special helpers which do not depend on traitsof
# all functionalities which depend on traitsof are collected into `traitsof_linkall` below
export
  Neutral, Combine, Semigroup, Monoid, Absorbing, OrElse, Alternative,
  FForeach, @syntax_fforeach,
  Functor, FMap, FEltype, ChangeFEltype, @syntax_fmap,
  Pure, Ap, Applicative, curry,
  FFlatten, Monad, @pure, @syntax_fflatmap, @syntax_fmap_fflattenrec,
  Sequence,
  Iterable, # special wrapper for Iterate to support TypeClasses on them
  unionall_implementationdetails  # special helper to get a generic type from a possible too concrete type

using Traits
using Traits.BasicTraits
using Suppressor: @suppress, @suppress_err, @suppress_out  # this is to surpress unnecessary method overwritten warnings

# Helpers
# =======

include("Utils.jl")
using .Utils
include("unionall_implementationdetails.jl")
include("Iterable.jl")

@traitsof_init(traitsof_basic)


# TypeClasses
# ===========
# (they may already include default implementations in terms of other typeclasses)

# we decided for a flat module without submodules to easier use @traitsof_link
include("TypeClasses/MonoidAlternative.jl")
include("TypeClasses/FunctorApplicativeMonad.jl")
include("TypeClasses/Sequence.jl")  # depends on both Monoid and Applicative

macro traitsof_linkall()
  esc(quote
  @traitsof_link_mod TypeClasses begin
    # MonoidAlternative
    ⊕
    combine
    neutral
    reduce
    foldr
    foldl
    absorbing
    ⊛
    orelse
    # FunctorApplicativeMonad
    fforeach
    fmap
    feltype
    change_feltype
    feltype_unionall_implementationdetails
    pure
    ap
    mapn
    fflatmap
    fflatten
    fflattenrec
    # Sequence
    sequence
  end
  nothing  # for invisible output
  end)
end

# Instances
# =========

include("TypeInstances/Dict.jl")
include("TypeInstances/Function.jl")
include("TypeInstances/Iterable.jl")  # only supplies default functions, no actual dispatch is done (Reason: there had been too many conflicts with Dict already)
include("TypeInstances/Pair.jl")
include("TypeInstances/String.jl")
include("TypeInstances/Vector.jl")

include("TypeInstances/Sequence.jl")

# to ensure everything is within the definition of traitsof
traitsof_refixate()
end # module
