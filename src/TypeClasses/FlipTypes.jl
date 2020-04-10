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
