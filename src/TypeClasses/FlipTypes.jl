import Traits.BasicTraits: isiterable

function flip_types end
# TODO what would be a better standard check for fliptypes?
isFlipTypes(T::Type) = isdef(flip_types, T)
isFlipTypes(a) = isFlipTypes(typeof(a))


@traits function flip_types(iter::T) where {
    T, isiterable(T), isPure(T), isCombine(T), isAp(eltype(T))  # do we want to dispatch on eltype?
  }
  default_flip_types_having_pure_combine_apEltype(iter)
end

function default_flip_types_having_pure_combine_apEltype(iter::T) where T
  first = iterate(iter)
  if first == nothing
    # only in this case we actually need `pure(eltype(T))` and `neutral(T)`
    # for non-empty sequences everything works for Types without both
    pure(eltype(T), neutral(T))
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
