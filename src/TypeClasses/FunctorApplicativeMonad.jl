using Traits
using Monadic
using ASTParser
import FunctionWrappers: FunctionWrapper

"""
  foreach(f, functor)

Like map, but destroying the context. I.e. makes only sense for functions with side effects

map, flatmap and foreach should have same semantics.

Note that this does not work for all Functors (e.g. not for Callables), however is handy in many cases.
This is also the reason why we don't use the default fallback to map, as this may make no sense for your custom Functor.
"""
@traits foreach(f, a) = Base.foreach(f, a)
isForeach(T::Type) = isdef(foreach, typeof(identity), T)
isForeach(a) = isForeach(typeof(a))

macro syntax_foreach(block::Expr)
  esc(monadic(:(TypeClasses.foreach), :(TypeClasses.foreach), macroexpand(__module__, block)))
end

# Functor
# =======

"""
  map(f, functor)

The core functionality of a functor, applying a normal function "into" the context defined by the functor.
Think of map and vector as best examples.
"""
@traits map(f, a) = Base.map(f, a)
isMap(T::Type) = isdef(map, typeof(identity), T)  # we check for a concrete function to have better typeinference
isMap(value) = isMap(typeof(value))

"""
  eltype(functor)

return the type of the functor "element"
"""
@traits eltype(T::Type) = Base.eltype(T)
@traits eltype(value) = eltype(typeof(value))
isEltype(T::Type) = isdef(eltype, Type{T})
isEltype(value) = isEltype(typeof(value))

"""
  change_eltype(FunctorType::Type, NewElementType::Type)
  FunctorType ⫙ NewElementType

return new type with inner element changed
"""
function change_eltype end
const ⫙ = change_eltype

# advanced default implementation using https://discourse.julialang.org/t/how-can-i-create-a-function-type-with-custom-input-and-output-type/31719
# Note that is very important to use @traits here as there may be implementations using only traits
@traits change_eltype(T::Type, E) = Out(map, FunctionWrapper{E, Tuple{Any}}, T)


# TODO is this still needed?
# """
#   eltype_unionall_implementationdetails(functor)
#
# Convenience wrapper around ``unionall_implementationdetails`` to capsulate the feltype
#
# This is most typical application of unionall, as the difficulty appears only as typevar not as mere value.
# """
# eltype_unionall_implementationdetails(functor) = change_eltype(functor, unionall_implementationdetails(eltype(typeof(functor))))


function isFunctor(T::Type)
  # TODO Functions for example don't have an eltype function, maybe we should just check for map
  isMap(T) && isEltype(T)
end
isFunctor(a) = isFunctor(typeof(a))

macro syntax_map(block::Expr)
  esc(monadic(:(TypeClasses.map), :(TypeClasses.map), macroexpand(__module__, block)))
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

# currying helper
# ---------------

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

# basic functionality
# -------------------

"""
  apply a function over applicative contexts instead of plain values
"""
# TODO make this a generative function to optimize performance
function mapn(func, args...)
  n = length(args)
  if n == 0
    error("mapn is not defined for 0 args as the type T needed for pure(traitsof, T) is not known")
  else
    cfunc = curry(func, n)
    Base.reduce((f, a) -> ap(f, a), args[2:end]; init = map(cfunc, args[1]))
  end
end

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

returnlast(a) = a
returnlast(a, b) = b
returnlast(a, b, c) = c
returnlast(a, b, c, d) = d
returnlast(a, b, c, d, e) = e
returnlast(a, b, c, d, e, f) = f
returnlast(a, b, c, d, e, f, g) = g
returnlast(a, b, c, d, e, f, g, h) = h
returnlast(args...) = args[end]

"""
combine several Applicative contexts by building up a Tuple
"""
function tupled(applicatives...)
  mapn(tuple, applicatives...)
end

# default implementations
# -----------------------

# default implementations collide to often with other traits definitions and rather do harm than good
# hence we just give a default definition to use for custom definitions

@traits default_map(f, a::A) where {A, isAp(A), isPure(A)} = ap(pure(A, f), a)



# generic Monoid implementations for Applicative
# ----------------------------------------------

# isApplicative(T) && isMonoid(eltype(T)) -> isMonoid(T)
# TODO do this interact dangerously with other definitions?

@traits function neutral(a::T) where {T, isPure(T), isNeutral(eltype(T))}
  pure(T, neutral(eltype(T)))
end

@traits function combine(a::T, b::T) where {T, isAp(T), isCombine(eltype(T))}
  mapn(⊕, a, b)
end

# TODO do we need this?
# @traits function combine(a::T1, b::T2) where {T1, T2, isAp(T1 ∧ T2), isCombine(eltype(T1 ∧ T2))}
#   mapn(⊕, a, b)
# end



# Monad
# =====

# we use flatten as default, as we have full type information about the nested levels
# this we wouldn't have with flatmap, as all the type information is hidden in the function
"""
  flatten(::F{F}) -> F

flatten gets rid of one level of nesting
"""
function flatten end
isFlatten(T::Type) = isdef(flatten, T)
isFlatten(a) = isFlatten(typeof(a))

isMonad(T::Type) = isApplicative(T) && isFlatten(T)
isMonad(a) = isMonad(typeof(a))



# basic functionality
# -------------------

@traits flatmap(f, a) = flatten(map(f, a))
isFlatten(T::Type) = isdef(flatten, T)
isFlatten(a) = isFlatten(typeof(a))


"""
  flattenrec(traitsof::Traitsof, nested_monad)

flattens out everything which it can, also mapping over Functors to flatten
out sublevels
"""
# recursion anchor
@traits flattenrec(a) where {!isFlatten(a)} = a
# only flatten if type defines flatten
@traits flattenrec(a) where {isFlatten(a)} = flattenrec(flatten(a))
# if not Flatten but Functor, map flattenrec over it
@traits flattenrec(a) where {isFunctor(a)} = map(b -> flattenrec(b), a)
# solve conflicting dispatch
@traits flattenrec(a) where {isFlatten(a), isFunctor(a)} = flattenrec(flatten(a))


# we can create a bunch of different syntaxes with this, all versions of the same

macro syntax_flatmap(block::Expr)
  esc(monadic(:(TypeClasses.map), :(TypeClasses.flatmap), macroexpand(__module__, block)))
end

"""
this is very interesting syntax in that it is similar to but can be different from syntax_flatmap

concretely if your final Type defines flatten for non-functor types (Example: Maybe)
  then ``@syntax_map_flattenrec`` will call ``flatten`` also on the final result
  while ``syntax_flatmap`` won't do any extra flatten call

also this syntax may be more type stable, as first the overall type is constructed
  and then everything is flattend out

finally you can easily create flatten overloadings which work on nested triples
"""
macro syntax_flattenrec(block::Expr)
  quote
    r = $(esc(monadic(:(TypeClasses.map), :(TypeClasses.map), macroexpand(__module__, block))))
    flattenrec(r)
  end
end

# Now can define the fallback definition for ap with monad style
# ==============================================================

# we don't overwrite ``ap`` directly because it can easily conflict with custom @traits definitions
# instead it is offered as a default definition which you can use for your custom type

# for monadic code we actually don't need Pure
@traits default_ap(f, a) where {isFunctor(a), isFlatten(a)} = @syntax_flatmap begin
  f = f
  a = a
  @pure f(a)
end
