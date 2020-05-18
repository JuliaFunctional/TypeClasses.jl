using TypeClasses
using Traits
using IsDef

# MonoidAlternative
# =================

@traits function TypeClasses.neutral(::Type{Writer{Acc, T}}) where {Acc, T, isNeutral(Acc), isNeutral(T)}
  Writer(neutral(Acc), neutral(T))
end

@traits function TypeClasses.combine(p1::Writer{Acc1, T1}, p2::Writer{Acc2, T2}) where
  {Acc1, T1, Acc2, T2, isCombine(Acc1, Acc2), isCombine(T1, T2)}
  Writer(combine(p1.acc, p2.acc), combine(p1.value, p2.value))
end

@traits function TypeClasses.absorbing(::Type{Writer{Acc, T}}) where {Acc, T, isAbsorbing(Acc), isAbsorbing(T)}
  Writer(absorbing(Acc), absorbing(T))
end

@traits function TypeClasses.orelse(p1::Writer{Acc1, T1}, p2::Writer{Acc2, T2}) where
  {Acc1, T1, Acc2, T2, isOrElse(Acc1, Acc2), isOrElse(T1, T2)}
  Writer(orelse(p1.acc, p2.acc), orelse(p1.value, p2.value))
end


# FunctorApplicativeMonad
# =======================

TypeClasses.eltype(::Type{Writer{Acc, T}}) where {Acc, T} = T
TypeClasses.eltype(::Type{<:Writer}) = Any

TypeClasses.foreach(f, p::Writer) = f(p.value); nothing
TypeClasses.map(f, p::Writer) = Writer(p.acc, f(p.value))

# pure needs Neutral on First
@traits function TypeClasses.pure(::Type{<:Writer{Acc}}, a) where {Acc, isNeutral(Acc)}
  Writer(neutral(Acc), a)
end

# Writer always define `combine` on `acc`
function TypeClasses.ap(f::Writer, a::Writer)
  Writer(combine(f.acc, a.acc), f.value(a.value))
end

function TypeClasses.flatmap(f, a::Writer)
  nested_writer = convert(Writer, f(a.value))
  Writer(combine(a.acc, nested_writer.acc), nested_writer.value)
end


# flip_types
# ==========

@traits function TypeClasses.flip_types(a::Writer) where {isMap(a.value)}
  TypeClasses.map(x -> Writer(a.acc, x), a.value)
end
