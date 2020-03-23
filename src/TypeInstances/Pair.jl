using TypeClasses
using Traits
using IsDef

# MonoidAlternative
# =================

@traits function TypeClasses.neutral(::Type{Pair{F, S}}) where {F, S, isNeutral(F), isNeutral(S)}
  neutral(F) => neutral(S)
end

@traits function TypeClasses.combine(p1::Pair{F1, S1}, p2::Pair{F2, S2}) where
  {F1, S1, F2, S2, isCombine(F1 ∨ F2), isCombine(S1 ∨ S2)}
  combine(p1.first, p2.first) => combine(p1.second, p2.second)
end

@traits function TypeClasses.absorbing(::Type{Pair{F, S}}) where {F, S, isAbsorbing(F), isAbsorbing(S)}
  absorbing(F) => absorbing(S)
end

@traits function TypeClasses.orelse(p1::Pair{F1, S1}, p2::Pair{F2, S2}) where
  {F1, S1, F2, S2, isOrElse(F1 ∨ F2), isOrElse(S1 ∨ S2)}
  orelse(p1.first, p2.first) => orelse(p1.second, p2.second)
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
  neutral(F) => a
end

# ap needs Semigroup on First F
@traits function TypeClasses.ap(f::Pair{F}, a::Pair{F}) where {F, isCombine(F)}
  combine(f.first, a.first) => f.second(a.second)
end

# flatten needs Semigroup on First
@traits function TypeClasses.flatten(a::Pair{F, <:Pair{F}}) where {F, isCombine(F)}
  combine(a.first, a.second.first) => a.second.second
end

# we need to handle the case of incomplete typeinference and detail Types at runtime
@traits function TypeClasses.flatten(a::Pair{<:Any, Any})
  flatten(fix_type(a))
end


# flip_types
# ==========

@traits function TypeClasses.flip_types(a::Pair{F, S}) where {F, S, isFunctor(S)}
  TypeClasses.map(x -> (a.first => x), a.second)
end

# we need to handle the case of incomplete typeinference and detail Types at runtime
@traits function TypeClasses.flip_types(a::Pair{<:Any, Any})
  flip_types(fix_type(a))
end


# fix_type
# ========

function TypeClasses.fix_type(a::Pair{<:Any, Any})
  a.first => a.second
end
