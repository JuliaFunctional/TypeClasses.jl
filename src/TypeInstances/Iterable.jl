using TypeClasses
using Traits
using IsDef
import Traits.BasicTraits: isiterable

"""
Iterables can be seen two ways. On the one hand, an iterable is mainly defined by its `iterate` method, which can be
thought of as a kind of TypeClass (similar to how `map`, `combine`, `Monad`, or `Monoid` refer to TypeClasses). In
this sense being iterable is regarded as a decisive characteristic which is usually checked via `Base.isiterable` or
`Traits.BasicTraits.isiterable` (recommended). As an example, the TypeClass FlipTypes has a default implementation
which uses exactly this.

The alternativ semantics, which is implemented in this file, is that an iterable type can be seen as an (abstract)
DataType on top of which we can define TypeClasses themselves.

Because of this duality, we don't define TypeClasses for iterables directly by dispatching on `isiterable`, but we
provide a custom wrapper ``TypeClasses.Iterable`` on which all TypeClasses are defined.
I.e. if you want to use standard TypeClasses on top of your iterable Type, just wrap it within an ``Iterable``:
```
myiterable = ...
Iterable(myiterable)
```
"""

# MonoidAlternative
# =================

@traits TypeClasses.neutral(iter::Type{<:Iterable{ElemT}}) where ElemT = Iterable{ElemT}()
@traits TypeClasses.neutral(iter::Type{<:Iterable}) where ElemT = Iterable{Any}()
@traits TypeClasses.combine(it1::Iterable{ET1}, it2::Iterable{ET2}) where {ET1, ET2} = Iterable{promote_type(ET1, ET2)}(chain(it1.iter, it2.iter))


# FunctorApplicativeMonad
# =======================

# implementation for Iter wrapper

@traits TypeClasses.eltype(::Type{<:Iterable{ElemT}}) where ElemT = ElemT

change_eltype(::Type{Iterable{A, IterT}}, B::Type) where {A, IterT} = Iterable{B, IterT}
change_eltype(::Type{Iterable{A}}, B::Type) where {A} = Iterable{B}

@traits function TypeClasses.foreach(f, it::Iterable)
  for a in it.iter
    f(a)
  end
end


@traits TypeClasses.map(f, it::Iterable) = Iterable(f(x) for x ∈ it.iter)

@traits TypeClasses.pure(::Type{<:Iterable}, a) = Iterable(IterateSingleton(a))
@traits TypeClasses.ap(fs::Iterable, it::Iterable) = Iterable(f(a) for f ∈ fs.iter for a ∈ it.iter)

@traits TypeClasses.flatten(it::Iterable) = Iterable(Iterators.flatten(it.iter))
@traits TypeClasses.flatten(it::Iterable{<:Iterable{ElemT}}) where ElemT = Iterable{ElemT}(Iterators.flatten(it.iter))


# flip_types
# ==========

# flip_types follows from applicative and iterable
