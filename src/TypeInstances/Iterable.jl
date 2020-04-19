using TypeClasses
using Traits
using IsDef

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

TypeClasses.neutral(iter::Type{<:Iterable}) = IterateEmpty{eltype(iter)}()
TypeClasses.combine(it1::Iterable, it2::Iterable) = Iterable(chain(it1.iter, it2.iter))


# FunctorApplicativeMonad
# =======================

TypeClasses.pure(::Type{<:Iterable}, a) = Iterable(IterateSingleton(a))
TypeClasses.ap(fs::Iterable, it::Iterable) = Iterable(f(a) for f ∈ fs.iter for a ∈ it.iter)

# Flattening iterables is only the simple flatten.
# We don't support extra distinction between different nested types
# as a general iterable might not have a well-defined eltype.
# Even the simple Base.Generator may loose the elementtype, so that you need to come up with a way how to reconstruct
# the true elementtype. That is again difficult as iterables might be infinite.
# Using FlattenMe runtime wrapper, like we do for ContextManager, is also complicated, as you may encounter
# an iterable which first yields FlattenMe(another_iterable), but than FlattenMe(option). That is difficult to handle
# at runtime.
# Bottomline: Only flatten iterables of iterables. If you want to do more complex flattening, use Vector instead.
TypeClasses.flatten(it::Iterable) = Iterable(Iterators.flatten(it.iter))

# flip_types
# ==========

# flip_types follows from applicative and iterable
