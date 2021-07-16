using TypeClasses

"""
IMPORTANT: we do NOT support AbstractDict, because there is no general way to map over such a type,
i.e. we cannot easily construct new AbstractDict from the same type, but with small alterations.
"""

# Monoid Instances for standard Dict
# ===================================

# generic neutral for Dict
TypeClasses.neutral(::Type{Dict}) = Dict()
TypeClasses.neutral(::Type{Dict{K, V}}) where {K, V} = Dict{K, V}()

# generic combine/⊕ for Dict: using ⊕ on the elements when needed
function TypeClasses.combine(d1::Dict, d2::Dict)
    newdict = Dict(
        key => haskey(d2, key) ? value ⊕ d2[key] : value 
        for (key, value) in d1)
    for (key, value) in d2
        if !haskey(newdict, key)
            push!(newdict, key => value)
        end
    end
    newdict
end

# generic orelse/⊘ for Dict
"""
    orelse(d1::Dict, d2::Dict) -> Dict

Following the orelse semantics on Option values, the first value is retained, and the second is dropped.
Hence this is the flipped version of `Base.merge`.
"""
TypeClasses.orelse(d1::Dict, d2::Dict) = merge(d2, d1)


# Functor/Applicative/Monad
# =========================

# Dict does not support map, as it would restrict the function applied to return Pairs and not arbitrary types
# TypeClasses.map(f, d::Dict) = Dict(f(pair) for pair in d)



# FlipTypes
# =========

function TypeClasses.flip_types(a::Dict)
    iter = a
    first = iterate(iter)

    if first === nothing
      # only in this case we actually need `pure(eltype(A))` and `neutral(A)`
      # for non-empty sequences everything works for Types without both
      pure(eltype(a), neutral(Dict))
    else
      (key, b), state = first
      start = map(c -> Dict(key => c), b)  # we can only combine on ABC
      Base.foldl(Iterators.rest(iter, state); init = start) do acc, (key, b)
        mapn(acc, b) do acc′, c  # working in applicative context B
          acc′ ⊕ Dict(key => c)  # combining on AC
        end
      end
    end
end