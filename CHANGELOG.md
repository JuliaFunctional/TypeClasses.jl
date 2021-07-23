# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2021-07-23
### Added
- `neutral` can be used as generic `neutral` value. With this every Semigroup is automatically a Monoid.
- `neutral(type)` now defaults to returning `neutral` instead of throwing a not-implemented-error.

### Changed
- `pure(Writer, value)` now initializes the accumulator to `TypeClasses.neutral` instead of `Option()`, making it strictly more general with regard to `TypeClasses.combine`.

### Removed
- `reduce_monoid`, `foldl_monoid` and `foldr_monoid` can now only be called as `reduce_monoid(iterable; [init])`. The older variant `reduce_monoid(combine_function, iterable; [init])` was a left over from previous thrown-away iterations.

## [1.0.0] - 2021-07-16
### Added
- extensive documentation is ready
- re-exporting DataTypesBasic (Option, Try, Either, ContextManager)
- `Writer` implements `neutral` and `combine` now, analog to `Pair` and `Tuple`
- `Writer` implements `pure`, falling back to `Option()` as the generic neutral value. The user needs to wrap their accumulator into an `Option` to make use of this default.
- new method `getaccumulator` is exported to access the accumulator of an `Writer`. Access its value with `Base.get`. 
- `Dictionaries.AbstractDictionary` is supported, however only loaded if Dictionaries is available, so no extra dependency.
- `AbstractVector` type-class instances now generalises the previous `Vector` instances.
- `Base.run` is now defined for `State` as an alias for just calling it
- when running a `State` you now do not need to provide an initial state, in that case it defaults to `nothing`.
- `↠` operator is added, defined as `a ↠ b = flatmap(_ -> b, a)`, and semantically kind of the reverse of `orelse`. 
- `↠`, `orelse` (`⊘`), `combine` (`⊕`) have now multi-argument versions (i.e. they can take more than 2 arguments).
- added `flip_types` implementation for `Dict`
- for convenience, `Base.map(f, a, b, c...)` is defined as an alias for `TypeClasses.mapn(f, a, b, c...)` for the data types `Option`, `Try`, `Either`, `ContextManager`, `Callable`, `Writer`, and `State`.
- `Base.Nothing` now implements `neutral` and `combine`, concretely, `neutral(nothing) == nothing` and `nothing ⊕ nothing == nothing`. This was added to support `combine` on `Option` in general.

### Changed
- `ap` has a default implementation now, using `flatmap` and `map`. This is added because most user will be easily familiar with `flatmap` and `map`, and can define those easily. Hence this fallback simplifies the usage massively. Also there is no method ambiguity threat, because `ap` dispatches on both the function and monad argument with the concrete type, so everything is safe.
- changed `orelse` alias `⊛` to `⊘` for better visual separation, the latex name \\oslash which fits semantically kind of, and because the original reasoning was an misunderstanding.
- `Task` and `Future` now have an `orelse` implementation which parallelizes runs and returns the first result
- `flatmap` for `Identity` is now defined as `flatmap(f, a::Identity) = f(a.value)`, i.e. there is no call to `convert(Identity, ...)` any longer, which makes composing Monads even simpler (Furthermore this gets rid of the need of converting a `Const` to an `Identity` which was more a hack beforehand). 
- `neutral` for `Identity` now always returns `Const(nothing)`.
- updated TagBot
- updated CompatHelper

### Fixed
- `neutral` for Either now returns `Const`, which is accordance to the Monoid laws.

### Removed
- `orelse` is no longer forwarded to inner elements, as this function is usually defined on a container level.

## [0.6.1] - 2021-03-30
### Added
* CI/CD pipeline
* Minimal Docs using Documenter
* Codecovering
* TagBot & CompatHelper
* License

### Changed
* parts from the README went to the docs

## [0.6.0] - 2021-03-29

### Removed

* Trait functions have been removed.

  I.e. there is no longer isMonad or isApplicative. The reason is that there is ongoing work on inferring such traits automatically from whether a function is defined or not. As soon as such a generic util exists, the traits would not be needed anylonger. In addition we experienced ambiguities with isSemigroup and isMonoid, because for some examples, the trait affiliation would be defined by the eltype, but eltype is an instable characteristic and hence not recommended to use. We circumvent this problem for now by just not providing the traits.

* Removed dependency on WhereTraits.jl.

  This makes the package for more independent and easier to maintain. We loose some flexibility in multiple dispatch, and instead assume stronger constraints on how the functions should be used.

* Removed `absorbing` function. It was no where really used. To simplify maintenance we take it out for now.
 
* Removed `change_eltype` function

  During the development of this package we initially used a further function, quite related to `eltype`, called `change_eltype`. It took a container type like `Vector` and tried to change its ElementType, e.g. `change_eltype(Vector{Int}, String) == Vector{String}`. While this may seem intuitively reasonable for example to define `isAp`, namely to check whether for some Container `Container` the key function `ap` is defined for `ap(::Container{Function}, ::Container)`, this is a version of dispatching on `eltype` and hence should be avoided.

  The resolution is that we assume `ap` is always overloaded with the first argument being of the general Container-type, i.e. without any restrictions to the eltype.

### Changed

- Writer no longer checks whether the accumulator defines the Semigroup interface. This is because we dropped the traits function isSemigroup.

## [0.5.0] - 2020-03-23

### Added

* TypeClasses: Functor, Applicative, Monads, Semigroup, Monoid and flip_types (traversable sequence)
* new DataTypes: Iterable, Callable, Writer, State
* TypeInstances: Iterable, Callable, Writer, State, Future, Task, Tuple, Pair, String, Vector, Dict
* TypeInstances for all of DataTypesBasic.jl: Const, Identity, Either, ContextManager
