# MonoidAlternative
# =================

neutral(::Traitsof, ::Type{Vector{A}}) where A = Vector{A}(undef, 0)
neutral(::Traitsof, ::Type{Vector}) = Vector{Any}(undef, 0)
function combine(traitsof::Traitsof, v1::Vector, v2::Vector)
  [v1; v2]
end

# FunctorApplicativeMonad
# =======================

change_feltype(::Traitsof, ::Type{Array{E1, N}}, ::Type{E2}) where {N, E1, E2} = Array{E2, N}
change_feltype(::Traitsof, a::Array{E1, N}, ::Type{E2}) where {N, E1, E2} = E1 == E2 ? a : Array{E2, N}(a)

function fforeach(traitsof::Traitsof, f, v::Vector)
  for a in v
    f(a)
  end
end

# this is overloading fmap/pure/ap directly without using traits
# hence extra namings of functions is not so needed because it won't come so easily to dispatch conflicts
fmap(traitsof::Traitsof, f, v::Vector) = map(f, v)

# we need to support generic Type{Vector} as this may be used as generic parameter which does not know how to change typeparameters
# i.e. we cannot use `pure(traitsof::Traitsof, ::Type{Vector{A}}, a::A) where A = [a]`
pure(traitsof::Traitsof, ::Union{Type{Vector{A}} where A, Type{Vector}}, a) = [a]

function ap(traitsof::Traitsof, fs::Vector, v::Vector)
  [f(a) for f ∈ fs for a ∈ v]
end

function fflatten(traitsof::Traitsof, v::Vector{Vector{E}}) where E
  vcat(v...)
end


# Sequence
# ========

# Sequence instance follows from Pure and Ap

function sequence_traits_Functor_Functor(traitsof::Traitsof, s::Vector, A, E, T, B, TraitsS, TraitsA, TraitsE, TraitsT::TypeLB(Combine, Pure), TraitsB::TypeLB(Ap, Functor))
  sequence_traits_Iterate__Combine_Pure__Ap_Functor(traitsof, s)
end

# Sequence instance follows from Pure and Combine

function sequence_traits_Functor_Functor(traitsof::Traitsof, s::Vector, A, E, T, B, TraitsS, TraitsA, TraitsE, TraitsT::TypeLB(Combine, Pure), TraitsB::TypeLB(Combine, Functor))
  sequence_traits_Iterate__Combine_Pure__Combine_Functor(traitsof, s)
end

# solve conflict between applicative and combine
# we default to use combine as this gives the more intuitive result for Dict and because it better follows the iterable idea
function sequence_traits_Functor_Functor(traitsof::Traitsof, s::Vector, A, E, T, B, TraitsS, TraitsA, TraitsE, TraitsT::TypeLB(Combine, Pure), TraitsB::TypeLB(Ap, Combine, Functor))
  sequence_traits_Iterate__Combine_Pure__Combine_Functor(traitsof, s)
end
