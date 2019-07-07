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
combine(traitsof::Traitsof, a::T, b::T) where T = combine_traits(traitsof, a, b, traitsof(T))
@create_default combine_traits
const Combine = typeof(combine)  # this is the standard naming convention
const Semigroup = typeof(combine)  # this alternative name is just super popular

@traitsof_push! function(traitsof::Traitsof, T::Type)
  if functiondefined(combine, Tuple{typeof(traitsof), T, T})
    Combine
  end
end
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
neutral(traitsof::Traitsof, t::Type{T}) where T = neutral_traits(traitsof, t, traitsof(T))
@create_default neutral_traits
const Neutral = typeof(neutral)

@traitsof_push! function(traitsof::Traitsof, T::Type)
  if functiondefined(neutral, Tuple{typeof(traitsof), Type{T}})
    Neutral
  end
end

const Monoid = Union{Semigroup, Neutral}


"""
    reduce(itr)::eltype(itr) where traitsof(eltype(itr)) >: Monoid
    reduce(itr, init::T)::T where traitsof(T) >: typeof(⊕)

Shortcut functions for Monoid and Semigroup (⊕) instances.
"""
function reduce end

"""
    foldl(itr)::eltype(itr) where traitsof(eltype(itr)) >: Monoid
    foldl(itr, init::T)::T where traitsof(T) >: typeof(⊕)

Shortcut functions for Monoid and Semigroup (⊕) instances.
"""
function foldl end

"""
    foldr(itr)::eltype(itr) where traitsof(eltype(itr)) >: Monoid
    foldr(itr, init::T)::T where traitsof(T) >: typeof(⊕)

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
    function $reducefn(traitsof::Traitsof, itr; init::T) where T
      $reducefn_init(traitsof, itr, init, traitsof(T))
    end
    function $reducefn_init(traitsof::Traitsof, itr, init::T, ::TypeLB(typeof(⊕))) where T
      Base.$reducefn((a,b) -> ⊕(traitsof, a, b), itr; init=init)
    end

    # needs to be defined after the keyword functions
    function $reducefn(traitsof::Traitsof, itr)
      $reducefn_eltp(traitsof, itr, eltype(itr), traitsof(eltype(itr)))
    end
    function $reducefn_eltp(traitsof::Traitsof, itr, ::Type{T}, ::TypeLB(Monoid)) where T
      Base.$reducefn((a,b) -> ⊕(traitsof, a, b), itr; init=neutral(traitsof, T))
    end

    function $reducefn(traitsof::Traitsof, op, itr)
      $reducefn_neutral(traitsof, op, itr, traitsof(typeof(op)))
    end
    # we assume that ``neutral`` for functions will give back a normal neutral function
    function $reducefn_neutral(traitsof::Traitsof, op, itr, ::TypeLB(typeof(neutral)))
      Base.$reducefn(op, itr; init = neutral(traitsof, op)(eltype(itr)))
    end
    # default fallback to Base, as these are normal input variables
    function $reducefn_neutral(traitsof::Traitsof, op, itr, _)
      Base.$reducefn(op, itr)
    end

    # default fallback to Base
    function $reducefn(traitsof::Traitsof, signature...; kwargs...)
      Base.$reducefn(signature...; kwargs...)
    end
  end
end


# Absorbing
# =========

function absorbing end
absorbing(traitsof::Traitsof, t::Type{T}) where T = absorbing_traits(traitsof, t, traitsof(T))
@create_default absorbing_traits
const Absorbing = typeof(absorbing)

@traitsof_push! function(traitsof::Traitsof, T::Type)
  if functiondefined(absorbing, Tuple{typeof(traitsof), Type{T}})
    Absorbing
  end
end


# Alternative
# ===========

# we decided for "orelse" instead of "alternatives" to highlight the intrinsic asymmetry in choosing
function orelse end
# we follow haskell unicode syntax http://hackage.haskell.org/package/base-unicode-symbols-0.2.3/docs/Control-Applicative-Unicode.html
const ⊛ = orelse
const OrElse = typeof(orelse)

# we choose Neutral instead of defining a new "empty" because the semantics is the same
const Alternative = Union{Neutral, OrElse}
