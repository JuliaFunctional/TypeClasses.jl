# MonoidAlternative
# =================

# there is no neutral definition for Either, however both combine and orelse make sense
# this also leverages sequence for dict and vector

# orelse keeps first Right
TypeClasses.orelse(::Traitsof, x1::Either{L, R, Right}, x2::Either) where {L, R} = x1
TypeClasses.orelse(::Traitsof, x1::Either{L, R, Left}, x2::Either) where {L, R} = x2

# combine keeps Left, otherwise combines nested values
TypeClasses.combine(::Traitsof, x1::Either{L, R, Right}, x2::Either{L2, R2, Left}) where {L, R, L2, R2} = x2
TypeClasses.combine(::Traitsof, x1::Either{L, R, Left}, x2::Either{L2, R2, Right}) where {L, R, L2, R2} = x1
function TypeClasses.combine(traitsof::Traitsof, x1::Either{L, R, Right}, x2::Either{L, R, Right}) where {L, R}
  Either{L, R, Right}(TypeClasses.combine(traitsof, x1.value::R, x2.value::R))
end
function TypeClasses.combine(traitsof::Traitsof, x1::Either{L, R, Left}, x2::Either{L, R, Left}) where {L, R}
  Either{L, R, Left}(TypeClasses.combine(traitsof, x1.value::L, x2.value::L))
end

# FunctorApplicativeMonad
# =======================

TypeClasses.feltype(::Traitsof, ::Type{E}) where {L, R, E <: Either{L, R}} = R
TypeClasses.change_eltype(::Traitsof, ::Type{Either{L, R, Tag}}, R2::Type) where {L, R, Tag} = Either{L, R2, Tag}
TypeClasses.change_eltype(::Traitsof, ::Type{Either{L, R}}, R2::Type) where {L, R} = Either{L, R2}

TypeClasses.fmap(::Traitsof, f, x::Either{L, R, Right}) where {L, R} = Either{L}(f(x.value))
function TypeClasses.fmap(::Traitsof, f, x::Either{L, R, Left}) where {L, R}
  R2 = Core.Compiler.return_type(f, Tuple{R})
  Either{L, R2}(x.value)
end

TypeClasses.ap(::Traitsof, f::Either{L, F, Right}, x::Either{L, R, Right}) where {F, L, R} = Either{L}(f.value(x.value))
TypeClasses.ap(::Traitsof, f::Either{L, F, Left}, x::Either{L, R, Right}) where {F, L, R} = ap_Either_left(F, L, R, f.value)
TypeClasses.ap(::Traitsof, f::Either{L, F, Left}, x::Either{L, R, Left}) where {F, L, R} = ap_Either_left(F, L, R, f.value)
TypeClasses.ap(::Traitsof, f::Either{L, F, Right}, x::Either{L, R, Left}) where {F, L, R} = ap_Either_left(F, L, R, x.value)
function ap_Either_left(F, L, R, left)
  R2 = return_type_FunctionType(F, Tuple{R}) # TODO this is probably very slow...
  Either{L, R2}(left)
end

# left implementation which still works with missing type information
TypeClasses.fflatten(::Traitsof, x::Either{L, R, Left}) where {L, R} = e
TypeClasses.fflatten(::Traitsof, x::Either{L, E, Left}) where {L, R, E <: Either{L, R}} = Either{L, R, Left}(x.value)  # just to have better type support
TypeClasses.fflatten(::Traitsof, x::Either{L, R, Right}) where {L, R} = x.value  # TODO or does this need to be more restrictive? like ``x::Either{L, E, Right} where {L, R, E <: Either{L, R}}``

TypeClasses.pure(::Traitsof, ::Type{E}, a) where {L, E <: Either{L}} = Either{L}(a)
TypeClasses.pure(::Traitsof, ::Type{Either}, a) = Either{Any}(a)


# Sequence
# ========

TypeClasses.sequence(traitsof::Traitsof, x::Either{L, R}) where {L, R} = sequence_Either_traits(traitsof, x, traitsof(L), traitsof(R))

sequence_Either_traits(::Traitsof, x::Either{L, R, Left}, TraitsL, TraitsR::TypeLB(Pure)) where {L, R} = TypeClasses.pure(traitsof, R, Either{L, Any, Left}(x.value))
function sequence_Either_traits(::Traitsof, x::Either{L, R, Left}, TraitsL, TraitsR::TypeLB(Pure, Functor)) where {L, R}
  E = feltype(traitsof, R)
  TypeClasses.pure(traitsof, T, Either{L, E, Left}(x.value))
end
sequence_Either_traits(::Traitsof, x::Either{L, R, Right}, TraitsL, TraitsR::TypeLB(Functor)) where {L, R} = TypeClasses.fmap(traitsof, x -> Either{L}(Right(x)), x.value)




# left implementation which still works with missing type information
Base.Iterators.flatten(x::Either{L, R, Left}) where {L, R} = e
Base.Iterators.flatten(x::Either{L, E, Left}) where {L, R, E <: Either{L, R}} = Either{L, R, Left}(x.value)  # just to have better type support
Base.Iterators.flatten(x::Either{L, R, Right}) where {L, R} = x.value  # TODO or does this need to be more restrictive? like ``x::Either{L, E, Right} where {L, R, E <: Either{L, R}}``
