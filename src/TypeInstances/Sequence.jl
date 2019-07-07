#= we decided against the Sequence flattening as this does not align with foreach semantic

# generic Sequence implementation for flatten
# ===========================================

# we cannot just default to sequence, as this gives unintuitive results if you don't want this
# if this is wanted, just define it yourself (Functions)
# fflatten_traits_default(traitsof::Traitsof, s, TraitsS::TypeLB(Sequence)) = sequence(traitsof, s)

# for now we still leave this enabled, as this is a very nice default for triples
function fflatten_traits_default(traitsof::Traitsof, s::S, TraitsS::TypeLB(Sequence, Functor)) where S
  A = feltype(traitsof, S)
  fflatten_traits_Sequence_Functor(traitsof, s, A, TraitsS, traitsof(A))
end

function fflatten_traits_Sequence_Functor(traitsof::Traitsof, s::S, A, TraitsS, TraitsA::TypeLB(Functor)) where S
  E = feltype(traitsof, A) # E = Element
  T = change_feltype(traitsof, S, E) # T = new S
  B = change_feltype(traitsof, A, T) # A = new B
  fflatten_traits_Sequence_Functor_Functor(traitsof, s, A, E, T, B, TraitsS, TraitsA, traitsof(E), traitsof(T), traitsof(B))
end

function fflatten_traits_Sequence_Functor_Functor(traitsof::Traitsof, s, A, E, T, B, TraitsS, TraitsA, TraitsE, TraitsT::TypeLB(FFlatten), TraitsB)
  fmap(traitsof, x -> fflatten(traitsof, x), sequence(traitsof, s))
end

=#
