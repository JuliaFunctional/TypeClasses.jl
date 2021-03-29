using TypeClasses

# MonoidAlternative
# =================

# We do not define MonoidAlternative for Writer, Pair and Tuple are already enough for this


# FunctorApplicativeMonad
# =======================

TypeClasses.foreach(f, p::Writer) = f(p.value); nothing
TypeClasses.map(f, p::Writer) = Writer(p.acc, f(p.value))

# pure needs Neutral on First
function TypeClasses.pure(::Type{<:Writer{Acc}}, a) where {Acc}
  Writer(neutral(Acc), a)
end

# Writer always defines `combine` on `acc`
function TypeClasses.ap(f::Writer, a::Writer)
  Writer(combine(f.acc, a.acc), f.value(a.value))
end

function TypeClasses.flatmap(f, a::Writer{Acc}) where Acc
  nested_writer = convert(Writer{Acc}, f(a.value))
  Writer(combine(a.acc, nested_writer.acc), nested_writer.value)
end


# flip_types
# ==========

function TypeClasses.flip_types(a::Writer)
  TypeClasses.map(x -> Writer(a.acc, x), a.value)
end