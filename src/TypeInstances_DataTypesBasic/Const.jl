# MonoidAlternative
# =================

# for convenience we forward Monoid definitions from the wrapped type
TypeClasses.neutral(::Type{Const{T}}) where {T} = Const(TypeClasses.neutral(T))
TypeClasses.combine(a::Const, b::Const) = Const(a.value ⊕ b.value)

# we support the special value Const(nothing) by defining Monoid on Nothing
TypeClasses.neutral(::Type{Nothing}) = nothing
TypeClasses.combine(::Nothing, ::Nothing) = nothing


# Const denotes failure, possibly trying again, hence we take the second attempt.
TypeClasses.orelse(a::Const, b::Const) = b


# FunctorApplicativeMonad
# =======================

TypeClasses.ap(f::Const, a::Const) = f  # short cycling behaviour
TypeClasses.flatmap(f, a::Const) = a


# FlipTypes
# =========

TypeClasses.flip_types(a::Const) = TypeClasses.map(Const, a.value)