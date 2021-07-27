# TypeClasses.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaFunctional.github.io/TypeClasses.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaFunctional.github.io/TypeClasses.jl/dev)
[![Build Status](https://github.com/JuliaFunctional/TypeClasses.jl/workflows/CI/badge.svg)](https://github.com/JuliaFunctional/TypeClasses.jl/actions)
[![Coverage](https://img.shields.io/codecov/c/github/JuliaFunctional/TypeClasses.jl)](https://codecov.io/gh/JuliaFunctional/TypeClasses.jl)

TypeClasses defines general programmatic abstractions taken from Scala cats and Haskell TypeClasses.

The following interfaces are defined:


| TypeClass   | Methods                                                  | Description                                                                                                    |
| ------------- | ---------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Functor     | `Base.map`                                               | The basic definition of a container or computational context.                                                  |
| Applicative | Functor &`TypeClasses.ap`                                | Computational context with support for parallel execution.                                                     |
| Monad       | Applicative &`TypeClasses.flatmap`                       | Computational context with support for sequential, nested execution.                                           |
| Semigroup   | `TypeClasses.combine`, alias `⊕`                        | The notion of something which can be combined with other things of its kind.                                   |
| Monoid      | Semigroup &`TypeClasses.neutral`                         | A semigroup with a neutral element is called a Monoid, an often used category.                                 |
| Alternative | `TypeClasses.neutral` & `TypeClasses.orelse`, alias `⊘` | Slightly different than Monoid, the`orelse` semantic does not merge two values, but just takes one of the two. |
