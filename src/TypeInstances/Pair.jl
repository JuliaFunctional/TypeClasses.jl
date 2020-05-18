using TypeClasses
using Traits
using IsDef

# MonoidAlternative
# =================

@traits function TypeClasses.neutral(::Type{Pair{F, S}}) where {F, S, isNeutral(F), isNeutral(S)}
  neutral(F) => neutral(S)
end

@traits function TypeClasses.combine(p1::Pair{F1, S1}, p2::Pair{F2, S2}) where
  {F1, S1, F2, S2, isCombine(F1, F2), isCombine(S1, S2)}
  combine(p1.first, p2.first) => combine(p1.second, p2.second)
end

@traits function TypeClasses.absorbing(::Type{Pair{F, S}}) where {F, S, isAbsorbing(F), isAbsorbing(S)}
  absorbing(F) => absorbing(S)
end

@traits function TypeClasses.orelse(p1::Pair{F1, S1}, p2::Pair{F2, S2}) where
  {F1, S1, F2, S2, isOrElse(F1, F2), isOrElse(S1, S2)}
  orelse(p1.first, p2.first) => orelse(p1.second, p2.second)
end
