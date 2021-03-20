# MonoidAlternative
# =================

# Const's typevariables are safe to use
TypeClasses.neutral(::Type{Const{T}}) where T = Const(TypeClasses.neutral(T))
TypeClasses.absorbing(::Type{Const{T}}) where T = Const(TypeClasses.absorbing(T))
function TypeClasses.combine(x1::Const, x2::Const)
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

TypeClasses.flip_types(x::Const) = TypeClasses.map(Const, x.value)