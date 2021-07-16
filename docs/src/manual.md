```@meta
CurrentModule = TypeClasses
DocTestSetup  = quote
    using TypeClasses
    using Dictionaries
end
```

# Introduction

Welcome to `TypeClasses.jl`. TypeClasses defines general programmatic abstractions taken from Scala cats and Haskell TypeClasses.

We use "interface" and "typeclass" synonymously. The following interfaces are defined:

TypeClass   | Methods                             | Description
----------- | ----------------------------------- | --------------------------------------------------------------------
[Functor ](@ref functor_applicative_monad)    | `Base.map`                          | The basic definition of a container or computational context.
[Applicative](@ref functor_applicative_monad) | Functor & `TypeClasses.pure` & `TypeClasses.ap` (automatically defined when `map` and `flatmap` are defined)          | Computational context with support for parallel execution.
[Monad](@ref functor_applicative_monad)       | Applicative & `TypeClasses.flatmap` | Computational context with support for sequential, nested execution.
[Semigroup](@ref semigroup_monoid_alternative)   | `TypeClasses.combine`, alias `⊕`    | The notion of something which can be combined with other things of its kind.
[Monoid](@ref semigroup_monoid_alternative)      | Semigroup & `TypeClasses.neutral`   | A semigroup with a neutral element is called a Monoid, an often used category.
[Alternative](@ref semigroup_monoid_alternative) | `TypeClasses.neutral` & `TypeClasses.orelse`, alias `⊘` | Slightly different than Monoid, the `orelse` semantic does not merge two values, but just takes one of the two.
[FlipTypes](@ref flip_types)   | `TypeClasses.flip_types`            | Enables dealing with nested types. Transforms an `A{B{C}}` into an `B{A{C}}`.


## Installation

```julia
using Pkg
Pkg.add("TypeClasses")
```

Use it like
```julia
using TypeClasses
```

## More Details

For detailed information of the TypeClasses, see [TypeClasses](@ref).

For detailed information about implementations of the TypeClasses for concrete DataTypes, see [DataTypes](@ref).


## General Design Decisions

* reuse as much `Base` as possible
* make it stable (hence so far we only support the most important type-classes)
* make it simple
* make it convenient
* bring examples


### No dispatch on `eltype`

With Functors and the like a typical thing you want to do is to get to know more about the inner type, i.e. the `eltype`. It turns out this is unwanted.

Julia's type-inference is seriously incomplete and there is also no sign that this will ever change. The compiler tries very hard to always infer the maximal specific type, but may fallback to more generic types if unsure or because of time-constraints. A calculation which may build up a `Vector{Number}` may easily turn out as a `Vector{Any}`, and even for a method returning `Vector{String}`, the underlying code may be that dynamic in nature, that the compiler just cannot infer the type and will return `Vector{Any}`. The take home message here is that, practically, `eltype` is an instable function. It's concrete behaviour, somewhere within a nested stack of function calls, may change between versions, depending on changing undocumented compiler-heuristics, or may even change because another layer of abstractions is added somewhere within the nested calls, which again triggers different compiler-heuristics.

If you dispatch on `Vector{Number}` in order to implement something specific for Number, that may fail to catch the Vector{Number} which was interpreted as `Vector{Any}` because of approximate type inference. You need to make sure that the semantics of the method for `Vector{Any}` is actually identical to the specialised version `Vector{Number}`. You should only ever do performance optimisations when dispatching on `eltype`, never base your semantics on `eltype`.

With Functors, specifically with Monads, we have exactly the setting where we may dispatch on `eltype` to define different semantics. They key reason is that there are a couple of Monads where you cannot inspect the concrete elements, for instance `Callable` where the element is hidden behind an arbitrary function. Hence you may not be able to implement a function for `Callable{Any}` in a sensible way, while it actually is well-defined for `Callable{Callable}`. That is not Julia.

Another example is the typeclass `neutral`. It turns out you can define `neutral` for each `Applicative` which ElementType itself implements `neutral`. It is really tempting to define the generic implementation for Applicatives, dispatching on `eltype`... Instead we provide specific applicative versions `neutral_applicative` and `combine_applicative` which assume the elements comply to the `Neutral` and `Semigroup` interface respectively. Similar for `orelse`.

As we cannot safely dispatch on `eltype`, the Julia way is to just assume your ElementType has the characteristics needed for your function, i.e. use duck-typing instead of dispatch. Naturally, this will work for all containers with the right elements. And in case the elements do not implement the required interfaces, it will fail with a well self-explaining `MethodError`. This you can then debug which will bring you directly to the place where you can inspect the elements in detail.
