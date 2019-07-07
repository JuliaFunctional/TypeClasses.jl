# FIter
# =====


"""
  fforeach(traitsof, f, functor)

Like fmap, but destroying the context. I.e. makes only sense for functions with side effects

Foreach allows to define a code-rewrite @syntax_fforeach similar to @syntax_fflatmap (which uses fmap and fflatmap).
Hence make sure that fmap, fflatmap and fforeach have same semantics.

Note that this does not work for all Functors (e.g. not for Callables), however is handy in many cases.
This is also the reason why we don't use the default fallback to map, as this may make no sense for your custom Functor.
"""
function fforeach end
fforeach(traitsof::Traitsof, f::F, a::A) where {F, A} = fforeach_traits(traitsof, f, a, traitsof(F), traitsof(A))
@create_default fforeach_traits
const FForeach = typeof(fforeach)

@traitsof_push! function(traitsof::Traitsof, T::Type)
  if functiondefined(fforeach, Tuple{typeof(traitsof), Function, T})
    FForeach
  end
end


# Functor
# =======

function fmap end
fmap(traitsof::Traitsof, f::F, a::A) where {F, A} = fmap_traits(traitsof, f, a, traitsof(F), traitsof(A))
  # extra layer to solve method resolution conflicts with default implementations
@create_default fmap_traits
const FMap = typeof(fmap)

# to work with Functors generically, we need to be able to change subtypes

# like eltype we offer convenience method for values
feltype(traitsof::Traitsof, a) = feltype(traitsof, typeof(a))
feltype(traitsof::Traitsof, A::Type) = feltype_traits(traitsof, A, traitsof(A))
@create_default feltype_traits
# defaulting to using eltype
feltype_traits_default(::Traitsof, A, _) = eltype(A)
const FEltype = typeof(feltype)

# TODO check whether this typeinfers i.e. whether Core.Compiler.return_type works
# TODO make this generated?
function change_feltype end
change_feltype(traitsof::Traitsof, T::Type, E::Type) = change_feltype_type_traits(traitsof, T, E, traitsof(T), traitsof(E))
@create_default change_feltype_type_traits
const ChangeFEltype = typeof(change_feltype)

# also have a version for values, as in Julia it is relatively often that the default value constructor picks a too concrete type
# which we need to lift afterwards
change_feltype(traitsof::Traitsof, t::T, E) where T = change_feltype_value_traits(traitsof, t, T, E, traitsof(T), traitsof(E))
@create_default change_feltype_value_traits

# we use a simple change_feltype_traits_default implementaion
# - to enhance type-inference
# - because the custom implementation is usually a wrong liner
# - this will give better error messages
# the default implementation is just to change nothing
change_feltype_type_traits_default(::Traitsof, T, E, _, _) = T
change_feltype_value_traits_default(::Traitsof, t, E, _, _) = t

"""
helper to abstract the feltype a bit more
(this is most typical application of unionall, as the difficulty appears only as typevar not as mere value)
"""
feltype_unionall_implementationdetails(traitsof, functor) = change_feltype(traitsof, functor, unionall_implementationdetails(feltype(traitsof, typeof(functor))))

# we want to indicate that all three functions need to be defined for a proper functor
# - fmap is the context preserving Functor method
# - feltype and change_feltype are needed for type-level support
# we are not including
# - fiter, because it is not definable for all Functors (e.g. not for Callable)
const Functor = Union{FMap, FEltype, ChangeFEltype}

# using function style simplifies the syntax a lot,
# however increases performance demands as every function needs to be run for every type
# still the final function will be generated, hence overall there should be no performance leak
@traitsof_push! function(traitsof::Traitsof, T::Type)
  if functiondefined(fmap, Tuple{typeof(traitsof), Function, T})
    Functor
  end
  # we don't check feltype and change_feltype because they should have useful default implementations
end


# Applicative
# ===========

function pure end
pure(traitsof::Traitsof, T::Type, a::A) where A = pure_traits(traitsof, T, a, traitsof(T), traitsof(A))
@create_default pure_traits
const Pure = typeof(pure)

function ap end
ap(traitsof::Traitsof, f::F, a::A) where F where A = ap_traits(traitsof, f, a, traitsof(F), traitsof(A))
@create_default ap_traits
const Ap = typeof(ap)

