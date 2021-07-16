```@meta
CurrentModule = TypeClasses
DocTestSetup  = quote
    using TypeClasses
    using Dictionaries
end
```

# DataTypes

## Option, Try, Either

`Option`, `Try`, and `Either` are re-exported from [DataTypesBasic.jl](https://github.com/JuliaFunctional/DataTypesBasic.jl) and equipped with the TypeClasses. As all three are implemented using the same primitives `Identity` and `Const`, they can actually be combined seamlessly. `Option` and `Try` are really only more specific `Either`. This is quite a unique design among typeclasses, which enables a lot flexibility and simplicity.

DataType | Implementation | Helpers
-------- | -------------- | -------
Identity | `Identity`     | `isidentity`, all&nbsp;TypeClasses
Const    | `Const`        |  `Base.isconst`, almost all TypeClasses, but without `pure`
Either   | `Either{L, R} = Union{Const{L}, Identity{R}}` | `Either`, `Base.eltype`, `either`, `@either`, `flip_left_right`, `iseither`, `isleft`, `isright`, `getleft`, `getright`, `getleftOption`, `getrightOption`, `getOption`, all&nbsp;TypeClasses
Try      | `Try{T} = Union{Const{<:Exception}, Identity{T}}` | `Try`, `@Try`, `@TryCatch`, `istry`, `issuccess`, `isfailure`, all&nbsp;TypeClasses
Option   | `Option{T} = Union{Const{Nothing}, Identity{T}}` | `Option`, `isoption`, `issome`, `isnone`, `iffalse`, `iftrue`, all&nbsp;TypeClasses

For more Details take also a look at [DataTypesBasic.jl](https://github.com/JuliaFunctional/DataTypesBasic.jl).


### Functor/Applicative/Monad

If all works, the result is an `Identity`
```jldoctest
julia> @syntax_flatmap begin
         a = true ? Option(4) : Option()
         b = @Try isodd(a) ? error("stop") : 5
         c = either(:left, isodd(b), "right")
         @pure a, b, c
       end
Identity((4, 5, "right"))
```

If something fails, the computation stops early on, returning a `Const`
```jldoctest
julia> @syntax_flatmap begin
         a = false ? Option(4) : Option()
         b = @Try isodd(a) ? error("stop") : 5
         c = either(:left, isodd(b), "right")
         @pure a, b, c
       end
Const(nothing)

julia> @syntax_flatmap begin
         a = true ? Option(5) : Option()
         b = @Try isodd(a) ? error("stop") : 5
         c = either(:left, isodd(b), "right")
         @pure a, b, c
       end
Const(Thrown(ErrorException("stop")))

julia> @syntax_flatmap begin
         a = true ? Option(4) : Option()
         b = @Try isodd(a) ? error("stop") : 6
         c = either(:left, isodd(b), "right")
         @pure a, b, c
       end
Const(:left)
```

### Monoid/Alternative

You can also `combine` Option, Try, Either. When combining Const with Const or Identity with Identity, the `combine` function of the underlying value is used. When combining `Const` with `Identity`, the `Identity` is always returned. When using `Option`, the value `Option() = Const(nothing)` deals as the `neutral` value and hence you can make any Semigroup (something which supports `combine`) into a Monoid (something which supports `combine` and `neutral`) by just wrapping it into `Option`.

```jldoctest
julia> combine(Option(), Option(4))
Identity(4)

julia> @Try(4) ⊕ @Try(error("stop"))  # \oplus is an alias for `combine`
Identity(4)

julia> either(:left, true, "right.") ⊕ @Try("success.") ⊕ Option("also needs to be a string.")
Identity("right.success.also needs to be a string.")
```

If your the element does not support `combine`, you can still use `orelse` (alias `⊘`, \oslash), which will just return the first Identity value.
```jldoctest
julia> either(:left, false, "right.") ⊘ @Try("success.") ⊘ Option(["does" "not" "need" "to" "be" "a" "string."])
Identity("success.")
```

For completenes, the Monad definition of `Option`, `Try`, and `Either` also come with the binary operator `↠` (\twoheadrightarrow), which acts somehow as the reverse of `orelse`: It will stop at the first `Const` value:
```jldoctest
julia> either(:left, true, "right.") ↠ @Try(error("stop.")) ↠ Option(["does" "not" "need" "to" "be" "a" "string."])
Const(Thrown(ErrorException("stop.")))
```

### FlipTypes

With any Functor you can flip types.
```jldoctest
julia> flip_types(Const(Identity(3)))
Identity(Const(3))

julia> flip_types(Identity(Const(3)))
Const(3)
```
You may be surprised by `Const(3)`, however this is correct. Flipping an outer Identity will `map` Identity over the inner Functor. The `Const` Functor, however, just ignores everything when mapped over it and will stay the same. More correctly, it would have changed its pseudo return value, however this is not represented in Julia, leaving it literally constant. 


## ContextManager

`ContextManager` also comes from [DataTypesBasic.jl](https://github.com/JuliaFunctional/DataTypesBasic.jl). It is super handy to define your own enter-exit semantics.

### Functor/Applicative/Monad

```jldoctest
julia> create_context(x) = @ContextManager continuation -> begin
         println("before x = $x")
         result = continuation(x)
         println("after x = $x")
         result
       end
create_context (generic function with 1 method)

julia> context = @syntax_flatmap begin
         a = create_context(3)
         b = create_context(a*a)
         @pure a, b
       end;

julia> context() do x
         println("within x = $x")
         x
       end
before x = 3
before x = 9
within x = (3, 9)
after x = 9
after x = 3
(3, 9)
```


### Monoid/Alternative

ContextManager only supports Functor/Applicative/Monad TypeClasses.


### FlipTypes

ContextManager only supports Functor/Applicative/Monad TypeClasses.



## AbstractVector

`Base.Vector` are supported. More concretely, methods are implemented for the whole `AbstractArray` tree, by converting from `Vector`.
Vector types can be seamlessly combined with `Either` (including `Options` and `Try`), providing a very flexible setup out-of-the-box.
`Either` types get converted to singleton lists in the case of `Identity` or an empty list in the case of `Const`.

### Functor/Applicative/Monad

The implementation of `TypeClasses.flatmap` follows the flattening/combining semantics, which takes all combinations of the vectors. As if you would have used for loops, however with constructing a result by collecting everything.

```jldoctest
julia> @syntax_flatmap begin
         a = [1, 2]
         b = [:x, :y]
         @pure a, b
         end
4-element Vector{Tuple{Int64, Symbol}}:
 (1, :x)
 (1, :y)
 (2, :x)
 (2, :y)

julia> @syntax_flatmap begin
         a = [1, 2, 3, 4, 5]
         @pure b = a + 1
         c = iftrue(a % 2 == 0) do
           a + b
         end
         @Try @assert a > 3
         @pure @show a, b, c
       end
(a, b, c) = (4, 5, 9)
1-element Vector{Any}:
 (4, 5, 9)
```

Sometimes it may also be handy to use the `pure` function.

```jldoctest
julia> pure(Vector, 1)
1-element Vector{Int64}:
 1
```


### Monoid/Alternative

Vectors only support Monoid interface, no Alternative.

```jldoctest
julia> neutral(Vector)
Any[]

julia> [1] ⊕ [5,6]
3-element Vector{Int64}:
 1
 5
 6

julia> combine([1], [5, 6])
3-element Vector{Int64}:
 1
 5
 6

julia> foldl_monoid([[1,2], [4,5], [10]])
5-element Vector{Int64}:
  1
  2
  4
  5
 10
```

### FlipTypes

You can flip nested types with `Vector`. It assumes the inner type supports Applicative method `ap` (if you have defined `flatmap` the `ap` method is automatically defined for you).

```jldoctest
julia> flip_types([Option(1), Option("2"), Option(:three)])
Identity(Any[1, "2", :three])

julia> flip_types([Option(1), Option(), Option(:three)])
Const(nothing)
```

Remember that flip_types usually forgets information, like here in the case when a `Const` is found.


## Dict

We do not support `AbstractDict` in general, because there is no common way of constructing such dicts. For the concrete `Base.Dict` we know how to construct it.

### Functor/Applicative/Monad

`Base.map` explicitly throws an error on `Dict`, so there is no way to support Functor/Applicative/Monad typeclasses.

### Monoid/Alternative

`neutral` for Dict just returns a general empty Dict
```jldoctest
julia> neutral(Dict)
Dict{Any, Any}() 
```

`combine` (`⊕`) will forward the function call `combine` to its elements. `orelse` (`⊘`) will take the first existing value, i.e. a flipped version of merge.
```jldoctest
julia> d1 = Dict(:a => "3", :b => "1")
Dict{Symbol, String} with 2 entries:
  :a => "3"
  :b => "1"

julia> d2 = Dict(:a => "5", :b => "9", :c => "15")
Dict{Symbol, String} with 3 entries:
  :a => "5"
  :b => "9"
  :c => "15"

julia> d1 ⊕ d2
Dict{Symbol, String} with 3 entries:
  :a => "35"
  :b => "19"
  :c => "15"

julia> d1 ⊘ d2
Dict{Symbol, String} with 3 entries:
  :a => "3"
  :b => "1"
  :c => "15"
```

### FlipTypes

`flip_types` works only in one direction.

```jldoctest
julia> flip_types(Dict(:a => [1,2], :b => [3, 4])) 
4-element Vector{Dict{Symbol, Int64}}:
 Dict(:a => 1, :b => 3)
 Dict(:a => 1, :b => 4)
 Dict(:a => 2, :b => 3)
 Dict(:a => 2, :b => 4)

julia> flip_types([Dict(:a => 1, :b => 3), Dict(:a => 2, :b => 4)])
ERROR: map is not defined on dictionaries
```
As you see, this is becaue `Base.map` explicitly throws an Error for `Base.Dict`.


## AbstractDictionary

Luckily this limitation of `Base.Dict` can be circumvented by using the package `Dictionaries` which enhances the dictionary interface and speeds up its performance.

### Functor/Applicative/Monad

`AbstractDictionary` is the abstract type provided by the package, and it already defines `Base.map` for it, so that we can implement Functor/Applicative/Monad interfaces on top. The semantics of the flattening of dictionaries follows the implementation in Scala Cats for Scala's Map type. It works like first filtering for common keys and then doing stuff respectively.

```jldoctest
julia> using Dictionaries

julia> dict = Dictionary(["a", "b", "c"], [1, 2, 3])
3-element Dictionaries.Dictionary{String, Int64}
 "a" │ 1
 "b" │ 2
 "c" │ 3

julia> create_dictionary(x) = Dictionary(["b", "c", "d"], [10x, 20x, 30x])
create_dictionary (generic function with 1 method)

julia> @syntax_flatmap begin
         a = dict
         b = create_dictionary(a)
         @pure a, b
         end
2-element Dictionaries.Dictionary{String, Tuple{Int64, Int64}}
 "b" │ (2, 20)
 "c" │ (3, 60)
```

20 is 10 times 2, and 60 is 20 times 3. You see it picks the right values for "b" and "c" respectively. The key "d" does not exist in all dictionaries and hence is filtered out.

### Monoid/Alternative

The implementation for `neutral`, `combine` and `orelse` are analogous to those for `Dict`, just a bit more abstract. Thanks to the good interfaces defined in the package `Dictionaries`, we can support general `AbstractDictionary`.

### FlipTypes

`flip_types` now actually works in both directions, as `AbstractDictionary` is a Monad itself.

```jldoctest
julia> flip_types(dictionary((:a => [1,2], :b => [3, 4]))) 
4-element Vector{Dictionary{Symbol, Int64}}:
 {:a = 1, :b = 3}
 {:a = 1, :b = 4}
 {:a = 2, :b = 3}
 {:a = 2, :b = 4}

julia> flip_types([
           dictionary((:a => 1, :b => 2)),
           dictionary((:a => 10, :b => 20)),
           dictionary((:b => 200, :c => 300))
       ])
1-element Dictionaries.Dictionary{Symbol, Vector{Int64}}
 :b │ [2, 20, 200]
```

In the last example you can again recognize the filtering logic. Here it leaves `:b` as the only valid key.


## Iterable

TypeClasses exports a wrapper type called `Iterable` which can be used to enable support on any iterable. 

### Functor/Applicative/Monad

```jldoctest
julia> collect(@syntax_flatmap begin
         a = Iterable(1:2)
         b = Iterable([3,6])
         @pure a, b
       end)
4-element Vector{Tuple{Int64, Int64}}:
 (1, 3)
 (1, 6)
 (2, 3)
 (2, 6)
```

The `@syntax_flatmap` macro actually can receive a wrapper function as an additional first argument with which the above can be written as

```jldoctest
julia> collect(@syntax_flatmap Iterable begin
         a = 1:2
         b = [3,6]
         @pure a, b
       end)
4-element Vector{Tuple{Int64, Int64}}:
 (1, 3)
 (1, 6)
 (2, 3)
 (2, 6)
```

You can use `TypeClasses.pure` to construct singleton Iterables
```jldoctest
julia> pure(Iterable, 1)
Iterable{TypeClasses.DataTypes.Iterables.IterateSingleton{Int64}}(TypeClasses.DataTypes.Iterables.IterateSingleton{Int64}(1))
```
It wraps an internal type which really just supports the singleton Iterable for your convenience.


### Monoid/Alternative

`Iterable` defines only the Monoid interface, just like Vector, but lazy.

```jldoctest
julia> Iterable(1:2) ⊕ Iterable(5:6)
Iterable{Base.Iterators.Flatten{Tuple{UnitRange{Int64}, UnitRange{Int64}}}}(Base.Iterators.Flatten{Tuple{UnitRange{Int64}, UnitRange{Int64}}}((1:2, 5:6)))

julia> collect(Iterable(1:2) ⊕ Iterable(5:6))
4-element Vector{Int64}:
 1
 2
 5
 6
```

For implementing the `neutral` function, an extra type for an empty iterator was defined within TypeClasses. It is itself not exported, because using `neutral` instead is simpler and better.

```jldoctest
julia> neutral(Iterable)
Iterable{TypeClasses.DataTypes.Iterables.IterateEmpty{Union{}}}(TypeClasses.DataTypes.Iterables.IterateEmpty{Union{}}())

julia> collect(neutral(Iterable))
Union{}[]
```
The element-type is `Union{}` to be easily type-joined with other iterables and element-types.


### FlipTypes

Again similar to Vector, Iterables define `flip_types` in a lazy style.


```jldoctest
julia> it = Iterable(Option(i) for i ∈ [1, 4, 7])
Iterable{Base.Generator{Vector{Int64}, Type{Option{T} where T}}}(Base.Generator{Vector{Int64}, Type{Option{T} where T}}(Option{T} where T, [1, 4, 7]))

julia> flip_types(it)
Identity(Iterable{Base.Iterators.Flatten{Tuple{Base.Iterators.Flatten{Tuple{TypeClasses.DataTypes.Iterables.IterateSingleton{Int64}, TypeClasses.DataTypes.Iterables.IterateSingleton{Int64}}}, TypeClasses.DataTypes.Iterables.IterateSingleton{Int64}}}}(Base.Iterators.Flatten{Tuple{Base.Iterators.Flatten{Tuple{TypeClasses.DataTypes.Iterables.IterateSingleton{Int64}, TypeClasses.DataTypes.Iterables.IterateSingleton{Int64}}}, TypeClasses.DataTypes.Iterables.IterateSingleton{Int64}}}((Base.Iterators.Flatten{Tuple{TypeClasses.DataTypes.Iterables.IterateSingleton{Int64}, TypeClasses.DataTypes.Iterables.IterateSingleton{Int64}}}((TypeClasses.DataTypes.Iterables.IterateSingleton{Int64}(1), TypeClasses.DataTypes.Iterables.IterateSingleton{Int64}(4))), TypeClasses.DataTypes.Iterables.IterateSingleton{Int64}(7)))))

julia> map(collect, flip_types(it))
Identity([1, 4, 7])
```


## Callable

We also provide a wrapper for functions. To enable support for your functions, just wrap them into `Callable`.

### Functor/Applicative/Monad

The callable monad is also sometimes called reader monad, however in Julia context that name doesn't make much sense. At least you heard it and can connect the concepts.

```jldoctest
julia> func = @syntax_flatmap begin
         a = Callable(x -> x * 10)
         b = Callable(x -> x * 100 )
         Callable() do x
           x + a + b
         end
       end;

julia> func(2)
222
```

Similar as for Iterables, it may simplify your setup to add `Callable` as a wrapper-function to `@syntax_flatmap`
```jldoctest
julia> func = @syntax_flatmap Callable begin
         # you need to use anonymous functions, as the equal sign `=` is rewritten by the macro
         a = x -> x * 10
         b = x -> x * 100
         identity() do x
           x + a + b
         end
       end;

julia> func(3)
333
```

You can also wrap a value into `Callable` using `pure`. It works like a constant function.
```jldoctest
julia> pure(Callable, 1)()
1

julia> pure(Callable, 1)("any", :arguments, key=4)
1
```

### Monoid/Alternative

`Callables` implement only `combine` by forwarding it to its elements.

```jldoctest
julia> a = Callable(x -> "hello $x");

julia> b = Callable(x -> "!");

julia> (a ⊕ b)(:Albert)
"hello Albert!"
```


### FlipTypes

Callable itself does not implement `flip_types` as it would need to know its arguments in advance, which of course is impossible.
However because it implements Monad interface, we can use it as a nested type within another type and get it out.

```jldoctest
julia> a = Callable.([x -> x, y -> 2y, z -> z*z]);

julia> flip_types(a)(3)
3-element Vector{Int64}:
 3
 6
 9
```


## `@spawnat` and `@async`

`@async` runs the computation in another thread, `@spawnat` runs it on another machine potentially. Both are supported by TypeClasses.

`@async` are described by `Task` objects, `@spawnat` by `Distributed.Future` respectively. Both kinds of contexts can be evaluated/run with `Base.fetch`.

### Functor/Applicative/Monad

```jldoctest taskfuture
julia> wait_a_little(f::Function, seconds=0.3) = @async begin
         sleep(seconds)
         f()
       end
wait_a_little (generic function with 2 methods)

julia> wait_a_little(x, seconds=0.3) = wait_a_little(() -> x, seconds)
wait_a_little (generic function with 4 methods)

julia> squared = map(wait_a_little(4)) do x
         x*x
       end;  # returns a Task

julia> fetch(squared)
16

julia> fetch(mapn(+, wait_a_little(11), wait_a_little(12)))
23

julia> monadic = @syntax_flatmap begin
         a = wait_a_little(5)
         b = wait_a_little(a + 3)
         @pure a, b
       end;  # returns a Task

julia> fetch(monadic)
(5, 8)
```

You can do the very same using `@spawnat`, i.e. the type `Distributed.Future`. Just use the following function instead.
```julia
using Distributed

wait_a_little(f::Function, seconds=0.3) = @spawnat :any begin
  sleep(seconds)
  f()
end
```


You can put any value into a `Task` and `Future` object by using `TypeClasses.pure`. You get it out again with `Base.fetch`.
```jldoctest
julia> fetch(pure(Task, 4))
4

julia> using Distributed

julia> fetch(pure(Future, "a"))
"a"
```

### Monoid/Alternative

Future and Task do not implement `neutral`.

`combine` is forwarded to the computation results.

```jldoctest taskfuture
julia> fetch(wait_a_little("hello.") ⊕ wait_a_little("world."))
"hello.world."
```

`orelse` is defined as the Alternative semantics of running multiple threads in parallel and taking the faster one.

```jldoctest taskfuture
julia> fetch(wait_a_little(:a, 1.0) ⊘ wait_a_little(:b, 2.0))
:a

julia> fetch(wait_a_little(:a, 3.0) ⊘ wait_a_little(:b, 2.0))
:b

julia> fetch(wait_a_little(() -> error("fails"), 0.1) ⊘ wait_a_little(:succeeds, 0.3))
:succeeds

julia> fetch(wait_a_little(:succeeds, 0.3) ⊘ wait_a_little(() -> error("fails"), 0.1))
:succeeds
```

In case all different paths fail, all errors are collected into an `MultipleExceptions` object
```julia taskfuture
julia> fetch(wait_a_little(() -> error("fails1")) ⊘ wait_a_little(() -> error("fails2")) ⊘ wait_a_little(() -> error("fails3")) ⊘ wait_a_little(() -> error("fails4")))
ERROR: TaskFailedException
Stacktrace:
 [1] wait
   @ ./task.jl:322 [inlined]
 [2] fetch(t::Task)
   @ Base ./task.jl:337
 [3] top-level scope
   @ REPL[56]:1

    nested task error: MultipleExceptions{NTuple{4, Thrown{TaskFailedException}}}((Thrown(TaskFailedException(Task (failed) @0x00007f5c8633af50)), Thrown(TaskFailedException(Task (failed) @0x00007f5c8633b0a0)), Thrown(TaskFailedException(Task (failed) @0x00007f5c864382b0)), Thrown(TaskFailedException(Task (failed) @0x00007f5c86438550))))
```


You can do the very same using `@spawnat`, i.e. the type `Distributed.Future`. Just use the following function instead.
```julia
using Distributed

wait_a_little(f::Function, seconds=0.3) = @spawnat :any begin
  sleep(seconds)
  f()
end
```

Note that a fetch on a Future will RETURN an RemoteException object instead of throwing an error.
```julia
julia> fetch(wait_a_little(() -> error("fails1")) ⊘ wait_a_little(() -> error("fails2")) ⊘ wait_a_little(() -> error("fails3")) ⊘ wait_a_little(() -> error("fails4")))
RemoteException(1, CapturedException(MultipleExceptions{NTuple{4, RemoteException}}((RemoteException(1, CapturedException(ErrorException("fails1"), [...]
```

### FlipTypes

Implementing `flip_types` does not make much sense for `Task` and `Future`, as this would need to execute the Task, and map over its returned value, finally creating a bunch of dummy Tasks within it. `@async` and `@spawnat` are really meant to be lazy constructions.


## Writer

The `Writer{Accumulator, Value}` monad stores logs or other intermediate outputs. It is like `Base.Pair{Accumulator, Value}`, with the added assumption that `Accumulator` implements the `TypeClasses.combine`. Also the `eltype` of a `Writer` corresponds to the element-type of the `Value`.

### Functor/Applicative/Monad

You can use the writer to implicitly accumulate any Semigroup or Monoid
```jldoctest
julia> @syntax_flatmap begin
         a = pure(Writer{String}, 5)
         Writer("first.")
         b = Writer("second.", a*a)
         @pure a, b
       end
Writer{String, Tuple{Int64, Int64}}("first.second.", (5, 25))
```

In case you only have a Semigroup, just wrap it into `Option`, the default `TypeClasses.pure` implementation for writer will use `Option()` internally.
```jldoctest
julia> @syntax_flatmap begin
         a = pure(Writer, 5)
         Writer(Option("hi"))
         @pure a
       end
Writer{Identity{String}, Int64}(Identity("hi"), 5)
```

### Monoid/Alternative

`neutral` and `combine` will foward the call to `neutral` and `combine` onto the element-types (for `neutral`) or the concrete element-values (for `combine`).

```jldoctest
julia> neutral(Writer{Option, Vector})
Const(nothing) => Any[]

julia> Writer("one.", [1,2]) ⊕ Writer("two.", [3,4]) ⊕ Writer("three.", [5])
Writer{String, Vector{Int64}}("one.two.three.", [1, 2, 3, 4, 5])

julia> Writer("hello.") ⊕ Writer("world.")  # the single argument constructor is just for logging, however as `nothing` always combines, this works too
Writer{String, Nothing}("hello.world.", nothing)
```

We don't implement `orelse`, as it is commonly meant on container level, but there is no obvious failure semantics here.


### FlipTypes

`Writer` supports `flip_types` by duplicating the accumulator respectively. 

```jldoctest
julia> flip_types(Writer("accumulator", [1, 2, 3]))
3-element Vector{Writer{String, Int64}}:
 Writer{String, Int64}("accumulator", 1)
 Writer{String, Int64}("accumulator", 2)
 Writer{String, Int64}("accumulator", 3)
```

Used within another FlipTypes, `Writer` just accumulates the accumulator.
```jldoctest
julia> flip_types([ Writer("one.", 1), Writer("two.", 2), Writer("three.", 3) ])
Writer{String, Vector{Int64}}("one.two.three.", [1, 2, 3])
```

## Pair/Tuple

Pair and Tuple have no Monad instances, but we support `combine` and `neutral` by forwarding the calls to its elements

### Functor/Applicative/Monad

No implementation. Please see [Writer](@ref) instead.

### Monoid/Alternative

```jldoctest
julia> ("hello." => [1,2]) ⊕ ("world." => [3])
"hello.world." => [1, 2, 3]

julia> ("hello.", [1,2], Dict(:a => "one.")) ⊕ ("world.", [3], Dict(:a => "two."))
("hello.world.", [1, 2, 3], Dict(:a => "one.two."))

julia> neutral(Pair{String, Vector})
"" => Any[]

julia> neutral(Tuple{String, Vector})
("", Any[])

julia> neutral(Tuple{String})
("",)
```

### FlipTypes

No implementation. Please see [Writer](@ref) instead.


## State

With the `State` monad you can hide the modification of some external variable. In Julia you can modify variables by side-effect, hence this State monad is rather for illustrative purposes only. However if you like to have tight control over your state or config, you can give it a try.

### Functor/Applicative/Monad

You can lift an arbitrary value into a  `State` with `TypeClasses.pure`. It won't do anything with the state.

```jldoctest
julia> run(pure(State, "returnvalue"), :initialstate)
("returnvalue", :initialstate)
```

If you want to change the state, use `TypeClasses.putstate`, and if you want to access the state itself, you can use `TypeClasses.getstate`.
For the general case you can construct `State` by passing a function taking the state as its only input argument, and returning result value and new state in a tuple.
```jldoctest
julia> putget = @syntax_flatmap begin
         putstate(4)
         x = getstate
         State(s -> ("x = $x", s+1))
       end;

julia> value, state = putget(())
("x = 4", 5)
```

### Monoid/Alternative

State only supports `combine` by forwarding it to its inner element. The state is passed from the first to the second.
```jldoctest
julia> state1 = State(s -> ("one.", s*s));

julia> state2 = State(s -> ("two.", 2s));

julia> run(state1 ⊕ state2, 3)
("one.two.", 18)

julia> run(state2 ⊕ state1, 3)
("two.one.", 36)
```

### FlipTypes

There is no implementation for `flip_types`, as you would need to look inside the `State` and wrap it out. That is hidden behind a function which depends on the state, so no way to bring things inside-out without such a state.
