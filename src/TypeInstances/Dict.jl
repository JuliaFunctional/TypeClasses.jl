using TypeClasses
using Traits
using IsDef

# Monoid Instances for standard Dict
# ===================================

# generic neutral for Dict
TypeClasses.neutral(::Type{Dict{K, V}}) where {K, V} = Dict{K, V}()

# generic combine/⊕ for Dict
TypeClasses.combine(d1::Dict, d2::Dict) = merge(d1, d2)

# Dict does not support map, as it would restrict the function applied to return Pairs and not arbitrary types
# TypeClasses.map(f, d::Dict) = Dict(f(pair) for pair in d)

# NOTE, For other TypeClasses see FunctorDict.jl which define normal Functor, Monad, Monoid and FlipTypes on FunctorDict
