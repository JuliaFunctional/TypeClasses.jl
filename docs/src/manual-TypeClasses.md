
```@meta
CurrentModule = TypeClasses
DocTestSetup  = quote
    using TypeClasses
    using Dictionaries
end
```

# TypeClasses

## [Functor, Applicative, Monad](@id functor_applicative_monad)

Typeclass | Interface | Helpers from `TypeClasses`
--------- | --------- | ---------------------------
&nbsp; | `TypeClasses.foreach = Base.foreach` | `@syntax_foreach`
Functor, Applicative, Monad  | `TypeClasses.map = Base.map` | `@syntax_map`
Applicative, Monad | `TypeClasses.pure`, `TypeClasses.ap` | `ap` is automatically defined if you defined `Base.map` and `TypeClasses.flatmap`. Further helpers: `mapn`, `@mapn`, `tupled`, `neutral_applicative`, `combine_applicative`, `orelse_applicative`
Monad | `TypeClasses.flatmap` | `flatten`, `↠` (\twoheadrightarrow), `@syntax_flatmap`

There are three syntax supported, where `@syntax_flatmap` is the most useful, however sometimes `@syntax_foreach` may also be handy because of its power and simplicity in a programming language with side-effects (like Julia).

```jldoctest
julia> @syntax_foreach begin  # translates to foreach calls
         a = [1, 2]
         b = [3, 4]
         @pure println("a = $a, b = $b")
       end
a = 1, b = 3
a = 1, b = 4
a = 2, b = 3
a = 2, b = 4

julia> @syntax_map begin  # translates to map calls
         a = [1, 2]
         b = [3, 4]
         @pure "a = $a, b = $b"
       end
2-element Vector{Vector{String}}:
 ["a = 1, b = 3", "a = 1, b = 4"]
 ["a = 2, b = 3", "a = 2, b = 4"]

julia> @syntax_flatmap begin  # translates to map/flatmap calls
         a = [1, 2]
         b = [3, 4]
         @pure "a = $a, b = $b"
       end
4-element Vector{String}:
 "a = 1, b = 3"
 "a = 1, b = 4"
 "a = 2, b = 3"
 "a = 2, b = 4"
```

For **Applicatives** there are a couple of additional helpers

```jldoctest
julia> f(a, b, c) = a + b + c
f (generic function with 1 method)

julia> @mapn f([1,2], [10], [100, 200])  # can also be written as `mapn(f, [1,2], [10], [100,200])`
4-element Vector{Int64}:
 111
 211
 112
 212

julia> tupled([1,2], [3, 4])
4-element Vector{Tuple{Int64, Int64}}:
 (1, 3)
 (1, 4)
 (2, 3)
 (2, 4)
```

And for **Monads** you have
```jldoctest
julia> flatten([[1,2], [3,4]])
4-element Vector{Int64}:
 1
 2
 3
 4

julia> [1, 2] ↠ [3, 4]  # flatmap(_ -> [3,4], [1,2])
4-element Vector{Int64}:
 3
 4
 3
 4

julia> Option(3) ↠ Option() ↠ Option("hi")  # stopping behaviour with operator syntax
Const(nothing)
```

### Considerations

#### Functor - map

You can overload `TypeClasses.map` or `Base.map`, as you like, they are both the very same.

#### Monad - flatmap

We decided to use `flatmap` as the interface, because it is often more intuitiv to implement than `flatten` and also comes quite natural next to `map`.

In order to enable simple interactions between monads, all `flatmap` implementations use `convert` before flattening. The exception is `Identity` which for convenience just returns whatever inner monad may appear, without forcing a conversion to `Identity`. For example, this enables you to combine `Vector` with `OPtion`, `Try`, `Either` in all ways.

`@syntax_flatmap` provides monadic syntax (similar to haskell do-notation). However, the macro translates to `flatmap` and `map` only, and does not need `pure`.

#### Applicative - ap / mapn / map

`mapn` is explicitly an extra function, because it has a generic definition which uses `pure` and `ap`, which can also be derived given the implementation of `flatmap` and single `map`. Many types define `Base.map(f, a, b, c, ...)` which is in this sense a `mapn`. However, they sometimes do not conform to the respective implementation of `flatten`/`flatmap`. For example `Vector` defines `Base.map(f, a, b, c, ...)` for Vectors of equal length, however flattening vectors is collecting all combinations of all vectors. These are two different semantics and it is hard to forsee which error-potentials this would bring if they are intermixed. Another example is `Dictionaries.Dictionary`, which supports map similar to Vector, checking for same indices first and raising an error otherwise.

