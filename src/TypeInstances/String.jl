using TypeClasses

TypeClasses.isNeutral(::Type{String}) = true
TypeClasses.isCombine(::Type{String}) = true

# Monoid
# ======

TypeClasses.neutral(::Type{String}) = ""
TypeClasses.combine(s1::String, s2::String) = s1 * s2
