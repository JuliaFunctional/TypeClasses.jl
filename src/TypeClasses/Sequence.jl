function sequence end
const Sequence = typeof(sequence)

# for complex traitsof dependency we recommend to write methods without many dispatches, just assuming everything is fine,
# concretely, Core.Compiler.return_type will probably not work if you aren't super careful
# hence we need to check traits anyway by a custom traitfunction
# where we can add all the dispatch complexity which specifies whether something has a trait

# this infers correctly, really impressive, see e.g. `code_typed(TypeClasses.sequence, Tuple{ConcreteTraitsof, Vector{String}})`
# still inference may be a bit tough because of change_feltype involved which may not always infer...
# TODO and we don't know yet how to check whether inference Core.Compiler.return_type was too generous in returning Any for instance

sequence(traitsof::Traitsof, s::S) where S = sequence_traits(traitsof, s, traitsof(S))
@create_default sequence_traits

function sequence_traits_default(traitsof::Traitsof, s::S, STraits::TypeLB(Functor)) where S
  A = feltype(traitsof, S) # A = Applicative
  sequence_traits_Functor(traitsof, s, A, STraits, traitsof(A))
end
# TODO also include A, E, T, B for further dispatching
function sequence_traits_Functor(traitsof::Traitsof, s::S, A, STraits, ATraits::TypeLB(Functor)) where S
  # usually also type-information from the following types T and B are needed for sequence
  E = feltype(traitsof, A) # E = Element
  T = change_feltype(traitsof, S, E) # T = new S
  B = change_feltype(traitsof, A, T) # A = new B
  # Note that traitsof only work on types because of being generated function
  # hence even if we want to we cannot use actual content as information
  sequence_traits_Functor_Functor(traitsof, s, A, E, T, B, STraits, ATraits, traitsof(E), traitsof(T), traitsof(B))
end

# sequence should infer properly right now
@traitsof_push! function(traitsof::Traitsof, T::Type)
  if functiondefined(sequence, Tuple{typeof(traitsof), T})
    Sequence
  end
end
