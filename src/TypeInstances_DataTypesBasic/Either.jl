# We define the Either type simply by the interactions between Identity and Const 


# MonoidAlternative
# =================

# Every Const is neutral towards Identity, we choose Const(nothing) here, the default one, following the Option implementation.
TypeClasses.neutral(::Type{<:Identity}) = Option()
# Option()::Const{Nothing}, so this should help for the Option case
TypeClasses.neutral(::Type{Const{Nothing}}) = Option()

# orelse and combine behave identical for Either, both return the Identity element
# - for combine semantics we follow the general approach of """Any semigroup S may be turned into a monoid simply by adjoining an element e not in S and defining e • s = s = s • e for all s ∈ S""" https://en.wikipedia.org/wiki/Monoid)
TypeClasses.combine(a::Identity, b::Const) = a
TypeClasses.combine(a::Const, b::Identity) = b
# - for orelse semantic Identity denotes success
TypeClasses.orelse(a::Identity, b::Const) = a
TypeClasses.orelse(a::Const, b::Identity) = b

# for generic Either, both Const and Identity can be combined on their own, but combining Const with Identity gives Identity.
# Hence, to comply with monoid laws, the neutral element is `Cons(neutral(L))`
TypeClasses.neutral(::Type{Either{L, R}}) where {L, R} = Const(neutral(L))
TypeClasses.neutral(::Type{Either{L, <:UR}}) where {L, UR} = Const(neutral(L))
# we don't provide the fallback of Option if given a generic Either type, as the monoid laws would get broken
# TypeClasses.neutral(::Type{Either}) = Const(nothing)

TypeClasses.neutral(::Type{Option{T}}) where T = Const(nothing)
TypeClasses.neutral(::Type{Option{<:UT}}) where UT = Const(nothing)
TypeClasses.neutral(::Type{Option}) = Const(nothing)



# FunctorApplicativeMonad
# =======================

TypeClasses.ap(f::Const, x::Identity) = f
TypeClasses.ap(f::Identity, x::Const) = x

# you can think of Identity as the neutral element for monadic composition: adding Identity as an additional layer, and then flattening the layers, nothing is changed in total.
TypeClasses.pure(::Type{Either{L, R}}, a) where {L, R} = Identity(a)  # includes Option, as Const{Nothing} => L=Nothing
TypeClasses.pure(::Type{Either{L, <:UR}}, a) where {L, UR} = Identity(a)
TypeClasses.pure(::Type{Either{<:UL, R}}, a) where {UL, R} = Identity(a)  # includes Try as Const{<:Exception} => UL = Exception
TypeClasses.pure(::Type{Either{<:UL, <:UR}}, a) where {UL, UR} = Identity(a)  # includes Either

# we cannot overload this generically, because `Base.map(f, ::Vector...)` would get overwritten as well (even without warning surprisingly)
# hence we do it individually for Either
Base.map(f, a::Either, b::Either, more::Either...) = mapn(f, a, b, more...)


# FlipTypes
# =========

# all covered by Identity and Const
