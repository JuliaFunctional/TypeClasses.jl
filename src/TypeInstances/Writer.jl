using TypeClasses
using Traits
using IsDef

# MonoidAlternative
# =================

@traits function TypeClasses.neutral(::Type{Writer{Acc, T}}) where {Acc, T, isNeutral(Acc), isNeutral(T)}
  Writer(neutral(Acc), neutral(T))
end

@traits function TypeClasses.combine(p1::Writer{Acc1, T1}, p2::Writer{Acc2, T2}) where
  {Acc1, T1, Acc2, T2, isCombine(Acc1 ∨ Acc2), isCombine(T1 ∨ T2)}
  Writer(combine(p1.acc, p2.acc), combine(p1.value, p2.value))
end

@traits function TypeClasses.absorbing(::Type{Writer{Acc, T}}) where {Acc, T, isAbsorbing(Acc), isAbsorbing(T)}
  Writer(absorbing(Acc), absorbing(T))
end

@traits function TypeClasses.orelse(p1::Writer{Acc1, T1}, p2::Writer{Acc2, T2}) where
  {Acc1, T1, Acc2, T2, isOrElse(Acc1 ∨ Acc2), isOrElse(T1 ∨ T2)}
  Writer(orelse(p1.acc, p2.acc), orelse(p1.value, p2.value)
end


# FunctorApplicativeMonad
# =======================

TypeClasses.eltype(::Type{Writer{Acc, T}}) where {Acc, T} = T
TypeClasses.eltype(::Type{<:Writer}) = Any
TypeClasses.change_eltype(::Type{<:Writer{Acc}}, ::Type{T}) where {Acc, T} = Writer{Acc, T}

TypeClasses.foreach(f, p::Writer) = f(p.value); nothing
TypeClasses.map(f, p::Writer) = Writer(p.acc, f(p.second))

# pure needs Neutral on First
@traits function TypeClasses.pure(::Type{<:Writer{Acc}}, a) where {Acc, isNeutral(Acc)}
  Writer(neutral(Acc), a)
end

# Writer always define `combine` on `acc`
function TypeClasses.ap(f::Writer, a::Writer)
  combine(f.acc, a.acc) => f.value(a.value)
end

@traits function TypeClasses.flatten(a::Writer{F, <:Writer{F}}) where {F}
  combine(a.acc, a.value.acc) => a.value.value
end

# we need to handle the case of incomplete typeinference and detail Types at runtime
# the second Any indeed has to be plain Any (and not <:Any) to prevent infinite recursions
@traits function TypeClasses.flatten(a::Writer{<:Any, Any})
  flatten(fix_type(a))
end


# flip_types
# ==========

@traits function TypeClasses.flip_types(a::Writer{Acc, T}) where {Acc, T, isMap(T)}
  TypeClasses.map(x -> Writer(a.acc, x), a.value)
end

# we need to handle the case of incomplete typeinference and detail Types at runtime
# the second Any indeed has to be plain Any (and not <:Any) to prevent infinite recursions
@traits function TypeClasses.flip_types(a::Writer{<:Any, Any})
  flip_types(fix_type(a))
end


# fix_type
# ========

function TypeClasses.fix_type(a::Writer{<:Any, <:Any})
  if a.value isa Writer
    # we also need fix type on nested Writer, because we need to know whether it has the same accumulator type
    Writer(a.acc, Writer(a.value.acc, a.value.value))
  else
    Writer(a.acc, a.value)
  end
end
