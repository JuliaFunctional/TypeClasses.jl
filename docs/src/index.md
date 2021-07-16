```@meta
CurrentModule = TypeClasses
DocTestSetup  = quote
    using TypeClasses
end
```

# TypeClasses.jl

Documentation for [TypeClasses](https://github.com/JuliaFunctional/TypeClasses.jl).

TypeClasses defines general programmatic abstractions taken from Scala cats and Haskell TypeClasses.

The following interfaces are defined:

TypeClass   | Methods                             | Description
----------- | ----------------------------------- | --------------------------------------------------------------------
[Functor ](@ref functor_applicative_monad)    | `Base.map`                          | The basic definition of a container or computational context.
[Applicative](@ref functor_applicative_monad) | Functor & `TypeClasses.pure` & `TypeClasses.ap` (automatically defined when `map` and `flatmap` are defined)          | Computational context with support for parallel execution.
[Monad](@ref functor_applicative_monad)       | Applicative & `TypeClasses.flatmap` | Computational context with support for sequential, nested execution.
[Semigroup](@ref semigroup_monoid_alternative)   | `TypeClasses.combine`, alias `⊕`    | The notion of something which can be combined with other things of its kind.
[Monoid](@ref semigroup_monoid_alternative)      | Semigroup & `TypeClasses.neutral`   | A semigroup with a neutral element is called a Monoid, an often used category.
[Alternative](@ref semigroup_monoid_alternative) | `TypeClasses.neutral` & `TypeClasses.orelse`, alias `⊘` | Slightly different than Monoid, the `orelse` semantic does not merge two values, but just takes one of the two.
[FlipTypes](@ref flip_types)   | `TypeClasses.flip_types`            | Enables dealing with nested types. Transforms an `A{B{C}}` into an `B{A{C}}`.


For convenience this packages further provides a couple of standard DataTypes and implements the interfaces for them.


## Manual Outline

```@contents
Pages = ["manual.md", "manual-TypeClasses.md", "manual-DataTypes.md"]
```

## [Library Index](@id main-index)

```@index
Pages = ["library.md"]
```