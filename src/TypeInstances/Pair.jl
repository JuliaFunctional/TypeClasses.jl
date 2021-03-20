using TypeClasses

# we assume that Pair(a::A, b::B) always constructs the most specific Pair type Pair{A, B}
# TODO is this really the case? It could be, but is it true?

# MonoidAlternative
# =================

function TypeClasses.neutral(::Type{Pair{F, S}}) where {F, S}
  @assert(isNeutral(F) && isNeutral(S), "TypeClasses.isNeutral on Pairs is only defined if both first and second has a neutral element. However `isNeutral(First) = isNeutral($F) = $(isNeutral(F))` and `isNeutral(Second) = isNeutral($S) = $(isNeutral(S))`")
  neutral(F) => neutral(S)
end

function TypeClasses.combine(p1::Pair{F1, S1}, p2::Pair{F2, S2}) where {F1, S1, F2, S2}
  @assert(isCombine(F1, F2) && isCombine(S1, S2), "TypeClasses.combine on Pairs is only defined if both first and second define combine. However `isCombine(F1, F2) = isCombine($F1, $F2) = $(isCombine(F1, F2))` and `isCombine(S1, S2) = isCombine($S1, $S2) = $(isCombine(S1, S2))`")
  combine(p1.first, p2.first) => combine(p1.second, p2.second)
end

function TypeClasses.absorbing(::Type{Pair{F, S}}) where {F, S}
  @assert(isAbsorbing(F) && isAbsorbing(S), "TypeClasses.isAbsorbing on Pairs is only defined if both first and second has a neutral element. However `isAbsorbing(First) = isAbsorbing($F) = $(isAbsorbing(F))` and `isAbsorbing(Second) = isAbsorbing($S) = $(isAbsorbing(S))`")
  absorbing(F) => absorbing(S)
end

function TypeClasses.orelse(p1::Pair{F1, S1}, p2::Pair{F2, S2}) where {F1, S1, F2, S2}
  @assert(isOrElse(F1, F2) && isOrElse(S1, S2), "TypeClasses.isOrElse on Pairs is only defined if both first and second define combine. However `isOrElse(F1, F2) = isOrElse($F1, $F2) = $(isOrElse(F1, F2))` and `isOrElse(S1, S2) = isOrElse($S1, $S2) = $(isOrElse(S1, S2))`")
  orelse(p1.first, p2.first) => orelse(p1.second, p2.second)
end