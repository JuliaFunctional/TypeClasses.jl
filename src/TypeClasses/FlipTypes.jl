import Traits.BasicTraits: isiterable

function flip_types end
isFlipTypes(T::Type) = isdef(flip_types, T)
isFlipTypes(a) = isFlipTypes(typeof(a))


# generic default implementation for Monoid of Applicatives
# ---------------------------------------------------------

# Note that these implementations build upon ``isiterable``(``Traits.BasicTraits.isiterable``)
# instead of ``Iterable`` (``TypeClasses.DataTypes.Iterables.Iterable``).

# Think of ``isiterable`` rather as a TypeClass in this context, while ``Iterable`` is a DataType.
# Here we define ``flip_types`` TypeClass by referring to TypeClasses `isiterable`, `isPure` and `isCombine`

"""
we create helpers to access different forks of eltypes

read them as having a type ABC = A{B{C}} where
  C(ABC) = C
  AC(ABC) = A{C}
  BAC(ABC) = B{A{C}}
  B(ABC) = B{C}
"""
B(ABC) = eltype(ABC)
C(ABC) = eltype(eltype(ABC))
AC(ABC) = ABC ⫙ C(ABC)
BAC(ABC) = B(ABC) ⫙ AC(ABC)


@traits function TypeClasses.flip_types(iter::ABC) where {ABC, isiterable(ABC), isPure(ABC), isCombine(BAC(ABC))}
  default_flip_types_having_pure_combineBAC(iter)
end
# we define an extra function so that people can easier deal with ambiguity errors
# (might happen quite often with isiterable)
function default_flip_types_having_pure_combineBAC(iter::ABC) where ABC
  first = iterate(iter)
  if first == nothing
    # only here we need `neutral(BAC)`
    # for non-empty sequences everything works for Types without (hence isNeutral is not dispatched on)
    neutral(BAC(ABC))
  else
    b, state = first
    start = map(c -> pure(AC(ABC), c), b)
    Base.foldl(Iterators.rest(iter, state); init = start) do acc, b
      b′ = map(c -> pure(AC(ABC), c), b)
      acc ⊕ b′  # combining BAC
    end
  end
end

# there is an alternative implementation of flip_types on top of the following TypeClasses:
# {isiterable(ABC), isPure(ABC), isCombine(AC(ABC)), isAp(BAC(ABC))}
#
# This is a special case of the above, because {isCombine(AC(ABC)), isAp(BAC(ABC))} -> isCombine(BAC(ABC))

@traits function flip_types(iter::T) where {T, isiterable(T), isPure(T), isCombine(T), isAp(eltype(T))}
  default_flip_types_having_pure_combine_apEltype(iter)
end

function default_flip_types_having_pure_combine_apEltype(iter::T) where T
  first = iterate(iter)
  if first == nothing
    ABC = T
    # only in this case we actually need `pure(B)` and `neutral(AC)`
    # for non-empty sequences everything works for Types without both
    pure(B(ABC), neutral(AC(ABC)))
  else
    b, state = first
    # we need to abstract out details so that combine can actually work
    # note that because of its definition, pure(ABC, x) == pure(A, x)
    # start = feltype_unionall_implementationdetails(fmap(traitsof, a -> pure(traitsof, T, a), x)) # we can only combine on S
    start = map(c -> pure(T, c), b)  # we can only combine on ABC
    Base.foldl(Iterators.rest(iter, state); init = start) do acc, b
      mapn(acc, b) do acc′, c  # working in applicative context B
        acc′ ⊕ pure(T, c)  # combining on T
      end
    end
  end
end

# in case a type implements both actually the apEltype version should be more type-stable, hence we fallback to that one
@traits function flip_types(iter::T) where {T, isiterable(T), isPure(T), isCombine(T), isAp(eltype(T)), isCombine(BAC(T))}
  default_flip_types_having_pure_combine_apEltype(iter)
end
