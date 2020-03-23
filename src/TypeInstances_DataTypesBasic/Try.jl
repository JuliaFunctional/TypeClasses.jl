# MonoidAlternative
# =================

# no instance for neutral

TypeClasses.orelse(x1::Success, x2::Try) = x1
TypeClasses.orelse(x1::Failure, x2::Try) = x2

# Monoid support for Exceptions
TypeClasses.neutral(::Type{<:Exception}) = MultipleExceptions()
TypeClasses.combine(e1::Exception, e2::Exception) = MultipleExceptions(e1, e2)
# Monoid support for Failure
TypeClasses.neutral(::Type{<:Failure{T}}) where T = Failure{T}(MultipleExceptions(), [])
TypeClasses.neutral(::Type{<:Failure}) = neutral(Failure{Any})


# we keep Success when combining for analogy with Either and Maybe
TypeClasses.combine(x1::Success, x2::Failure) = x1
TypeClasses.combine(x1::Failure, x2::Success) = x1
function TypeClasses.combine(e1::Failure{T1}, e2::Failure{T2}) where {T1, T2}
  Failure{T1 ∨ T2}(e1.exception ⊕ e2.exception, [e1.stack; e2.stack])
end

@traits function TypeClasses.combine(x1::Success{T1}, x2::Success{T2}) where {T1, T2, isCombine(T1 ∨ T2)}
  Success(x1.value ⊕ x2.value)
end


# FunctorApplicativeMonad
# =======================

TypeClasses.eltype(::Try{T}) where {T} = T
TypeClasses.change_eltype(::Type{<:Failure}, T) = Failure{T}
TypeClasses.change_eltype(::Type{<:Success}, T) = Success{T}
TypeClasses.change_eltype(::Type{<:Try}, T) = Try{T}

TypeClasses.map(f, x::Success) = @Try f(x.value)

function TypeClasses.map(f, x::Failure{T}) where T
  _T2 = Out(f, T)
  T2 = _T2 === NotApplicable ? Any : _T2
  Failure{T2}(x)
end

TypeClasses.ap(f::Success, x::Success) = @Try f.value(x.value)
TypeClasses.ap(f::Failure{F}, x::Success{T}) where {F, T} = ap_Try_Exception(F, T, f)
TypeClasses.ap(f::Success{F}, x::Failure{T}) where {F, T} = ap_Try_Exception(F, T, x)
TypeClasses.ap(f::Failure{F}, x::Failure{T}) where {F, T} = ap_Try_Exception(F, T, f)  # take first exception, short cycling behaviour
function ap_Try_Exception(F, T, failure)
  _T2 = return_type_FunctionType(F, Tuple{T}) # TODO this is probably very slow...
  T2 = _T2 === Union{} ? Any : _T2
  Failure{T2}(failure)
end

TypeClasses.flatten(x::Try) = Iterators.flatten(x)

TypeClasses.pure(::Type{<:Try}, a) = Success(a)


# FlipTypes
# ========

@traits TypeClasses.flip_types(x::Failure{T}) where {T, isPure(T), isEltype(T)} = pure(T, Failure{eltype(T)}(x))
@traits TypeClasses.flip_types(x::Failure{T}) where {T, isPure(T), !isEltype(T)} = pure(T, Failure{Any}(x))
@traits TypeClasses.flip_types(x::Success{T}) where {T, isMap(T)} = map(Success, x.value)

@traits function TypeClasses.flip_types(x::Success{Any})
  TypeClasses.flip_types(fix_type(x))
end


# fix_type
# ========

"""
as typeinference sometimes lead to wrong containers, we need to be able to fix them at runtime
importantly, fix_type never generates Any again
"""
fix_type(x::Success{Any}) = Success{typeof(x.value)}(x.value)
# we cannot fix the type of Failure unfortunately
