using TypeClasses

"""
Iterables can be seen two ways. On the one hand, an iterable is mainly defined by its `iterate` method, which can be
thought of as a kind of TypeClass (similar to how `map`, `combine`, `Monad`, or `Monoid` refer to TypeClasses). In
this sense being iterable is regarded as a decisive characteristic which is usually checked via `Base.isiterable`.
As an example, the TypeClass FlipTypes has a default implementation which uses exactly this.

The alternativ semantics, which is implemented in this file, is that an iterable type can be seen as an (abstract)
DataType on top of which we can define TypeClasses themselves.

Because of this duality, we don't define TypeClasses for iterables directly by dispatching on `isiterable`, but we
provide a custom wrapper `TypeClasses.Iterable` on which all TypeClasses are defined.
I.e. if you want to use standard TypeClasses on top of your iterable Type, just wrap it within an `Iterable`:
```
myiterable = ...
Iterable(myiterable)
```
"""

# MonoidAlternative
# =================

TypeClasses.neutral(iter::Type{<:Iterable}) = Iterable()
TypeClasses.combine(it1::Iterable, it2::Iterable) = Iterable(chain(it1.iter, it2.iter))


# FunctorApplicativeMonad
# =======================

TypeClasses.pure(::Type{<:Iterable}, a) = Iterable(TypeClasses.DataTypes.Iterables.IterateSingleton(a))
TypeClasses.ap(fs::Iterable, it::Iterable) = Iterable(f(a) for f ∈ fs.iter for a ∈ it.iter)

# Base.map(f, iter1, iter2, iter3...) is already defined and uses zip semantics, hence we don't overload it


# Flattening Iterables works with everything being iterable itself (it is treated as iterable)
TypeClasses.flatten(it::Iterable) = Iterable(Iterators.flatten(it.iter))
TypeClasses.flatmap(f, it::Iterable) = flatten(map(f, it))


# FlipTypes
# =========

# we define flip_types for all iterable despite it only works if the underlying element defines `ap`
# as there is no other sensible definition for Iterable, an error that the element does not implement `ap`
# is actually the correct error
flip_types(iter::Iterable) = default_flip_types_having_pure_combine_apEltype(iter)
