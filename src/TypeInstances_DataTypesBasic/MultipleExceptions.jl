using DataTypesBasic

# Monoid support for Exceptions
TypeClasses.neutral(::Type{<:Exception}) = MultipleExceptions()
TypeClasses.combine(e1::Exception, e2::Exception) = MultipleExceptions(e1, e2)
