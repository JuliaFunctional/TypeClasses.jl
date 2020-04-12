# MonoidAlternative
# =================

# there is no neutral definition for Either, however both combine and orelse make sense
# this also leverages sequence for dict and vector

# orelse keeps first Right
TypeClasses.orelse(x1::Right, x2::Either) = x1
TypeClasses.orelse(x1::Left, x2::Either) = x2

@traits TypeClasses.neutral(::Type{<:Either{L}}) where {L, isNeutral(L)} = Left{L, Any}(neutral(L))
@traits TypeClasses.neutral(::Type{<:Either{L, R}}) where {L, R, isNeutral(R)} = Right{L, R}(neutral(R))

# combine keeps Right as Lefts could be regarded as neutral elements which must have no effect on combine by convention
TypeClasses.combine(x1::Right, x2::Left) = x1
TypeClasses.combine(x1::Left, x2::Right) = x2
TypeClasses.combine(x1::Left, x2::Either) = x2  # if no combine is defined on Left, that is fine for us
# TODO more liberal on L, i.e. L1, L2?
@traits function TypeClasses.combine(x1::Right{L, R}, x2::Right{L, R}) where {L, R, isCombine(R)}
  Right{L}(x1.value ⊕ x2.value)
end
# TODO more liberal on R, i.e. R1, R2?
@traits function TypeClasses.combine(x1::Left{L, R}, x2::Left{L, R}) where {L, R, isCombine(L)}
  x = x1.value ⊕ x2.value
  Left{typeof(x), R}(x)
end

# FunctorApplicativeMonad
# =======================

TypeClasses.change_eltype(::Type{<:Either{L}}, R) where {L} = Either{L, R}
TypeClasses.change_eltype(::Type{<:Left{L}}, R) where {L} = Left{L, R}
TypeClasses.change_eltype(::Type{<:Right{L}}, R) where {L} = Right{L, R}

TypeClasses.ap(f::Right{L, F}, x::Right{L, R}) where {F, L, R} = Right{L}(f.value(x.value))
TypeClasses.ap(f::Left{L, F}, x::Right{L, R}) where {F, L, R} = ap_Either_left(F, L, R, f.value)
TypeClasses.ap(f::Right{L, F}, x::Left{L, R}) where {F, L, R} = ap_Either_left(F, L, R, x.value)
TypeClasses.ap(f::Left{L, F}, x::Left{L, R}) where {F, L, R} = ap_Either_left(F, L, R, f.value)

function ap_Either_left(F, L, R, left)
  _R2 = Out(apply, F, R)
  R2 = _R2 === NotApplicable ? Any : _R2
  Left{L, R2}(left)
end

# left implementation which still works with missing type information
TypeClasses.flatten(x::Either) = Iterators.flatten(x)

TypeClasses.pure(::Type{<:Either{L}}, a) where {L} = Right{L}(a)
TypeClasses.pure(::Type{<:Either}, a) = Right{Any}(a)



# FlipTypes
# =========

@traits function TypeClasses.flip_types(x::Right{L, R}) where {L, R, isMap(R)}
  TypeClasses.map(y -> Right{L}(y), x.value)
end

@traits function TypeClasses.flip_types(x::Left{L, R}) where {L, R, isMap(L)}
  TypeClasses.map(y -> Left{typeof(y), R}(y), x.value)
end


@traits function TypeClasses.flip_types(x::Right{<:Any, Any})
  flip_types(fix_type(x))
end
@traits function TypeClasses.flip_types(x::Left{Any, <:Any})
  flip_types(fix_type(x))
end


# fix_type
# ========

function TypeClasses.fix_type(x::Right{L, Any}) where L
  Right{L, typeof(x.value)}(x.value)
end
function TypeClasses.fix_type(x::Left{Any, R}) where R
  Left{typeof(x.value), R}(x.value)
end
