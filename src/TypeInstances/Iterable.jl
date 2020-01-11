using TypeClasses
using Traits

"""
as we experienced problems with supporting Iterate trait directly (e.g. conflicts with Dict type)
we offer implementations for an Iterable wrapper

all functionality can also be accessed via individual functions so that
you can easily use them as default implementations when dispatching on your custom type
"""

# MonoidAlternative
# =================

@traits TypeClasses.neutral(iter) where {isiterable(iter)} = IterateEmpty{eltype(iter)}()
@traits TypeClasses.combine(it1, it2) where {isiterable(it1), isiterable(it2)} = chain(it1, it2)


# FunctorApplicativeMonad
# =======================

# implementation for Iter wrapper

@traits TypeClasses.eltype(T::Type) where {isiterable(T), Base.IteratorEltype(T)::Base.HasEltype} = Base.eltype(T)
@traits TypeClasses.eltype(T::Type) where {isiterable(T), Base.IteratorEltype(T)::Base.EltypeUnknown} = Any

# change_eltype(traitsof::Traitsof, ::Type{Iterable{A}}, B::Type) where A = Iterable{B}
# change_eltype(traitsof::Traitsof, it::Iterable{A}, B::Type) where A = Iterable{B}(it)

@traits function TypeClasses.foreach(f, iter) where {isiterable(iter)}
  for a in it
    f(a)
  end
end

@traits TypeClasses.map(f, iter) where {isiterable(iter)} = (f(x) for x ∈ it)

@traits TypeClasses.pure(T::Type, a) where {isiterable(T)} = IterateSingleton(a)
@traits TypeClasses.ap(fs, it) where {isiterable(fs), isiterable(it)} = (f(a) for f ∈ fs for a ∈ it)

@traits TypeClasses.flatten(it) where {isiterable(it)} = Iterators.flatten(it)




# FlipTypes
# =========


# generic default implementation for Monoid of Applicatives
# ---------------------------------------------------------


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

@traits function flip_types(iter::ABC) where {ABC, isiterable(ABC), isPure(ABC), isCombine(BAC(ABC))}
  flip_types_CombineBAC(iter)
end
# we define an extra function so that people can easier deal with ambiguity errors
# (might happen quite often with isiterable)
function flip_types_CombineBAC(iter::ABC) where ABC
  first = iterate(s)
  if first == nothing
    # only here we need `neutral(BAC)`
    # for non-empty sequences everything works for Types without (hence isNeutral is not dispatched on)
    neutral(BAC(ABC))
  else
    b, state = first
    start = map(c -> pure(ABC, c), b)
    #|> feltype_unionall_implementationdetails  # we need to keep care of abstract enough type for later combine
    Base.foldl(Iterators.rest(iter, state); init = start) do acc, b
      b′ = map(c -> pure(ABC, c), b)
      acc ⊕ b′  # combining BAC
    end
  end
end

#= isiterable(ABC), isPure(ABC), isCombine(AC(ABC)), isAp(BAC(ABC))
-----> special case of the above, because {isCombine(AC(ABC)), isAp(BAC(ABC))} -> isCombine(BAC(ABC))

@traits function flip_types(iter::ABC) where {ABC, isiterable(ABC), isPure(ABC), isCombine(AC(ABC)), isAp(BAC(ABC))}
  flip_types_ApBAC_CombineAC(iter)
end

function flip_types_ApBAC_CombineAC(iter::ABC) where ABC
  first = iterate(iter)
  if first == nothing
    # only in this case we actually need `pure(B)` and `neutral(AC)`
    # for non-empty sequences everything works for Types without both
    pure(B(ABC), neutral(AC(ABC)))
  else
    b, state = first
    # we need to abstract out details so that combine can actually work
    # note that because of its definition, pure(ABC, x) == pure(A, x)
    # start = feltype_unionall_implementationdetails(fmap(traitsof, a -> pure(traitsof, T, a), x)) # we can only combine on S
    start = map(c -> pure(ABC, c), b)  # we can only combine on ABC
    Base.foldl(Iterators.rest(iter, state); init = start) do acc, b
      mapn(acc, b) do acc′, c  # working in applicative context B
        acc′ ⊕ pure(ABC, c)  # combining on AC
      end
    end
  end
end
=#
