# Monoid
# ======

TypeClasses.neutral(::Type{String}) = ""
TypeClasses.combine(s1::String, s2::String) = s1 * s2
