using TypeClasses.Utils

"""
    flip_types(value::T{S{A}})::S{T{A}}

reverses the two outer containers, e.g. making an Array of Options into an Option of an Array.
"""
function flip_types end


"""
    default_flip_types_having_pure_combine_apEltype(container)

Use this helper function to ease the definition of `flip_types` for your own type.

Note that the following interfaces are assumed:
- iterable
- pure
- combine
- ap on eltype

And in case of empty iterable in addition the following:
- neutral
- pure on eltype

We do not overload `flip_types` directly because this would require dispatching on whether `isAp(eltype(T))`.
But relying on `eltype` to define different semantics is strongly discouraged.
"""
function default_flip_types_having_pure_combine_apEltype(iter::T) where T
  first = iterate(iter)
  if first === nothing
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
