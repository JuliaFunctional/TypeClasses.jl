using TypeClasses

# MonoidAlternative
# =================

TypeClasses.neutral(::Type{Writer{Accumulator, Value}}) where {Accumulator, Value} = neutral(Accumulator) => neutral(Value)
TypeClasses.combine(w1::Writer, w2::Writer) = Writer(combine(w1.acc, w2.acc), combine(w1.value, w2.value))

# we don't implement orelse, as it is commonly meant on container level, but there is no obvious failure semantics here

# FunctorApplicativeMonad
# =======================

TypeClasses.foreach(f, p::Writer) = f(p.value); nothing
TypeClasses.map(f, p::Writer) = Writer(p.acc, f(p.value))

# pure needs Neutral on First
function TypeClasses.pure(::Type{<:Writer{Acc}}, a) where {Acc}
  Writer(neutral(Acc), a)
end
# We fall back to assume that the general writer uses Option values in order to have a neutral value
# this should be okay, as it is canonical extension for any Semigroup to an Monoid  
function TypeClasses.pure(::Type{<:Writer}, a)
  Writer(neutral, a)
end

# Writer always defines `combine` on `acc`
function TypeClasses.ap(f::Writer, a::Writer)
  Writer(combine(f.acc, a.acc), f.value(a.value))
end

# we cannot overload this generically, because `Base.map(f, ::Vector...)` would get overwritten as well (even without warning surprisingly)
TypeClasses.map(f, a::Writer, b::Writer, more::Writer...) = mapn(f, a, b, more...)



function TypeClasses.flatmap(f, a::Writer)
  # we intentionally only convert the container to Writer, and leave the responsibility for the accumulator to the `combine` function
  # (one reason is that all monads are only converted on the container side, another is that it seems quite difficult to convert MyType{Option} correctly, because it is a Union type.)
  nested_writer = convert(Writer, f(a.value))
  Writer(combine(a.acc, nested_writer.acc), nested_writer.value)
end


# flip_types
# ==========

function TypeClasses.flip_types(a::Writer)
  TypeClasses.map(x -> Writer(a.acc, x), a.value)
end