using TypeClasses

# Monoid
# ======

@traits TypeClasses.neutral(::Type{String}) = ""
@traits TypeClasses.combine(s1::String, s2::String) = s1 * s2
