using Monadic
using ExprParsers
import Base: foreach, map, eltype

"""
  foreach(f, functor)

Like map, but destroying the context. I.e. makes only sense for functions with side effects

map, flatmap and foreach should have same semantics.

Note that this does not work for all Functors (e.g. not for Callables), however is handy in many cases.
This is also the reason why we don't use the default fallback to map, as this may make no sense for your custom Functor.
"""

"""
    isForeach(type)
    isForeach(value) = isForeach(typeof(value))

trait for checking whether a given Type defines `Base.foreach`
"""
isForeach(T::Type) = error("Could not find definition for `TypeClasses.isForeach(::Type{$T})`. Please define it.")
isForeach(value) = isForeach(typeof(value))

"""
    @syntax_foreach begin
      # Vectors behaves like nested for loops within @syntax_foreach
      a = [1, 2, 3]
      b = [10, 20]
      @pure a + b
    end
    # [[11, 21], [12, 22], [13, 23]]

This is a variant of the monadic syntax which uses `foreach` for both map_like and flatmap_like.
See `Monadic.@monadic` for more details.
"""
macro syntax_foreach(block::Expr)
  block = macroexpand(__module__, block)
  esc(monadic(:(TypeClasses.foreach), :(TypeClasses.foreach), block))
end
macro syntax_foreach(wrapper, block::Expr)
  block = macroexpand(__module__, block)
  esc(monadic(:(TypeClasses.foreach), :(TypeClasses.foreach), wrapper, block))
end


# Functor
# =======

"""
  map(f, functor)

The core functionality of a functor, applying a normal function "into" the context defined by the functor.
Think of map and vector as best examples.
"""

"""
    isMap(type)
    isMap(value) = isMap(typeof(value))
    isFunctor(type)
    isFunctor(value) = isFunctor(typeof(value))

trait for checking whether a given Type defines `Base.map`
"""
isMap(T::Type) = error("Could not find definition for `TypeClasses.isMap(::Type{$T})`. Please define it.")
isMap(value) = isMap(typeof(value))
const isFunctor = isMap


"""
    @syntax_map begin
      # Vectors behave similar to nested for loops within @syntax_map
      a = [1, 2, 3]
      b = [10, 20]
      @pure a + b
    end
    # [[11, 21], [12, 22], [13, 23]]

This is a variant of the monadic syntax which uses `map` for both map_like and flatmap_like.
See `Monadic.@monadic` for more details.
"""
macro syntax_map(block::Expr)
  block = macroexpand(__module__, block)
  esc(monadic(:(TypeClasses.map), :(TypeClasses.map), block))
end
macro syntax_map(wrapper, block::Expr)
  esc(monadic(:(TypeClasses.map), :(TypeClasses.map), wrapper, block))
end


# Applicative
# ===========

"""
  pure(T::Type, a)

wraps value a into container T
"""
function pure end

"""
    isPure(type)
    isPure(value) = isPure(typeof(value))

trait for checking whether a given Type defines `TypeClasses.pure`
"""
isPure(T::Type) = error("Could not find definition for `TypeClasses.isPure(::Type{$T})`. Please define it.")
isPure(value) = isPure(typeof(value))

"""
  ap(f::F1, a::F2)

apply function in container F1 to element in container F2
"""
function ap end

"""
    isAp(type)
    isAp(value) = isAp(typeof(value))
    isMapN(type)
    isMapN(value) = isMapN(typeof(value))

trait for checking whether a given Type defines `TypeClasses.ap`
"""
isAp(T::Type) = error("Could not find definition for `TypeClasses.isAp(::Type{$T})`. Please define it.")
isAp(a) = isAp(typeof(a))
const isMapN = isAp  # alias because `mapn` is actually equal in power to `ap`, but more self explanatory and more used


"""
    isApplicative(type)
    isApplicative(value) = isApplicative(typeof(value))

combining traits [`TypeClasses.isMap`](@ref), [`TypeClasses.isPure`](@ref) and [`TypeClasses.isAp`](@ref)
"""
isApplicative(a) = isFunctor(T) && isPure(T) && isAp(T)

