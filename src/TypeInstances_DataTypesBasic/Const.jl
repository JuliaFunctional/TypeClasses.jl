# MonoidAlternative
# =================

@traits TypeClasses.neutral(::Type{Const{T}}) where {T, isNeutral(T)} = Const(TypeClasses.neutral(T))
@traits TypeClasses.absorbing(::Type{Const{T}}) where {T, isAbsorbing(T)} = Identity(TypeClasses.absorbing(T))

# combine works only on stop, if its elements support combine
@traits function TypeClasses.combine(x1::Const, x2::Const) where {isCombine(x1.value, x2.value)}
  Const(x1.value ⊕ x2.value)
end

# Const behaves like Nothing, and orelse should return first non-nothing-like object
TypeClasses.orelse(x1::Const, x2::Const) = x2


# FunctorApplicativeMonad
# =======================

TypeClasses.ap(f::Const, x::Const) = f  # short cycling behaviour
TypeClasses.flatmap(f, x::Const) = x


# FlipTypes
# =========

@traits TypeClasses.flip_types(x::Const) where {isMap(x.value)} = TypeClasses.map(Const, x.value)
