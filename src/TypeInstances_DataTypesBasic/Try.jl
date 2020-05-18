# MonoidAlternative
# =================

# parts follow from Either

# Monoid support for Exceptions
TypeClasses.neutral(::Type{<:Exception}) = MultipleExceptions()
TypeClasses.combine(e1::Exception, e2::Exception) = MultipleExceptions(e1, e2)

# Monoid support for Const{Exception}
TypeClasses.neutral(::Type{Const{<:Exception}}) = Const(MultipleExceptions())

# we keep Identit when combining for analogy with Either and Option
TypeClasses.combine(x1::Identity, x2::Const{<:Exception}) = x1
TypeClasses.combine(x1::Const{<:Exception}, x2::Identity) = x1

# TODO delete
# function TypeClasses.combine(e1::Const{<:Exception}, e2::Const{<:Exception})
#   Const(MultipleExceptions(e1.value, e2.value))
# end

# FunctorApplicativeMonad
# =======================
# most follows from Either

TypeClasses.pure(::Type{Try}, a) = Identity(a)
TypeClasses.pure(::Type{Try{T}}, a) where T = Identity(a)


# FlipTypes
# ========
# follows completely from Either
