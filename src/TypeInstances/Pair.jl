# MonoidAlternative
# =================

neutral(traitsof::Traitsof, ::Type{Pair{F, S}}) where {F, S} = neutral_Pair_traits(traitsof, F, S, traitsof(F), traitsof(S))
function neutral_Pair_traits(traitsof::Traitsof, F, S, TraitsF::TypeLB(Neutral), TraitsS::TypeLB(Neutral))
  neutral(traitsof, F) => neutral(traitsof, S)
end

absorbing(traitsof::Traitsof, ::Type{Pair{F, S}}) where {F, S} = absorbing_Pair_traits(traitsof, F, S, traitsof(F), traitsof(S))
function absorbing_Pair_traits(traitsof::Traitsof, F, S, TraitsF::TypeLB(Absorbing), TraitsS::TypeLB(Absorbing))
  absorbing(traitsof, F) => absorbing(traitsof, S)
end

function combine(traitsof::Traitsof, p1::Pair{F1, S1}, p2::Pair{F2, S2}) where {F1, S1, F2, S2}
  F = promote_type(F1, F2)
  S = promote_type(S1, S2)
  combine_Pair_traits(traitsof, p1, p2, F, S, traitsof(F), traitsof(S))
end

function combine_Pair_traits(traitsof::Traitsof, p1, p2, F, S, TraitsF::TypeLB(Combine), TraitsS::TypeLB(Combine))
  combine(traitsof, p1.first, p2.first) => combine(traitsof, p1.second, p2.second)
end


# FunctorApplicativeMonad
# =======================

feltype(traitsof::Traitsof, ::Type{Pair{L, R}}) where {L, R} = R
change_feltype(traitsof::Traitsof, ::Type{Pair{L, R1}}, R2::Type) where {L, R1} = Pair{L, R2}
change_feltype(traitsof::Traitsof, p::Pair{L, R1}, R2::Type) where {L, R1} = Pair{L, R2}(p.first, p.second)

function fforeach(::Traitsof, f, p::Pair{F, S}) where {F, S}
  f(p.second)
  nothing
end

fmap(::Traitsof, f, p::Pair{F, S}) where {F, S} = p.first => f(p.second)

# pure needs Neutral on First
pure(traitsof::Traitsof, P::Type{<:Pair{F}}, a) where F = pure_Pair_traits(traitsof, P, a, F, traitsof(F))
function pure_Pair_traits(traitsof::Traitsof, P, a, F, TraitsF::TypeLB(Neutral))
  neutral(traitsof, F) => a
end

# ap needs Semigroup on First
function ap(traitsof::Traitsof, f::Pair{First, Func}, a::Pair{First, A}) where {First, Func, A}
  ap_Pair_traits(traitsof, f, a, traitsof(First), traitsof(Func), traitsof(A))
end
function ap_Pair_traits(traitsof::Traitsof, f, a, ::TypeLB(Combine), _, _)
  combine(traitsof, f.first, a.first) => f.second(a.second)
end

# fflatten needs Semigroup on First
function fflatten(traitsof::Traitsof, a::Pair{F, Pair{F, S}}) where {F, S}
  fflatten_Pair_traits(traitsof, a, traitsof(F), traitsof(S))
end

function fflatten_Pair_traits(traitsof::Traitsof, a, TraitsFirst::TypeLB(Combine), TraitsSecond)
  combine(traitsof, a.first, a.second.first) => a.second.second
end


# Sequence
# ========

function sequence(traitsof::Traitsof, a::Pair{F, S}) where {F, S}
  sequence_Pair_traits(traitsof, a, traitsof(F), traitsof(S))
end
function sequence_Pair_traits(traitsof::Traitsof, a, TraitsF, TraitsS::TypeLB(FMap))
  fmap(traitsof, x -> (a.first => x), a.second)
end
