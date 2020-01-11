using TypeClasses
using Traits

# MonoidAlternative
# =================

@traits function TypeClasses.neutral(::Type{Pair{F, S}}) where {F, S, isNeutral(F), isNeutral(S)}
  TypeClasses.neutral(F) => TypeClasses.neutral(S)
end

@traits function TypeClasses.combine(p1::Pair{F1, S1}, p2::Pair{F2, S2}) where
  {F1, S1, F2, S2, isCombine(promote_type(F1, F2)), isCombine(promote_type(S1, S2))}
  TypeClasses.combine(p1.first, p2.first) => TypeClasses.combine(p1.second, p2.second)
end

@traits function TypeClasses.absorbing(::Type{Pair{F, S}}) where {F, S, isAbsorbing(F), isAbsorbing(S)}
  TypeClasses.absorbing(F) => TypeClasses.absorbing(S)
end

@traits function TypeClasses.orelse(p1::Pair{F1, S1}, p2::Pair{F2, S2}) where
  {F1, S1, F2, S2, isOrElse(promote_type(F1, F2)), isOrElse(promote_type(S1, S2))}
  TypeClasses.orelse(p1.first, p2.first) => TypeClasses.orelse(p1.second, p2.second)
end


# FunctorApplicativeMonad
# =======================

@traits TypeClasses.eltype(::Type{Pair{L, R}}) where {L, R} = R
@traits TypeClasses.eltype(::Type{<:Pair}) = Any
@traits TypeClasses.change_eltype(::Type{<:Pair{L}}, ::Type{R}) where {L, R} = Pair{L, R}

@traits TypeClasses.foreach(f, p::Pair) = f(p.second); nothing
@traits TypeClasses.map(f, p::Pair) = p.first => f(p.second)

# pure needs Neutral on First
@traits function TypeClasses.pure(::Type{<:Pair{F}}, a) where {F, isNeutral(F)}
  TypeClasses.neutral(F) => a
end

# ap needs Semigroup on First F
@traits function TypeClasses.ap(f::Pair{F}, a::Pair{F}) where {F, isCombine(F)}
  TypeClasses.combine(f.first, a.first) => f.second(a.second)
end

# flatten needs Semigroup on First
@traits function TypeClasses.flatten(a::Pair{F, <:Pair{F}}) where {F, isCombine(F)}
  TypeClasses.combine(a.first, a.second.first) => a.second.second
end


# flip_types
# ==========

@traits function TypeClasses.flip_types(a::Pair{F, S}) where {F, S, isFunctor(S)}
  TypeClasses.map(x -> (a.first => x), a.second)
end
