# MonoidAlternative
# =================

# no instance for neutral

TypeClasses.orelse(::Traitsof, x1::Try{T, Success}, x2::Try) where T = x1
TypeClasses.orelse(::Traitsof, x1::Try{T, Exception}, x2::Try) where T = x2

TypeClasses.combine(::Traitsof, x1::Try{T, Success}, x2::Try{S, Exception}) where {T, S} = x2
TypeClasses.combine(::Traitsof, x1::Try{T, Exception}, x2::Try{S, Success}) where {T, S} = x1
TypeClasses.combine(traitsof::Traitsof, x1::Try{T, Exception}, x2::Try{T, Exception}) where T = Try{T, Exception}(MultipleExceptions(x1.value, x2.value))
function TypeClasses.combine(traitsof::Traitsof, x1::Try{T, Success}, x2::Try{T, Success}) where T
  Try{T, Success}(TypeClasses.combine(traitsof, x1.value::T, x2.value::T))
end


# Combine support for exceptions
TypeClasses.neutral(::Traitsof, ::Type{Exception}) = MultipleExceptions()
TypeClasses.combine(::Traitsof, e1::Exception, e2::Exception) = MultipleExceptions(e1, e2)


# FunctorApplicativeMonad
# =======================

TypeClasses.feltype(::Traitsof, ::Type{F}) where {T, F <: Try{T}} = T
TypeClasses.change_eltype(::Traitsof, ::Type{Try{T, Tag}}, T2::Type) where {T, Tag} = Try{T2, Tag}
TypeClasses.change_eltype(::Traitsof, ::Type{Try{T}}, T2::Type) where T = Try{T2}

TypeClasses.fmap(::Traitsof, f, x::Try{T, Success}) where T = @Try f(x.value)
function TypeClasses.fmap(::Traitsof, f, x::Try{T, Exception}) where T
  T2 = Core.Compiler.return_type(f, Tuple{T})
  Try{T2, Exception}(x.value)
end

TypeClasses.ap(::Traitsof, f::Try{F, Success}, x::Try{T, Success}) where {F, T} = @Try f.value(x.value)
TypeClasses.ap(::Traitsof, f::Try{F, Exception}, x::Try{T, Success}) where {F, T} = ap_Try_Exception(F, T, f.value)
TypeClasses.ap(::Traitsof, f::Try{F, Exception}, x::Try{T, Exception}) where {F, T} = ap_Try_Exception(F, T, f.value)
TypeClasses.ap(::Traitsof, f::Try{F, Success}, x::Try{T, Exception}) where {F, T} = ap_Try_Exception(F, T, x.value)
function ap_Try_Exception(F, T, exception)
  T2 = return_type_FunctionType(F, Tuple{T}) # TODO this is probably very slow...
  Try{T2}(exception)
end

# flatten implementation which still works with missing type information
TypeClasses.fflatten(::Traitsof, x::Try{T, Exception}) where T = x
TypeClasses.fflatten(::Traitsof, x::Try{F, Exception}) where {T, F <: Try{T}} = Try{T, Exception}(x.value)
TypeClasses.fflatten(::Traitsof, x::Try{<:Any, Success}) = x.value  # TODO more restrictive constrain <:Try needed?

TypeClasses.pure(::Traitsof, ::Type{T}, a) where T <: Try = Try(a)


# Sequence
# ========

TypeClasses.sequence(traitsof::Traitsof, x::Try{T}) where T = sequence_Try_traits(traitsof, x, traitsof(T))

sequence_Try_traits(::Traitsof, x::Try{T, Exception}, ::TypeLB(Pure)) where T = TypeClasses.pure(traitsof, T, Try{Any, Exception}(x.value))
function sequence_Try_traits(::Traitsof, x::Try{T, Exception}, ::TypeLB(Pure, Functor)) where T
  E = feltype(traitsof, T)
  TypeClasses.pure(traitsof, T, Try{E, Exception}(x.value))
end
sequence_Try_traits(::Traitsof, x::Try{T, Success}, ::TypeLB(Functor)) where T = TypeClasses.fmap(traitsof, Try, x.value)


# flatten implementation which still works with missing type information
Base.Iterators.flatten(x::Try{T, Exception}) where T = x
Base.Iterators.flatten(x::Try{F, Exception}) where {T, F <: Try{T}} = Try{T, Exception}(x.value)
Base.Iterators.flatten(x::Try{<:Any, Success}) = x.value  # TODO more restrictive constrain <:Try needed?
