using TypeClasses

# we assume that Pair(a::A, b::B) always constructs the most specific Pair type Pair{A, B}
# TODO is this really the case? It could be, but is it true?

# MonoidAlternative
# =================

TypeClasses.neutral(::Type{Pair{F, S}}) where {F, S} = neutral(F) => neutral(S)
TypeClasses.combine(p1::Pair, p2::Pair) = combine(p1.first, p2.first) => combine(p1.second, p2.second)

TypeClasses.absorbing(::Type{Pair{F, S}}) where {F, S} = absorbing(F) => absorbing(S)
TypeClasses.orelse(p1::Pair, p2::Pair) = orelse(p1.first, p2.first) => orelse(p1.second, p2.second)