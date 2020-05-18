# MonoidAlternative
# =================

TypeClasses.neutral(::Type{Nothing}) = nothing
TypeClasses.absorbing(::Type{Nothing}) = nothing
TypeClasses.combine(x1::Nothing, x2::Nothing) = nothing
TypeClasses.orelse(x1::Nothing, x2::Nothing) = nothing


# FunctorApplicativeMonad
# =======================

TypeClasses.ap(f::Nothing, x::Nothing) = nothing
TypeClasses.flatmap(f, x::Nothing) = nothing


# FlipTypes
# =========

function TypeClasses.flip_types(x::Nothing)
  error("TypeClasses.flip_types is not defined for Nothing")
end