# basic functionality
# -------------------

"""
    @mapn f(a, b, c, d)

translates to

    mapn(f, a, b, c, d)
"""
macro mapn(call_expr)
  parsed = parse_expr(EP.Call(), call_expr)
  @assert isempty(parsed.kwargs) "mapn does not support keyword arguments, but found $(parsed.kwargs)."
  callee = if isempty(parsed.curlies)
    parsed.name
  else
    :($(parsed.name){($(parsed.curlies...))})
  end
  esc(:(TypeClasses.mapn($callee, $(parsed.args...))))
end

# generic implementation, looping over the arguments
# - - - - - - - - - - - - - - - - - - - - - - - - - -

# because of world problem we cannot call eval in curry (see e.g. https://discourse.julialang.org/t/running-in-world-age-x-while-current-world-is-y-errors/5871/3)
# hence we define it logically by collecting all args
function curry(func, n::Int)
  function h(x, prev_xs)
    new_xs = tuple(prev_xs..., x)
    if length(new_xs) == n
      func(new_xs...)
    else
      x -> h(x, new_xs)
    end
  end
  x -> h(x, ())
end

"""
  apply a function over applicative contexts instead of plain values
"""
# Note that the try to make this a generative function failed because of erros like
# """ERROR: The function body AST defined by this @generated function is not pure. This likely means it contains a closure or comprehension."""
function mapn(func, args...)
  n = length(args)
  if n == 0
    error("mapn is not defined for 0 args as the type T needed for pure(T, x) is not known")
  else
    cfunc = curry(func, n)
    Base.foldl((f, a) -> ap(f, a), args[2:end]; init = map(cfunc, args[1]))
  end
end


# specifically compiled versions
# - - - - - - - - - - - - - - -

# We compile specific versions for specific numbers of arguments via code generation.
# Tests showed that this leads way more optimal code.
# Note, that it is not possible to do this with generated functions, as the resulting expression needs to curry
# the function, which requires closures, however they are not supported within generated function bodies.

function _create_curried_expr(func, N::Int)
  args_symbols = Symbol.(:a, 1:N)
  final_call = :($func($(args_symbols...)))
  foldr(args_symbols, init=final_call) do a, subfunc
    :($a -> $subfunc)
  end
end
function _create_ap_expr(curried_func, args_symbols)
  @assert length(args_symbols) >= 1
  first_applied = :(map($curried_func, $(args_symbols[1])))
  foldl(args_symbols[2:end], init=first_applied) do partially_applied, a
    :(ap($partially_applied, $a))
  end
end

for N in 1:128  # 128 is an arbitrary number
  func_name = :func
  args_symbols = Symbol.(:a, 1:N)
  curried_func_name = :curried_func
  curried_func_expr = _create_curried_expr(func_name, N)
  ap_expr = _create_ap_expr(curried_func_name, args_symbols)
  @eval function mapn($func_name, $(args_symbols...))
    $curried_func_name = $curried_func_expr
    $ap_expr
  end
end

# common applications of mapn
# - - - - - - - - - - - - - -

"""
    tupled(Option(1), Option(2), Option(3)) == Option((1,2,3))
    tupled(Option(1), None, Option(3)) == None

Combine several Applicative contexts by building up a Tuple
"""
function tupled(applicatives...)
  mapn(tuple, applicatives...)
end


# default implementations
# -----------------------

# default implementations collide to often with other traits definitions and rather do harm than good
# hence we just give a default definition which can be used for custom definitions
default_map_having_ap_pure(f, a::A) where {A} = ap(pure(A, f), a)



# generic Monoid implementations for Applicative
# ----------------------------------------------

# isApplicative(T) && isMonoid(eltype(T)) -> isMonoid(T)

# it is tempting to overload `neutral`, `combine` and so forth directly,
# however dispatching on eltype is not allowed if used for different semantics,

function neutral_applicative(T::Type)
  pure(T, neutral(eltype(T)))
end

function combine_applicative(a, b)
  mapn(⊕, a, b)
end

function absorbing_applicative(T::Type)
  pure(T, absorbing(eltype(T)))
