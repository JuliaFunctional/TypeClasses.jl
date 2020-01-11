
# MonoidAlternative
# =================

# Maybe Monoid instance, as Nothing can work as neutral element
# taken from haskell http://hackage.haskell.org/package/base-4.12.0.0/docs/src/GHC.Base.html#line-419
TypeClasses.neutral(::Traitsof, ::Type{Maybe{T}}) where T = Maybe{T}(nothing)
TypeClasses.neutral(::Traitsof, ::Type{Maybe}) = Maybe(nothing)

TypeClasses.combine(::Traitsof, x1::Maybe{T, Some}, x2::Maybe{S, Nothing}) where {T, S} = x1
TypeClasses.combine(::Traitsof, x1::Maybe{T, Nothing}, x2::Maybe) where T = x2  # we cannot shot cycle as the neutral element must have no effect on combine
function TypeClasses.combine(traitsof::Traitsof, x1::Maybe{T, Some}, x2::Maybe{T, Some}) where T
  Maybe{T, Some}(TypeClasses.combine(traitsof, x1.value::T, x2.value::T))
end
combine_MaybeSome_traits(traitsof::Traitsof, v1, v2, ::TypeLB(Combine)) = TypeClasses.combine(traitsof, v1, v2)

# Maybe Applicative instance, here just realized via orelse implementation
TypeClasses.orelse(::Traitsof, x1::Maybe{T, Some},xm2::Maybe) where T = x1
TypeClasses.orelse(::Traitsof, x1::Maybe{T, Nothing}, x2::Maybe) where T = x2


# FunctorApplicativeMonad
# =======================

TypeClasses.feltype(::Traitsof, ::Type{M}) where {T, M <: Maybe{T}} = T
TypeClasses.change_eltype(::Traitsof, ::Type{Maybe{T, Tag}}, T2::Type) where {T, Tag} = Maybe{T2, Tag}
TypeClasses.change_eltype(::Traitsof, ::Type{Maybe{T}}, T2::Type) where T = Maybe{T2}


function TypeClasses.fmap(::Traitsof, f, ::Maybe{T, Nothing}) where T
  T2 = Core.Compiler.return_type(f, Tuple{T})
  Maybe{T2, Nothing}(nothing)
end
TypeClasses.fmap(::Traitsof, f, x::Maybe{T, Some}) where T = Maybe(f(x.value))

TypeClasses.ap(::Traitsof, f::Maybe{F, Some}, x::Maybe{T, Some}) where {F, T} = Maybe(f.value(x.value))
TypeClasses.ap(::Traitsof, f::Maybe{F}, x::Maybe{T}) where {F, T} = ap_Maybe_nothing(F, T)
function ap_Maybe_nothing(F, T)
  T2 = return_type_FunctionType(F, Tuple{T}) # TODO this is probably very slow...
  Maybe{T, Nothing}(nothing)
end

TypeClasses.pure(::Traitsof, ::Type{<:Maybe}, a) = Maybe(a)

TypeClasses.fflatten(::Traitsof, x::Maybe{T, Nothing}) where T = Maybe{T}(nothing)
TypeClasses.fflatten(::Traitsof, x::Maybe{<:Any, Some}) = x.value  # TODO or better constrain this to <:Maybe only?


function return_type_FunctionType(F, TupleTypeArgs)
  try
    Core.Compiler.return_type(F.instance, TupleTypeArgs)
  catch e
    e isa UndefRefError ? Any : rethrow()
  end
end


# Sequence
# ========

TypeClasses.sequence(traitsof::Traitsof, x::Maybe{T}) where T = sequence_Maybe_traits(traitsof, x, traitsof(T))

sequence_Maybe_traits(::Traitsof, x::Maybe{T, Nothing}, ::TypeLB(Pure)) where T = TypeClasses.pure(traitsof, T, Maybe(nothing))
function sequence_Maybe_traits(::Traitsof, x::Maybe{T, Nothing}, ::TypeLB(Pure, Functor)) where T
  E = feltype(traitsof, T)
  TypeClasses.pure(traitsof, T, Maybe{E, Nothing}(nothing))
end
sequence_Maybe_traits(::Traitsof, x::Maybe{T, Some}, ::TypeLB(Functor)) where T = TypeClasses.fmap(traitsof, Maybe, x.value)
