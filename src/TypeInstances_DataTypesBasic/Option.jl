
# MonoidAlternative
# =================

# Maybe Monoid instance, as Nothing can work as neutral element
# taken from haskell http://hackage.haskell.org/package/base-4.12.0.0/docs/src/GHC.Base.html#line-419
TypeClasses.neutral(::Type{Option{T}}) where T = nothing
TypeClasses.neutral(::Type{Option}) =  nothing
# combine keeps Some as the neutral element must have no effect on combine by convention
TypeClasses.combine(x1::Identity, x2::Nothing) = x1
TypeClasses.combine(x1::Nothing, x2::Identity) = x2

# Maybe Applicative instance, here just realized via orelse implementation
TypeClasses.orelse(x1::Identity, x2::Nothing) = x1
TypeClasses.orelse(x1::Nothing, x2::Identity) = x2


# FunctorApplicativeMonad
# =======================

TypeClasses.ap(f::Identity, x::Nothing) = nothing
TypeClasses.ap(f::Nothing, x::Identity) = nothing

TypeClasses.pure(::Type{Option}, a) = Identity(a)
TypeClasses.pure(::Type{Option{T}}, a) where T = Identity(a)


# FlipTypes
# =========
# completely defined by Nothing and Identity