end

function orelse_applicative(a, b)
  mapn(orelse, a, b)
end


# Monad
# =====

# we use flatmap instead of flatten as the default function, because of the following reasons:
# - flatmap has a similar signature as map and ap, and hence should fit more intuitively into the overal picture for beginners
# - flatmap is what is most often used in e.g. `@syntax_flatmap`, and hence this should optimal code
# - flatten seams to have more information about the nested types, however as julia's typeinference is incomplete
#     and may not correctly infer subtypes, it is actually quite tricky to dispatch correctly on nested typevariables.
#     Concretely you want the functionality to not differ whether typeinference worked or not, and hence you have
#     To deal with Vector{Any} and similar missing typeinformation on the typeparameters. You can fix the types,
#     but you always have to be careful that you do so.
#     And of course this approach only works for containers where you actually have a proper `eltype`.
#     A last point to raise is that not dispatching on nested Functors prevents the possibility of flattening
#     multiple different Functors. This is partly, however the same result can be achieved much better using
#     ExtensibleEffects.
#     Hence we don't see any real use of complex nested dispatch any longer and recommend rather not to use it
#     because of the unintuitive complexity.

"""
    flatmap(function_returning_A, a::A)::A

`flatmap` applies a function to a container and immediately flattens it out.
While map would give you `A{A{...}}`, flatmap gives you a plain `A{...}`, without any nesting.

If you define your own versions of flatmap, the recommendation is to apply a `Base.convert` after applying `f`.
This makes sure your flatmap is typesafe, and actually enables sound interactions with other types which may be
convertable to your A.

E.g. for Vector the implementation looks as follows:
```
TypeClasses.flatmap(f, v::Vector) = vcat((convert(Vector, f(x)) for x in v)...)
```
"""
function flatmap end


"""
    isFlatMap(type)
    isFlatMap(value) = isFlatMap(typeof(value))
    isFlatten(type)
    isFlatten(value) = isFlatten(typeof(value))

trait for checking whether a given Type defines `TypeClasses.isFlatMap`
"""
isFlatMap(T::Type) = error("Could not find definition for `TypeClasses.isFlatMap(::Type{$T})`. Please define it.")
isFlatMap(a) = isFlatMap(typeof(a))

const isFlatten = isFlatMap

"""
    isMonad(type)
    isMonad(value) = isMonad(typeof(value))

combining traits [`TypeClasses.isMap`](@ref), [`TypeClasses.isPure`](@ref), [`TypeClasses.isAp`](@ref) (which together make up [`isApplicative`](@ref)), and in addition also [`isFlatMap`](@ref).
"""
isMonad(a) = isApplicative(a) && isFlatMap(a)

# basic functionality
# -------------------

"""
    flatten(::A{A})::A = flatmap(identity, a)

`flatten` gets rid of one level of nesting. Has a default fallback to use `flatmap`.
"""
flatten(a) = flatmap(identity, a)

"""
    @syntax_flatmap begin
      # Vector behave similar to nested for loops within @syntax_flatmap
      a = [1, 2, 3]
      b = [10, 20]
      @pure a + b
    end
    # [11, 21, 12, 22, 13, 23]

This is the standard monadic syntax which uses `map` for map_like and `flatmap` for flatmap_like.
See `Monadic.@monadic` for more details.
"""
macro syntax_flatmap(block::Expr)
  block = macroexpand(__module__, block)
  esc(monadic(:(TypeClasses.map), :(TypeClasses.flatmap), block))
end
macro syntax_flatmap(wrapper, block::Expr)
  block = macroexpand(__module__, block)
  esc(monadic(:(TypeClasses.map), :(TypeClasses.flatmap), wrapper, block))
end


# Now can define the fallback definition for ap with monad style
# ==============================================================

# we don't overwrite `ap` directly because it can easily conflict with custom definitions
# instead it is offered as a default definition which you can use for your custom type

# for monadic code we actually don't need Pure
default_ap_having_map_flatmap(f, a) = @syntax_flatmap begin
  f = f
  a = a
  @pure f(a)
end
