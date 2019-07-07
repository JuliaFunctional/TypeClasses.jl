"""
as we experienced problems with supporting Iterate trait directly (e.g. conflicts with Dict type)
we offer implementations for an Iterable wrapper

all functionality can also be accessed via individual functions so that
you can easily use them as default implementations when dispatching on your custom type
"""

# MonoidAlternative
# =================

neutral_traits_Iterate() = IterateEmpty() # our own empty type to not side-jump on Vectors (and maybe improve inference)
combine_traits_Iterate(it1, it2) = chain(it1, it2)

# implementation for Iterable

neutral(::Traitsof, ::Type{Iterable}) = Iterable{Any}(neutral_traits_Iterate())
neutral(::Traitsof, ::Type{Iterable{A}}) where A = Iterable{A}(neutral_traits_Iterate())
combine(::Traitsof, it1::Iterable{A}, it2::Iterable{B}) where {A, B} = Iterable{promote_type(A, B)}(combine_traits_Iterate(it1, it2))

# FunctorApplicativeMonad
# =======================

# fiter(it) = it
# fmap_traits_Iterate(f, it) = (f(x) for x ∈ it)
ap_traits_Iterate(fs, it) = (f(a) for f ∈ fs for a ∈ it)
fflatten_traits_Iterate(it) = Iterators.flatten(it)

# implementation for Iter wrapper

feltype(traitsof::Traitsof, ::Type{Iterable{A}}) where A = A
change_feltype(traitsof::Traitsof, ::Type{Iterable{A}}, B::Type) where A = Iterable{B}
change_feltype(traitsof::Traitsof, it::Iterable{A}, B::Type) where A = Iterable{B}(it)

function fforeach(::Traitsof, f, it::Iterable)
  for a in it
    f(a)
  end
end

function fmap(traitsof::Traitsof, f, it::Iterable{A}) where A
  B = Core.Compiler.return_type(f, Tuple{A})
  Iterable{B}(f(x) for x ∈ it)
end

pure(traitsof::Traitsof, ::Type{<:Iterable}, a::A) where A = Iterable{A}(IterateSingleton(a))

function ap(traitsof::Traitsof, fs::Iterable{F}, it::Iterable{A}) where {F, A}
  B = try
    Core.Compiler.return_type(F.instance, Tuple{A})
  catch  # F.instance might not work
    Any
  end
  Iterable{B}(ap_traits_Iterate(fs, it))
end

fflatten(traitsof::Traitsof, it::Iterable) = Iterable(fflatten_traits_Iterate(it))

#=
# unfortunately this won't work in many cases because
# - we cannot assume non-empty iterators
# - unfortunately we hit the limits of julia's type inference with nested anonymous functions (like they appear in fmap_traits_Iterate)
#   which refer to functions with as complex dispatch as fmap...
#   see https://discourse.julialang.org/t/limits-of-type-inference/22868
#   (when just referring to fmap_traits_Iterate directly instead of using fmap, things type-infer properly)

fflatten(traitsof::Traitsof, it::Iterable{<:Iterable{A}}) where A = Iterable{A}(fflatten_traits_Iterate(it))
fflatten(traitsof::Traitsof, it::Iterable{<:Iterable}) = Iterable(fflatten_traits_Iterate(it))
function fflatten_traits_Functor(traitsof::Traitsof, it::Iterable, SubIter, _, ::TypeLB(Iterate))
  Iterable(fflatten_traits_Iterate(it))
end
=#




# Sequence
# ========


# generic default implementation for Monoid of Applicatives
# ---------------------------------------------------------

function sequence_traits_Iterate__Combine_Pure__Ap_Functor(traitsof::Traitsof, s::S) where S
  # we need to construct new S type for calling `pure`/`neutral` with the correct type
  A = feltype(traitsof, S) # A = Applicative
  E = feltype(traitsof, A) # E = Element
  T = change_feltype(traitsof, S, E) # T = new S

  first = iterate(s)

  if first == nothing
    # only in this case we actually need pure(eltype(S)) and neutral(S)
    # for non-empty sequences everything works for Types without both
    B = change_feltype(traitsof, A, T)  # B = new A
    pure(traitsof, B, neutral(traitsof, T))
  else
    x, state = first
    # we need to abstract out details so that combine can actually work
    start = feltype_unionall_implementationdetails(traitsof, fmap(traitsof, a -> pure(traitsof, T, a), x)) # we can only combine on S
    Base.foldl(Iterators.rest(s, state); init = start) do acc, x
      mapn(traitsof, (a, b) -> combine(traitsof, a, pure(traitsof, T, b)), acc, x)
    end
  end
end

# implementation for Iterable

function sequence_traits_Functor_Functor(traitsof::Traitsof, s::Iterable, A, E, T, B, TraitsS, TraitsA, TraitsE, TraitsT::TypeLB(Combine, Pure), TraitsB::TypeLB(Ap, Functor))
  sequence_traits_Iterate__Combine_Pure__Ap_Functor(traitsof, s)
end


# generic default implementation for Monoid of Applicatives
# ---------------------------------------------------------

# TODO maybe better offer this as possibilities instead of default implementations (same for DataTypesBasic.TypeInstances.Sequence)
# so that users can easily add definitions to their new Types
# while not getting unexpected magic default behavior

function sequence_traits_Iterate__Combine_Pure__Combine_Functor(traitsof::Traitsof, s::S) where S
  @traitsof_link feltype change_feltype neutral pure fmap combine feltype_unionall_implementationdetails
  # we need to construct new S type for calling `pure`/`neutral` with the correct type
  A = feltype(S) # A = Applicative
  E = feltype(A) # E = Element
  T = change_feltype(S, E) # T = new S

  first = iterate(s)

  if first == nothing
    # here we only need `neutral` for the nested type, as we
    # assume it contains all information necessary to combine itself
    # for non-empty sequences everything works for Types without both
    B = change_feltype(A, T)  # B = new A
    neutral(B)
  else
    x, state = first
    start = fmap(x) do a
      pure(T, a)  # we can only combine on T
    end |> feltype_unionall_implementationdetails  # we need to keep care of abstract enough type for later combine
    Base.foldl(Iterators.rest(s, state); init = start) do acc, x
      y = fmap(x) do b
        pure(T, b)
      end
      combine(acc, y) # this uses combine on the underlying
    end
  end
end

# implementations for Iterable

function sequence_traits_Functor_Functor(traitsof::Traitsof, s::Iterable, A, E, T, B, TraitsS, TraitsA, TraitsE, TraitsT::TypeLB(Combine, Pure), TraitsB::TypeLB(Combine, Functor))
  sequence_traits_Iterate__Combine_Pure__Combine_Functor(traitsof, s)
end

# solve conflict between applicative and combine
# we default to use combine as this gives the more intuitive result for Dict and because it better follows the iterable idea
function sequence_traits_Functor_Functor(traitsof::Traitsof, s::Iterable, A, E, T, B, TraitsS, TraitsA, TraitsE, TraitsT::TypeLB(Combine, Pure), TraitsB::TypeLB(Ap, Combine, Functor))
  sequence_traits_Iterate__Combine_Pure__Combine_Functor(traitsof, s)
end
