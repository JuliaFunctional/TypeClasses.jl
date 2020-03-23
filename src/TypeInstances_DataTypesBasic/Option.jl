
# MonoidAlternative
# =================

# Maybe Monoid instance, as Nothing can work as neutral element
# taken from haskell http://hackage.haskell.org/package/base-4.12.0.0/docs/src/GHC.Base.html#line-419
TypeClasses.neutral(::Type{Option{T}}) where T = Option{T}()
TypeClasses.neutral(::Type{Option}) = Option()
# combine keeps Some as the neutral element must have no effect on combine by convention
TypeClasses.combine(x1::Some, x2::None) = x1
TypeClasses.combine(x1::None, x2::Option) = x2
function TypeClasses.combine(x1::Some{T}, x2::Some{T}) where T
  Some(x1.value ⊕ x2.value)
end

# Maybe Applicative instance, here just realized via orelse implementation
TypeClasses.orelse(x1::Some, x2::Option) = x1
TypeClasses.orelse(x1::None, x2::Option) = x2


# FunctorApplicativeMonad
# =======================

TypeClasses.eltype(::Type{<:Option{T}}) where {T} = T
TypeClasses.eltype(::Type{<:Option}) = Any

TypeClasses.change_eltype(::Type{<:Option}, Elem) = Option{Elem}
TypeClasses.change_eltype(::Type{<:Some}, Elem) = Some{Elem}
TypeClasses.change_eltype(::Type{<:None}, Elem) = None{Elem}

function TypeClasses.map(f, ::None{T}) where T
  T2 = Out(f, T)
  if T2 === NotApplicable
    Option{Any}()
  else
    Option{T2}()
  end
end
TypeClasses.map(f, x::Some) where T = Base.map(f, x)

TypeClasses.ap(f::Some, x::Some) = Option(f.value(x.value))
TypeClasses.ap(f::Option{F}, x::Option{T}) where {F, T} = ap_Option_nothing(F, T)
function ap_Option_nothing(F, T)
  T2 = return_type_FunctionType(F, Tuple{T}) # TODO this is probably very slow...
  if T2 === Union{}
    Option{Any}()
  else
    Option{T2}()
  end
end

TypeClasses.pure(::Type{<:Option}, a) = Some(a)

TypeClasses.flatten(x::Option) = Iterators.flatten(x)


# FlipTypes
# =========

@traits function TypeClasses.flip_types(x::None{T}) where {T, isPure(T), isEltype(T)}
  pure(T, None{eltype(T)}())
end
@traits function TypeClasses.flip_types(x::None{T}) where {T, isPure(T), !isEltype(T)}
  pure(T, None{Any}())
end
@traits function TypeClasses.flip_types(x::Some{T}) where {T, isMap(T)}
  map(Some, x.value)
end

@traits function TypeClasses.flip_types(x::Some{Any})
  TypeClasses.flip_types(fix_type(x))
end


# fix_type
# ========

"""
as typeinference sometimes lead to wrong containers, we need to be able to fix them at runtime
importantly, fix_type never generates Any again
"""
fix_type(x::Some{Any}) = Some{typeof(x.value)}(x.value)
# we cannot fix the type of None unfortunately
