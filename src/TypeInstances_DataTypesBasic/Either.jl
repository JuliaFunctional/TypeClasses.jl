# MonoidAlternative
# =================

# there is no neutral definition for Either, however both combine and orelse make sense
# this also leverages sequence for dict and vector

# orelse keeps the first Identity, and does not know about how to combine values in case of several identities
TypeClasses.orelse(x1::Identity, x2::Union{Const, Identity}) = x1 
TypeClasses.orelse(x1::Const, x2::Union{Const, Identity}) = x2

TypeClasses.neutral(::Type{Either{L, R}}) where {L, R} = Identity(neutral(R))
TypeClasses.neutral(::Type{Either{<:UL, R}}) where {UL, R} = Identity(neutral(R))
TypeClasses.neutral(::Type{Option{T}}) where T = Const(nothing)
TypeClasses.neutral(::Type{Option}) =  Const(nothing)

# `combine` is quite similar to `orelse`, with the key difference that it tries to combine the underlying values in case of two Identity
# This semantic follows the idea of Const{Nothing} being an neutral element for values which just support [`combine`](@ref), but no `neutral`.
TypeClasses.combine(x1::Identity, x2::Identity) = Identity(combine(x1.value, x2.value))
TypeClasses.combine(x1::Identity, x2::Const) = x1
TypeClasses.combine(x1::Const, x2::Identity) = x2
TypeClasses.combine(x1::Const, x2::Const) = x2


# FunctorApplicativeMonad
# =======================

TypeClasses.ap(f::Const, x::Identity) = f
TypeClasses.ap(f::Identity, x::Const) = x

TypeClasses.pure(::Type{Either{L, R}}, a) where {L, R} = Identity(a)  # includes Option, as Const{Nothing} => L=Nothing
TypeClasses.pure(::Type{Either{L, <:UR}}, a) where {L, UR} = Identity(a)
TypeClasses.pure(::Type{Either{<:UL, R}}, a) where {UL, R} = Identity(a)  # includes Try as Const{<:Exception} => UL = Exception
TypeClasses.pure(::Type{Either{<:UL, <:UR}}, a) where {UL, UR} = Identity(a)


# FlipTypes
# =========

# all covered by Identity and Const