For convenience, `Base.map(f, a, b, c...)` is defined as an alias for `TypeClasses.mapn(f, a, b, c...)` for the data types `Option`, `Try`, `Either`, `ContextManager`, `Callable`, `Writer`, and `State`.

Each Applicative can lift an underlying Monoid. In addition some Applicatives also define Monoids themselves (e.g. Vector). Hence, we distinguish both by adding functions `neutral_applicative`, `combine_applicative`, `orelse_applicative`.


## [Semigroup, Monoid, Alternative](@id semigroup_monoid_alternative)

Typeclass | Interface | Helpers from `TypeClasses`
--------- | --------- | --------------
Monoid, Alternative | `TypeClasses.neutral` | 
Monoid, Semigroup | `TypeClasses.combine` | alias `⊕` (\oplus), `reduce_monoid`, `foldr_monoid`, `foldl_monoid`
Alternative | `TypeClasses.orelse` | alias `⊘` (\oslash) 

A **Semigroup** just supports `combine`, a **Monoid** in addition supports `neutral`. We define the generic neutral element `neutral` which is neutral to everything, hence every Semigroup is actually a Monoid in Julia. Hence `TypeClasses.neutral` is both a function which returns the neutral element (defaulting to `neutral`), as well as the generic neutral element itself. 

Sometimes, the type itself has an obvious way of combining multiple values, like for `String` or `Vector`. Other times, the `combine` is forwarded to inner elements in case it is needed.

```jldoctest
julia> neutral(Vector) ⊕ [1,2] ⊕ [3]
3-element Vector{Any}:
 1
 2
 3

julia> d = Dict(:a => "hello.", :b => 4) ⊕ Dict(:a => "world.", :c => 1.0)
Dict{Symbol, Any} with 3 entries:
  :a => "hello.world."
  :b => 4
  :c => 1.0

julia> combine(Option(), Option([1]), Option([2, 3]))
Identity([1, 2, 3])
```

Let's look at **Alternative**. Take the `Dict` as an example of a container. If we find the same key in both dictionaries, `combine` is going to recursively call `combine` on them. Alternatively, we could just grab the one or the other. This is implemented within the `orelse` function, which will always take the first value it finds. 

```jldoctest
julia> Dict(:a => "first", :b => 4) ⊘ Dict(:a => true, :c => 1.0)
Dict{Symbol, Any} with 3 entries:
  :a => "first"
  :b => 4
  :c => 1.0

julia> orelse(Option(), Option(1), Option(4))
Identity(1)
```


### Considerations

We decided to use the same `neutral` for both Monoid and Alternative because of simplicity. 

Julia does not have stable typeparameters (for optimization a typeparameter may be inferred as Any instead of more concrete type), and hence Alternative (which is concept targeted at Functors, i.e. things with one typeparameter) becomes way more similar to Monoid.


## [FlipTypes](@id flip_types)

Typeclass | Interface | Helpers from `TypeClasses`
--------- | --------- | --------------------------
FlipTypes | `TypeClasses.flip_types` | `TypeClasses.default_flip_types_having_pure_combine_apEltype`

`flip_types(::A{B{C}})` should return `::B{A{C}}`. Hence the name: it flips the first two types. 

Here are some examples
```jldoctest
julia> flip_types([Option(:a), Option(:b)])
Identity([:a, :b])

julia> flip_types(Identity([:a, :b]))
2-element Vector{Identity{Symbol}}:
 Identity(:a)
 Identity(:b)

julia> flip_types([Option(:a), Option()])
Const(nothing)

julia> using Dictionaries

julia> flip_types(dictionary((:a => [1,2], :b => [3, 4])))
4-element Vector{Dictionary{Symbol, Int64}}:
 {:a = 1, :b = 3}
 {:a = 1, :b = 4}
 {:a = 2, :b = 3}
 {:a = 2, :b = 4}

julia> flip_types([dictionary((:a => 1, :b => 2)), dictionary((:a => 10, :b => 20)), dictionary((:b => 200, :c => 300))])
1-element Dictionaries.Dictionary{Symbol, Vector{Int64}}
 :b │ [2, 20, 200]
```

You see that flip_types may actually forget information. This is normal, but very important to remember. Hence, applying flip_types twice usually not return to the original value, but will change the result.


### Considerations

FlipTypes is not an official TypeClass, however proofs to be a very essential abstraction. Normally this comes with the TypeClass Traversable and is called `sequence`, however that name is not very self-explanatory and sounds quite specific.

`TypeClasses.flip_types` has already one big usage in `ExtensibleEffects.jl`, for a generic implementation of effect handling.

