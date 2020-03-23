using Traits

"""
    ⊕(::T, ::T)::T

Associcative combinator operator.

The symbol ``⊕`` following http://hackage.haskell.org/package/base-unicode-symbols-0.2.3/docs/Data-Monoid-Unicode.html

# Following Laws should hold

Associativity

    ⊕(::T, ⊕(::T, ::T)) == ⊕(⊕(::T, ::T), ::T)
"""
function combine end
const ⊕ = combine

isCombine(T::Type) = isdef(combine, T, T)
isCombine(a) = isCombine(typeof(a))
isSemigroup(a) = isCombine(a) # this alternative name is just super popular

# fix wrong type-inference
# Traits.IsDef._return_type(combine, ::Type{Tuple{Any, Any}}) = Union{}

"""
    neutral(::Type{T})::T

Neutral element for `⊕`, also called "identity element".

We decided for name ``neutral`` according to https://en.wikipedia.org/wiki/Identity_element. Alternatives seem inappropriate
  - "identity" is already taken
  - "identity_element" seems to long
  - "I" is too ambiguous
  -"unit" seems ambiguous with physical units

# Following Laws should hold

Left Identity

      ⊕(neutral(T), t::T) == t

Right Identity

      ⊕(t::T, neutral(T)) == t
"""
function neutral end
@traits neutral(T::Type) = throw(MethodError("neutral($T) not defined"))
@traits neutral(a) = neutral(typeof(a))

isNeutral(T::Type) = isdef(neutral, Type{T})
isNeutral(a) = isNeutral(typeof(a))

isMonoid(a) = isSemigroup(a) && isNeutral(a)


"""
    reduce(itr)::eltype(itr)
    reduce(itr, init::T)::T

Shortcut functions for Monoid and Semigroup (⊕) instances.
"""
function reduce end

"""
    foldl(itr)::eltype(itr)
    foldl(itr, init::T)::T

Shortcut functions for Monoid and Semigroup (⊕) instances.
"""
function foldl end

"""
    foldr(itr)::eltype(itr)
    foldr(itr, init::T)::T

Shortcut functions for Monoid and Semigroup (⊕) instances.
"""
function foldr end

# we want to suppress warnings of redefining methods, as everything works despite the warnings say different
# unfortunately non of the suppress methods seem to work...
@suppress @suppress_out @suppress_err for reducefn ∈ [:reduce, :foldl, :foldr]
  reducefn_eltp = Symbol(reducefn, "_eltype")
  reducefn_neutral = Symbol(reducefn, "_neutral")
  reducefn_init = Symbol(reducefn, "_init")

  @eval begin
    @traits function $reducefn(init::T, itr) where {T, isSemigroup(T)}
      Base.$reducefn(⊕, itr; init=init)
    end
    @traits function $reducefn(itr) where {isMonoid(eltype(itr))}
      Base.$reducefn(⊕, itr; init=neutral(eltype(itr)))
    end

    # we assume that ``neutral`` for functions will give back a normal neutral function
    @traits function $reducefn(op::Union{Function, Type}, itr) where {isNeutral(op)}
      Base.$reducefn(op, itr; init = neutral(op)(eltype(itr)))
    end

    # default fallback to Base
    @traits function $reducefn(args...; kwargs...)
      Base.$reducefn(args...; kwargs...)
    end
  end
end


# Absorbing
# =========

"""
specify an absorbing element for your Type which will stays unaltered when used in ``combine``
i.e. ``combine(absorbing(T), anything) == absorbing(T)``
"""
function absorbing end
absorbing(T::Type) = throw(MethodError("absorbing($T) not defined"))
@traits absorbing(a) = absorbing(typeof(a))

isAbsorbing(T::Type) = isdef(absorbing, Type{T})
isAbsorbing(a) = isAbsorbing(typeof(a))


# Alternative
# ===========

# we decided for "orelse" instead of "alternatives" to highlight the intrinsic asymmetry in choosing
function orelse end
# we follow haskell unicode syntax http://hackage.haskell.org/package/base-unicode-symbols-0.2.3/docs/Control-Applicative-Unicode.html
const ⊛ = orelse
isOrElse(T::Type) = isdef(orelse, T, T)
isOrElse(a) = isOrElse(typeof(a))

# we choose Neutral instead of defining a new "empty" because the semantics is the same
isAlternative(a) = isNeutral(a) && isOrElse(a)
