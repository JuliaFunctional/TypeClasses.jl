# Welcome

TypeClasses defines general programmatic abstractions taken from Scala cats and Haskell TypeClasses.

# TODO describe how easy it is to define a flip_types definition for custom types


# Design Decisions

## No dispatch on `eltype`

With Functors and the like a typical thing you want to do is to get to know more about the inner type, i.e. the `eltype`. It turns out this is unwanted.

Julia's type-inference is seriously incomplete and there is also no sign that this will ever change. The compiler tries very hard to always infer the maximal specific type, but may fallback to more generic types if unsure or because of time-constraints. A calculation which may build up a `Vector{Number}` may easily turn out as a `Vector{Any}`, and even for a method returning `Vector{String}`, the underlying code may be that dynamic in nature, that the compiler just cannot infer the type and will return `Vector{Any}`. The take home message here is that, practically, `eltype` is an instable function. It's concrete behaviour, somewhere within a nested stack of function calls, may change between versions, depending on changing undocumented compiler-heuristics, or may even change because another layer of abstractions is added somewhere within the nested calls, which again triggers different compiler-heuristics.

If you dispatch on `Vector{Number}` in order to implement something specific for Number, that may fail to catch the Vector{Number} which was interpreted as `Vector{Any}` because of approximate type inference. You need to make sure that the semantics of the method for `Vector{Any}` is actually identical to the specialised version `Vector{Number}`. You should only ever do performance optimisations when dispatching on `eltype`, never base your semantics on `eltype`.

With Functors, specifically with Monads, we have exactly the setting where we may dispatch on `eltype` to define different semantics. They key reason is that there are a couple of Monads where you cannot inspect the concrete elements, for instance `Callable` where the element is hidden behind an arbitrary function. Hence you may not be able to implement a function for `Callable{Any}` in a sensible way, while it actually is well-defined for `Callable{Callable}`. That is not Julia.

Another example is the typeclass `neutral`. It turns out you can define `neutral` for each `Applicative` which ElementType itself implements `neutral`. It is really tempting to define the generic implementation for Applicatives, dispatching on `eltype`... Instead we provide specific applicative versions `neutral_applicative` and `combine_applicative` which assume the elements comply to the `Neutral` and `Semigroup` interface respectively. Similar for `absorbing` and `orelse`.

As we cannot safely dispatch on `eltype`, the Julia way is to just assume your ElementType has the characteristics needed for your function, i.e. use duck-typing instead of dispatch. Naturally, this will work for all containers with the right elements. And in case the elements do not implement the required interfaces, it will fail with a well self-explaining `MethodError`. This you can then debug which will bring you directly to the place where you can inspect the elements in detail.


### No `change_eltype` function

During the development of this package we initially used a further function, quite related to `eltype`, called `change_eltype`. It took a container type like `Vector` and tried to change its ElementType, e.g. `change_eltype(Vector{Int}, String) == Vector{String}`. While this may seem intuitively reasonable for example to define `isAp`, namely to check whether for some Container `Container` the key function `ap` is defined for `ap(::Container{Function}, ::Container)`, this is a version of dispatching on `eltype` and hence should be avoided.

The resolution is that we assume `ap` is always overloaded with the first argument being of the general Container-type, i.e. without any restrictions to the eltype.