const Applicative = Union{Functor, Pure, Ap}

@traitsof_push! function(traitsof::Traitsof, T::Type)
  if functiondefined(pure, Tuple{typeof(traitsof), Type{T}, T})
    Pure
  end
end

@traitsof_push! function(traitsof::Traitsof, T::Type)
  if functiondefined(ap, Tuple{typeof(traitsof), T, T})
    Ap
  end
end

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

function mapn(traitsof::Traitsof, func, args...)
  n = length(args)
  if n == 0
    error("mapn is not defined for 0 args as the type T needed for pure(traitsof, T) is not known")
  else
    cfunc = curry(func, n)
    Base.reduce((f, a) -> ap(traitsof, f, a), args[2:end]; init = fmap(traitsof, cfunc, args[1]))
  end
end

# default implementations
# -----------------------

# we use extra function namings to enable later overloading of conflicting dispatches with this implementations
fmap_traits_Ap_Pure(traitsof::Traitsof, f, a::A) where A = ap(traitsof, pure(traitsof, A, f), a)
# we overwrite _default so that these definitions have lower precedence in dispatch than user-defined dispatch on fmap_traits
fmap_traits_default(traitsof::Traitsof, f, a, _, ::TypeLB(Ap, Pure)) = fmap_traits_Ap_Pure(traitsof, f, a)

# LEGACY: this is no longer needed as Functor is inferred directly from the existence of a function
# this code is still here to show how you can infer types using recursive traitfunctions
# @traitsof_push! function(traitsof::Traitsof, ::Type{T}) where T
#   if Union{Ap, Pure} <: traitsof(T)
#     Functor
#   end
# end


# Monad
# =====

# we use flatten as default, as we have full type information about the nested levels
# this we wouldn't have with fflatmap, as all the type information is hidden in the function

function fflatten end
fflatten(traitsof::Traitsof, a::A) where A = fflatten_traits(traitsof, a, traitsof(A))
@create_default fflatten_traits
const FFlatten = typeof(fflatten)
const Monad = Union{Applicative, FFlatten}

function fflatten_traits_default(traitsof::Traitsof, a::A, TraitsA::TypeLB(Functor)) where A
  B = feltype(traitsof, A)
  fflatten_traits_Functor(traitsof, a, B, TraitsA, traitsof(B))
end
# turns out this is needed for e.g. ContextManager
function fflatten_traits_Functor end


@traitsof_push! function(traitsof::Traitsof, T::Type)
  if functiondefined(fflatten, Tuple{typeof(traitsof), T})
    FFlatten
  end
end





# basic functionality
# -------------------

fflatmap(traitsof::Traitsof, f, a) = fflatten(traitsof, fmap(traitsof, f, a))


"""
  fflattenrec(traitsof::Traitsof, nested_monad)

fflattens out everything which it can, also fmapping over Functors to flatten
out sublevels
"""
fflattenrec(traitsof::Traitsof, a::A) where  A = fflattenrec_traits(traitsof, a, traitsof(A))
# recursion anchor
fflattenrec_traits(traitsof::Traitsof, a, _) = a
# only flatten if type defines fflatten
function fflattenrec_traits(traitsof::Traitsof, a, ::TypeLB(FFlatten))
  # take of one level and recurse
  fflattenrec(traitsof, fflatten(traitsof, a))
end
# if not FFlatten but Functor, map fflattenrec over it
fflattenrec_traits(traitsof::Traitsof, a, ::TypeLB(Functor)) = fmap(traitsof, b -> fflattenrec(traitsof, b), a)
# solve conflicting dispatch
fflattenrec_traits(traitsof::Traitsof, a, ::TypeLB(FFlatten, Functor)) = fflattenrec(traitsof, fflatten(traitsof, a))


# monadic programming style
# -------------------------

"""
Simple helper type to mark pure code parts in monadic code block
"""
struct PureCode
  code
end
"""
Mark code to contain non-monadic code.

This can be thought of as generalized version of `pure` function within @syntax_fflatmap context.
"""
macro pure(e)
  PureCode(e)
end

# @pure is expanded within monadic
function mergepure!(a::Int, b::Int, block::Vector{Any})
  for k ∈ a:b
    if block[k] isa PureCode
      block[k] = block[k].code
    end
  end
end

