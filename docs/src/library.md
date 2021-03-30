# TypeClasses Public API

## Functor, Applicative, Monad

```@meta
CurrentModule = TypeClasses
```

Foreach
```@docs
Base.foreach
@syntax_foreach
```

Functor
```@docs
Base.map
@syntax_map
```

Applicative Core
```@docs
pure
ap
```

Applicative Helper
```@docs
mapn
@mapn
sequence
tupled
```

Monad Core
```@docs
flatmap
```

Monad Helper
```@docs
flatten
@syntax_flatmap
```

## Semigroup, Monoid, Alternative

Semigroup
```@docs
combine
⊕
```

Neutral
```@docs
neutral
```

Monoid Helpers
```@docs
reduce_monoid
foldr_monoid
foldl_monoid
```

Alternative
```@docs
orelse
⊛
```

## FlipTypes

```@docs
flip_types
```

## TypeClasses.DataTypes

Iterable
```@docs
Iterable
IterateEmpty
IterateSingleton
```

Callable
```@docs
Callable
```

Writer
```@docs
Writer
```

State
```@docs
State
getstate
putstate
```