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
isCombine(T1::Type, T2::Type) = isdef(combine, T1, T2)
isCombine(a, b) = isCombine(typeof(a), typeof(b))
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
neutral(T::Type) = throw(MethodError("neutral($T) not defined"))
neutral(a) = neutral(typeof(a))

isNeutral(T::Type) = isdef(neutral, Type{T})
isNeutral(a) = isNeutral(typeof(a))

isMonoid(a) = isSemigroup(a) && isNeutral(a)


for reduce ∈ [:reduce, :foldl, :foldr]
  reduce_monoid = Symbol(reduce, "_monoid")

  @eval begin
    """
        $($reduce_monoid)(init, itr) where isSemigroup(init)

    Combines all elements of `itr` using the initial element `init` and `combine`.
    """
    @traits function $reduce_monoid(init::T, itr) where {T, isSemigroup(T)}
      Base.$reduce(⊕, itr; init=init)
    end
    """
        $($reduce_monoid)(itr) where isMonoid(eltype(itr))
        $($reduce_monoid)(itr; [init]) where {isSemigroup(eltype(itr)), !isempty(itr)}

    Combines all elements of `itr` using `neutral` and `combine`.
    """
    @traits function $reduce_monoid(itr) where {isMonoid(eltype(itr))}
      Base.$reduce(⊕, itr; init=neutral(eltype(itr)))
    end
    @traits function $reduce_monoid(itr) where {isSemigroup(eltype(itr)), !isempty(itr)}
      Base.$reduce(⊕, itr)
    end

    """
        $($reduce_monoid)(func, itr) where isNeutral(func)

    We assume that ``neutral`` for functions will give back a normal neutral function with which we can construct an
    initial element.

    E.g. think of `+` which has `zero` as function creating neutral elements,
    and similarly `neutral(::typeof(*)) = one`.
    """
    # we assume that ``neutral`` for functions will give back a normal neutral function
    @traits function $reduce_monoid(op::Union{Function, Type}, itr) where {isNeutral(op)}
      Base.$reduce(op, itr; init = neutral(typeof(op))(eltype(itr)))
    end

    # throw error if something does not match
    @traits function $reduce_monoid(args...; kwargs...)
      error("$($reduce_monoid) is only defined for Monoid or Semigroup")
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
absorbing(a) = absorbing(typeof(a))

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
isOrElse(T1::Type, T2::Type) = isdef(orelse, T1, T2)
isOrElse(a, b) = isOrElse(typeof(a), typeof(b))

# we choose Neutral instead of defining a new "empty" because the semantics is the same
isAlternative(a) = isNeutral(a) && isOrElse(a)
