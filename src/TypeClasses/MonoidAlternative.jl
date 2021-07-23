# Monoid / Semigroup
# ==================

"""
    neutral
    neutral(::Type)
    neutral(_default_return_value) = neutral

Neutral element for `⊕`, also called "identity element". `neutral` is a function which can give you 
the neutral element for a concrete type, or alternatively you can use it as a singleton value which combines with everything.

By default `neutral(type)` will return the generic `neutral` singleton. You can override it for your specific type to have a more specific neutral value.

We decided for name `neutral` according to https://en.wikipedia.org/wiki/Identity_element. Alternatives seem inappropriate
  - "identity" is already taken
  - "identity_element" seems to long
  - "I" is too ambiguous
  - "unit" seems ambiguous with physical units


Following Laws should hold
--------------------------

Left Identity

      ⊕(neutral(T), t::T) == t

Right Identity

      ⊕(t::T, neutral(T)) == t
"""
function neutral end
neutral(T::Type) = neutral  # we use the singleton type itself as the generic neutral value
neutral(a) = neutral(typeof(a))


"""
    combine(::T, ::T)::T  # overload this
    ⊕(::T, ::T)::T  # alias \\oplus
    combine(a, b, c, d, ...)  # using combine(a, b) internally

Associcative combinator operator.

The symbol `⊕` (\\oplus) following http://hackage.haskell.org/package/base-unicode-symbols-0.2.3/docs/Data-Monoid-Unicode.html

# Following Laws should hold

Associativity

    ⊕(::T, ⊕(::T, ::T)) == ⊕(⊕(::T, ::T), ::T)
"""
function combine end
const ⊕ = combine

combine(a, b, c, more...) = foldl(⊕, more, init=(a⊕b)⊕c)


# supporting `neutral` as generic neutral value
combine(::typeof(neutral), b) = b
combine(a, ::typeof(neutral)) = a
combine(::typeof(neutral), ::typeof(neutral)) = neutral


for reduce ∈ [:reduce, :foldl, :foldr]
  reduce_monoid = Symbol(reduce, "_monoid")
  _reduce_monoid = Symbol("_", reduce_monoid)

  @eval begin
    """
        $($reduce_monoid)(itr; init=TypeClasses.neutral)
        
    Combines all elements of `itr` using the initial element `init` if given and `TypeClasses.combine`.
    """
    function $reduce_monoid(itr; init=neutral)
      # taken from Base._foldl_impl

      # Unroll the while loop once to hopefully infer the element type at compile time
      y = iterate_named(itr)
      isnothing(y) && return init
      v = combine(init, y.value)
      while true
          y = iterate_named(itr, y.state)
          isnothing(y) && break
          v = combine(v, y.value)
      end
      return v
    end
  end
end


# Alternative
# ===========

"""
    orelse(a, b)  # overload this
    ⊘(a, b)  # alias \\oslash
    orelse(a, b, c, d, ...)  # using orelse(a, b) internally

Implements an alternative logic, like having two options a and b, taking the first valid one.
We decided for "orelse" instead of "alternatives" to highlight the intrinsic asymmetry in choosing.

The operator ⊘ (\\oslash) is choosen to have an infix operator which is similar to \\oplus, however clearly distinguishable, asymmetric, and somehow capturing a choice semantics.
The slash actually is used to indicate choice (at least in some languages, like German), and luckily \\oslash exists (and is not called \\odiv).  
"""
function orelse end
const ⊘ = orelse

orelse(a, b, c, more...) = foldl(⊘, more, init=(a⊘b)⊘c)