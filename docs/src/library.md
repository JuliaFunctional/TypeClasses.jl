# TypeClasses Public API

## Functor, Applicative, Monad

```@meta
CurrentModule = TypeClasses
```

Foreach, using `Base.foreach`
```@docs
@syntax_foreach
```

Functor, using `Base.map`
```@docs
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
tupled
```

Monad Core
```@docs
flatmap
```

Monad Helper
```@docs
flatten
↠
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
⊘
```

## FlipTypes

```@docs
flip_types
default_flip_types_having_pure_combine_apEltype
```

## TypeClasses.DataTypes

Iterable
```@docs
Iterable
```

Callable
```@docs
Callable
```

Writer
```@docs
Writer
getaccumulator
```

State
```@docs
State
getstate
putstate
```