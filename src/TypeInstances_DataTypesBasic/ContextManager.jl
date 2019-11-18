# FunctorApplicativeMonad
# =======================

function TypeClasses.fforeach(::Traitsof, f, c::ContextManager)
  TypeClasses.fmap(traitsof, f, c)(x -> x)
  nothing
end

TypeClasses.fmap(::Traitsof, f, c::ContextManager) = @ContextManager cont -> begin
  c(x -> cont(f(x)))
end

# TypeClasses.feltype defaults to eltype

# TODO we don't care about F for now, maybe this leads to some bugs
TypeClasses.change_feltype(::Traitsof, ::Type{<:ContextManager{A, F}}, B) where {A, F} = ContextManager{B, F}




TypeClasses.pure(traitsof::Traitsof, ::Type{ContextManager}, x) = @ContextManager cont -> cont(x)

# we use the default implementation of ap which follows from flatten
# TypeClasses.ap

function TypeClasses.fflatten(traitsof::Traitsof, c::ContextManager{T, F}) where {T, F}
  # despite ContextManager does not parameterize the return value of the continuation, we can infer it
  if T <: ContextManager
    @ContextManager cont -> begin
      # execute both nested ContextManagers in the nested manner
      c() do cc
        cc(cont)
      end
    end
  else
    # if this is not a nested ContextManager, we default to a yet undefined function
    flatten_ContextManager_NonContextManager(traitsof, c, T)
  end
end

"""
  by default just flatten nothing

(this will get flattened in the outer call to flatten which triggers an extra flatten call if applicable)

overwrite this for with your special elementtype E
"""
flatten_ContextManager_NonContextManager(traitsof::Traitsof, c, T) = c



# relaxed flatten definition
# --------------------------

# ContextManager can be regarded as a mere singleton, hence we can fflatten into anything

# if the subtype is itself a Functor we take this as enough information to flatten twice
# 1) the ContextManager, 2) the outer monad again
# this is done because flatten on ContextManager defaults to do nothing,
# so there actually may be the possibility of an additional flatten
function fflatten_traits_Functor_ContextManager(traitsof::Traitsof, a, ::TypeLB(Functor))
  TypeClasses.fflatten(traitsof, TypeClasses.fmap(traitsof, b -> b(x->x), a))
end
# if no functor, just flatten the contextmanager (x->x)
function fflatten_traits_Functor_ContextManager(traitsof::Traitsof, a, _)
  TypeClasses.fmap(traitsof, b -> b(x->x), a)
end
function TypeClasses.fflatten_traits_Functor(traitsof::Traitsof, a, B::Type{<:ContextManager{T}}, _, _) where T
  fflatten_traits_Functor_ContextManager(traitsof, a, traitsof(T))
end



# Maybe, Try, Either need to be handled individually because their own fflatten takes precedence over the generic one just defined

function TypeClasses.fflatten(traitsof::Traitsof, a::Maybe{<:ContextManager{T}, Some}) where T
  fflatten_Maybe_ContextManager(traitsof, a, traitsof(T))
end
# if subtype is Functor flatten twice
fflatten_Maybe_ContextManager(traitsof::Traitsof, a, ::TypeLB(Functor)) = a.value(x -> x)
# else flat only the ContextManager and preserve the outer Monad
fflatten_Maybe_ContextManager(traitsof::Traitsof, a, _) = TypeClasses.fmap(traitsof, b -> b(x->x), a)

# TODO Currently there are no TypeVar for UnionAll types so that we cannot generalize the code for Maybe/Either/Try at once. At least it seems so



function TypeClasses.fflatten(traitsof::Traitsof, a::Try{<:ContextManager{T}, Success}) where T
  fflatten_Try_ContextManager(traitsof, a, traitsof(T))
end
# if subtype is Functor flatten twice
fflatten_Try_ContextManager(traitsof::Traitsof, a, ::TypeLB(Functor)) = a.value(x -> x)
# else flat only the ContextManager and preserve the outer Monad
fflatten_Try_ContextManager(traitsof::Traitsof, a, _) = TypeClasses.fmap(traitsof, b -> b(x->x), a)



function TypeClasses.fflatten(traitsof::Traitsof, a::Either{<:Any, <:ContextManager{T}, Right}) where T
  fflatten_Either_ContextManager(traitsof, a, traitsof(T))
end
# if subtype is Functor flatten twice
fflatten_Either_ContextManager(traitsof::Traitsof, a, ::TypeLB(Functor)) = a.value(x -> x)
# else flat only the ContextManager and preserve the outer Monad
fflatten_Either_ContextManager(traitsof::Traitsof, a, _) = TypeClasses.fmap(traitsof, b -> b(x->x), a)



# Sequence
# ========

# does not make much sense as if I would sequence ContextManager, I need to evaluate the context
# hence I could directly fflatten instead
