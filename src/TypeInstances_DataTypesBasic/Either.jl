# MonoidAlternative
# =================

# there is no neutral definition for Either, however both combine and orelse make sense
# this also leverages sequence for dict and vector

# orelse keeps first Right
TypeClasses.orelse(x1::Identity, x2::Union{Const, Identity}) = x1
TypeClasses.orelse(x1::Const, x2::Identity) = x2

TypeClasses.neutral(::Type{Either{L, R}}) where {L, R} = Identity(neutral(R))
TypeClasses.neutral(::Type{Either{<:Any, R}}) where {R} = Identity(neutral(R))
TypeClasses.neutral(::Type{Option{T}}) where T = Const(nothing)
TypeClasses.neutral(::Type{Option}) =  Const(nothing)

# analog to definition of Option
# combine keeps Right as Lefts could be regarded as neutral elements which must have no effect on combine by convention
TypeClasses.combine(x1::Identity, x2::Const) = x1
TypeClasses.combine(x1::Const, x2::Identity) = x2


# FunctorApplicativeMonad
# =======================

TypeClasses.ap(f::Const, x::Identity) = f
TypeClasses.ap(f::Identity, x::Const) = x

TypeClasses.pure(::Type{Either}, a) = Identity(a)
TypeClasses.pure(::Type{Either{L, <:Any}}, a) where L = Identity(a)
TypeClasses.pure(::Type{Either{<:Any, R}}, a) where R = Identity(a)
TypeClasses.pure(::Type{Either{L, R}}, a) where {L, R} = Identity(a)


# FlipTypes
# =========

# all covered by Identity and Const