function monadic(block::Expr, fmaplike = :(TypeClasses.fmap), fflatmaplike = :(TypeClasses.fflatmap))
  @assert block.head == :block
  i = findfirst(x -> x isa Expr, block.args)
  # for everything before i we merge @pure expressions into normal code
  mergepure!(1, i - 1, block.args)
  monadic(i, block.args, fmaplike, fflatmaplike)
end

function monadic(i::Nothing, block::Vector{Any}, _, _)
  Expr(:block, block...)
end

function monadic(i::Int, block::Vector{Any}, fmaplike, fflatmaplike)
  e::Expr = block[i]
  j = findnext(x -> x isa Expr, block, i+1)
  if isnothing(j) # last monadic Expr is a special case
    # either i is the last entry at all, then this can be returned directly
    if i == length(block)
      Expr(:block, block...)
    # or this not the last entry, but @pure expressions may follow, then we construct a final fmap
    else
      mergepure!(i + 1, length(block), block) # merge all left @pure
      lastblock = Expr(:block, block[i+1:end]...)

      callfmap = if (e.head == :(=))
        subfunc = Expr(:->, Expr(:tuple, e.args[1]), lastblock)  # we need to use :tuple wrapper to support desctructuring https://github.com/JuliaLang/julia/issues/6614
        Expr(:call, fmaplike, :traitsof, subfunc, e.args[2])
      elseif (e.head == :call)
        subfunc = Expr(:->, :_, lastblock)
        Expr(:call, fmaplike, :traitsof, subfunc, e)
      else
        error("this should not happen")
      end
      Expr(:block, block[1:i-1]..., callfmap)
    end
  # if i is not the last monadic Expr
  else
    mergepure!(i + 1, j - 1, block) # merge all new @pure inbetween
    submonadic = monadic(j - i, block[i+1:end], fmaplike, fflatmaplike)

    callfflatmap = if (e.head == :(=))
      subfunc = Expr(:->, Expr(:tuple, e.args[1]), submonadic)  # we need to use :tuple wrapper to support desctructuring https://github.com/JuliaLang/julia/issues/6614
      Expr(:call, fflatmaplike, :traitsof, subfunc, e.args[2])
    elseif (e.head == :call)
      subfunc = Expr(:->, :_, submonadic)
      Expr(:call, fflatmaplike, :traitsof, subfunc, e)
    else
      error("this should not happen")
    end
    Expr(:block, block[1:i-1]..., callfflatmap)
  end
end


# we can create a bunch of different syntaxes with this, all versions of the same

macro syntax_fflatmap(block::Expr)
  @assert block.head == :block
  esc(monadic(macroexpand(__module__, block)))
end

macro syntax_fforeach(block::Expr)
  @assert block.head == :block
  esc(monadic(macroexpand(__module__, block), :(TypeClasses.fforeach), :(TypeClasses.fforeach)))
end

macro syntax_fmap(block::Expr)
  @assert block.head == :block
  esc(monadic(macroexpand(__module__, block), :(TypeClasses.fmap), :(TypeClasses.fmap)))
end

"""
this is very interesting syntax in that it is simlar to but can be different from syntax_fflatmap

concretely if your final Type defines fflatten for non-functor types (Example: Maybe)
  then ``@syntax_fmap_fflattenrec`` will call ``fflatten`` also on the final result
  while ``syntax_fflatmap`` won't do any extra fflatten call

also this syntax may be more type stable, as first the overall type is constructed
  and then everything is flattend out

finally you can easily create fflatten overloadings which work on nested triples
"""
macro syntax_fmap_fflattenrec(block::Expr)
  @assert block.head == :block
  quote
    r = $(esc(monadic(macroexpand(__module__, block), :(TypeClasses.fmap), :(TypeClasses.fmap))))
    fflattenrec($(esc(:traitsof)), r)
  end
end




# Now can define the fallback definition for ap with monad style
# ==============================================================

# for monadic code we actually don't need Pure
ap_traits_FFlatten_Functor(traitsof::Traitsof, f, a) = @syntax_fflatmap begin
  f = f
  a = a
  @pure f(a)
end
ap_traits_default(traitsof::Traitsof, f, a, ::TypeLB(Functor, FFlatten), ::TypeLB(Functor)) = ap_traits_FFlatten_Functor(traitsof, f, a)
