"""
    combine(::T, ::T)::T
    ⊕(::T, ::T)::T

Associcative combinator operator.

The symbol `⊕` following http://hackage.haskell.org/package/base-unicode-symbols-0.2.3/docs/Data-Monoid-Unicode.html

# Following Laws should hold

Associativity

    ⊕(::T, ⊕(::T, ::T)) == ⊕(⊕(::T, ::T), ::T)
"""
function combine end
const ⊕ = combine

"""
    isCombine(type)
    isCombine(value) = isCombine(typeof(value))
    isCombine(type1, type2)
    isCombine(value, value) = isCombine(typeof(type1), typeof(type2))

    isSemigroup(type)
    isSemigroup(value) = isSemigroup(typeof(value))
    isSemigroup(type1, type2)
    isSemigroup(value, value) = isSemigroup(typeof(type1), typeof(type2))

trait for checking whether a given Type defines `TypeClasses.combine`
"""
isCombine(T::Type) = error("Could not find definition for `TypeClasses.isCombine(::Type{$T})`. Please define it.")
isCombine(a) = isCombine(typeof(a))
isCombine(::Type{T}, ::Type{T}) where T = isCombine(T)
isCombine(T::Type, S::Type) = error("Could not find definition for `TypeClasses.isCombine(::Type{$T}, ::Type{$S})`. Please define it.")
isCombine(a, b) = isCombine(typeof(a), typeof(b))
const isSemigroup = isCombine # this alternative name is just super popular


"""
    neutral(::Type{T})::T

Neutral element for `⊕`, also called "identity element".

We decided for name `neutral` according to https://en.wikipedia.org/wiki/Identity_element. Alternatives seem inappropriate
  - "identity" is already taken
  - "identity_element" seems to long
  - "I" is too ambiguous
  - "unit" seems ambiguous with physical units

# Following Laws should hold

Left Identity

      ⊕(neutral(T), t::T) == t

Right Identity

      ⊕(t::T, neutral(T)) == t
"""
function neutral end
neutral(T::Type) = error("neutral($T) not defined")
neutral(a) = neutral(typeof(a))

"""
    isNeutral(type)
    isNeutral(value) = isNeutral(typeof(value))
    
trait for checking whether a given Type defines `TypeClasses.neutral`
"""
isNeutral(T::Type) = error("Could not find definition for `TypeClasses.isNeutral(::Type{$T})`. Please define it.")
isNeutral(a) = isNeutral(typeof(a))

"""
    isMonoid(type)
    isMonoid(value) = isMonoid(typeof(value))

combining traits [`TypeClasses.isSemigroup`](@ref) and [`TypeClasses.isNeutral`](@ref)
"""
isMonoid(a) = isSemigroup(a) && isNeutral(a)

struct _InitialValue end

for reduce ∈ [:reduce, :foldl, :foldr]
  reduce_monoid = Symbol(reduce, "_monoid")
  _reduce_monoid = Symbol("_", reduce_monoid)

  @eval begin
    """
        $($reduce_monoid)(itr; [init])
        $($reduce_monoid)(monoid_combine_function, itr; [init])

    Combines all elements of `itr` using the initial element `init` if given and `combine`.
    If no `init` is given, `neutral` and `combine` is used instead.

    If `monoid_combine_function` is given, it `neutral(monoid_combine_function)` is expected to return the corresponding `neutral` function
    """
    function $reduce_monoid(itr; init = _InitialValue())
      $_reduce_monoid(TypeClasses.combine, TypeClasses.neutral, itr, init)
    end
    function $reduce_monoid(monoid_combine_function, itr; init = _InitialValue())
      $_reduce_monoid(monoid_combine_function, neutral(monoid_combine_function), itr, init)
    end
    function $_reduce_monoid(combine, neutral, itr, init)
      op(acc::_InitialValue, x) = x
      op(acc, x) = combine(acc, x)
      # taken from Base._foldl_impl

      # Unroll the while loop once; if init is known, the call to op may
      # be evaluated at compile time
      y = iterate_named(itr)
      isnothing(y) && return neutral(eltype(itr))
      v = op(init, y.value)
      while true
          y = iterate_named(itr, y.state)
          isnothing(y) && break
          v = op(v, y.value)
      end
      return v
    end
  end
end


# Absorbing
# =========

"""
specify an absorbing element for your Type which will stays unaltered when used in `combine`
i.e. `combine(absorbing(T), anything) == absorbing(T)`
"""
function absorbing end
absorbing(T::Type) = throw(MethodError("absorbing($T) not defined"))
absorbing(a) = absorbing(typeof(a))

"""
    isAbsorbing(type)
    isAbsorbing(value) = isAbsorbing(typeof(value))
    
trait for checking whether a given Type defines `TypeClasses.neutral`
"""
isAbsorbing(T::Type) = error("Could not find definition for `TypeClasses.isAbsorbing(::Type{$T})`. Please define it.")
isAbsorbing(a) = isAbsorbing(typeof(a))


# Alternative
# ===========

"""
    orelse(a, b)
    ⊛(a, b)

Implements an alternative logic, like having two options a and b, taking the first valid one.
We decided for "orelse" instead of "alternatives" to highlight the intrinsic asymmetry in choosing.

The operator ⊛ follows haskell unicode syntax http://hackage.haskell.org/package/base-unicode-symbols-0.2.3/docs/Control-Applicative-Unicode.html
"""
function orelse end
const ⊛ = orelse

"""
    isOrElse(type)
    isOrElse(value) = isOrElse(typeof(value))
    isOrElse(type1, type2)
    isOrElse(value, value) = isOrElse(typeof(type1), typeof(type2))

trait for checking whether a given Type defines `TypeClasses.orelse`
"""
isOrElse(T::Type) = error("Could not find definition for `TypeClasses.isOrElse(::Type{$T})`. Please define it.")
isOrElse(a) = isOrElse(typeof(a))
isOrElse(::Type{T}, ::Type{T}) where T = isOrElse(T)
isOrElse(T::Type, S::Type) = error("Could not find definition for `TypeClasses.isOrElse(::Type{$T}, ::Type{$S})`. Please define it.")
isOrElse(a, b) = isOrElse(typeof(a), typeof(b))

"""
    isAlternative(type)
    isAlternative(value) = isAlternative(typeof(value))

combining traits [`TypeClasses.isNeutral`](@ref) and [`TypeClasses.isOrElse`](@ref)
we choose Neutral instead of defining a new "empty" because the semantics is the same
"""
isAlternative(a) = isNeutral(a) && isOrElse(a)
