# Monoid instances
# ================

neutral(::Traitsof, ::typeof(+)) = zero
neutral(::Traitsof, ::typeof(*)) = one


# Monad instances
# ===============

fmap_traits_Callable(::Traitsof, f, g) = (args...; kwargs...) -> f(g(args...; kwargs...))
fmap_traits(traitsof::Traitsof, f, g, TraitsF, TraitsG::TypeLB(Callable)) = fmap_traits_Callable(traitsof, f, g)


pure_traits_Callable(::Traitsof, G, a) = (args...; kwargs...) -> a
pure_traits(traitsof::Traitsof, G, a, TraitsG::TypeLB(Callable), TraitsA) = pure_traits_Callable(traitsof, G, a)

ap_traits_Callable(::Traitsof, f, g) = (args...; kwargs...) -> f(args...; kwargs...)(g(args...; kwargs...))
ap_traits(traitsof::Traitsof, f, g, TraitsF::TypeLB(Callable), TraitsG::TypeLB(Callable)) = ap_traits_Callable(traitsof, f, g)

fflatten_traits_Callable(traitsof::Traitsof, g) = (args...; kwargs...) -> g(args...; kwargs...)(args...; kwargs...)
fflatten_traits(traitsof::Traitsof, g, TraitsG::TypeLB(Callable)) = fflatten_traits_Callable(traitsof, g)
