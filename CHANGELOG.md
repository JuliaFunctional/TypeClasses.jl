# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.6.1] - 2021-03-30
### Added
* CI/CD pipeline
* Minimal Docs using Documenter
* Codecovering
* TagBot & CompatHelper

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
