using Traits
using Monadic
using ASTParser
using IsDef
import FunctionWrappers: FunctionWrapper

"""
  foreach(f, functor)

Like map, but destroying the context. I.e. makes only sense for functions with side effects

map, flatmap and foreach should have same semantics.

Note that this does not work for all Functors (e.g. not for Callables), however is handy in many cases.
This is also the reason why we don't use the default fallback to map, as this may make no sense for your custom Functor.
"""
const foreach = Base.foreach
isForeach(T::Type) = isdef(foreach, typeof(identity), T)
isForeach(a) = isForeach(typeof(a))

"""
    @syntax_foreach begin
      # Vectors behaves like nested for loops within @syntax_foreach
      a = [1, 2, 3]
      b = [10, 20]
      @pure a + b
    end
    # [[11, 21], [12, 22], [13, 23]]

This is a variant of the monadic syntax which uses ``foreach`` for both map_like and flatmap_like.
See ``Monadic.@monadic`` for more details.
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
const map = Base.map
isMap(T::Type) = isdef(map, typeof(identity), T)  # we check for a concrete function to have better typeinference
isMap(value) = isMap(typeof(value))
const isFunctor = isMap

"""
  eltype(functor)

return the type of the functor "element"
"""
const eltype = Base.eltype
# we don't need isEltype, as Base.eltype has a default returning Any

"""
  change_eltype(FunctorType::Type, NewElementType::Type)
  FunctorType ⫙ NewElementType

return new type with inner element changed
"""
function change_eltype end
const ⫙ = change_eltype

# advanced default implementation using https://discourse.julialang.org/t/how-can-i-create-a-function-type-with-custom-input-and-output-type/31719
change_eltype(T::Type, E) = Out(map, FunctionWrapper{E, Tuple{Any}}, T)


"""
    @syntax_map begin
      # Vectors behave similar to nested for loops within @syntax_map
      a = [1, 2, 3]
      b = [10, 20]
      @pure a + b
    end
    # [[11, 21], [12, 22], [13, 23]]

This is a variant of the monadic syntax which uses ``map`` for both map_like and flatmap_like.
See ``Monadic.@monadic`` for more details.
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

isPure(T::Type) = isdef(pure, Type{T}, Any)
isPure(a) = isPure(typeof(a))

"""
  ap(f::F1, a::F2)

apply function in container F1 to element in container F2
"""
function ap end
isAp(T::Type) = isdef(ap, change_eltype(T, Function), T)
isAp(a) = isAp(typeof(a))
const isMapN = isAp  # alias because `mapn` is actually equal in power to `ap`, but more self explanatory and more used

function isApplicative(T::Type)
  isFunctor(T) && isPure(T) && isAp(T)
end
isApplicative(a) = isApplicative(typeof(a))

# basic functionality
# -------------------

"""
    @mapn f(a, b, c, d)

translates to

    mapn(f, a, b, c, d)
"""
macro mapn(call_expr)
  parsed = Parsers.Call()(call_expr)
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
# hence we just give a default definition to use for custom definitions
default_map_having_ap_pure(f, a::A) where {A} = ap(pure(A, f), a)



# generic Monoid implementations for Applicative
# ----------------------------------------------

# isApplicative(T) && isMonoid(eltype(T)) -> isMonoid(T)
# TODO do this interact dangerously with other definitions?

@traits function neutral(a::T) where {T, isPure(T), isNeutral(eltype(T))}
  pure(T, neutral(eltype(T)))
end

@traits function combine(a::T1, b::T2) where {T1, T2, isAp(T1 ∨ T2), isCombine(eltype(T1 ∨ T2))}
  mapn(⊕, a, b)
end

@traits function absorbing(a::T) where {T, isPure(T), isAbsorbing(eltype(T))}
  pure(T, absorbing(eltype(T)))
end

@traits function orelse(a::T1, b::T2) where {T1, T2, isAp(T1 ∨ T2), isOrElse(eltype(T1 ∨ T2))}
  mapn(orelse, a, b)
end

# Monad
# =====

# we use flatten as default, as we have full type information about the nested levels
# this we wouldn't have with flatmap, as all the type information is hidden in the function
"""
    flatten(::A{A})::A

flatten gets rid of one level of nesting
"""
function flatten end
isFlatten(T::Type) = isdef(flatten, T)
isFlatten(a) = isFlatten(typeof(a))

isMonad(T::Type) = isApplicative(T) && isFlatten(T)
isMonad(a) = isMonad(typeof(a))



# basic functionality
# -------------------

"""
    flatmap(function_returning_A, a::A) = flatten(map(function_returning_A, a))

flatmap maps and flattens at once.

Overload `flatten` instead usually gives you more control over the type handling.
Still you can overload this function directly, e.g. for performance reasons.
"""
flatmap(f, a) = flatten(map(f, a))

"""
    @syntax_flatmap begin
      # Vector behave similar to nested for loops within @syntax_flatmap
      a = [1, 2, 3]
      b = [10, 20]
      @pure a + b
    end
    # [11, 21, 12, 22, 13, 23]

This is the standard monadic syntax which uses ``map`` for map_like and ``flatmap`` for flatmap_like.
See ``Monadic.@monadic`` for more details.
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

# we don't overwrite ``ap`` directly because it can easily conflict with custom @traits definitions
# instead it is offered as a default definition which you can use for your custom type

# for monadic code we actually don't need Pure
default_ap_having_map_flatmap(f, a) = @syntax_flatmap begin
  f = f
  a = a
  @pure f(a)
end
