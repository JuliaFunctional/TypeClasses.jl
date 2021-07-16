using .Dictionaries

# Monoid / Alternative
# ====================

TypeClasses.neutral(T::Type{<:AbstractDictionary}) = T()

# generic combine/⊕ for Dict: using ⊕ on the elements when needed
"""
```jldoctest
julia> using TypeClasses, Dictionaries

julia> dict1 = Dictionary([:a, :b, :c], ["1", "2", "3"])
3-element Dictionaries.Dictionary{Symbol, String}
 :a │ "1"
 :b │ "2"
 :c │ "3"

julia> dict2 = Dictionary([:b, :c, :d], ["4", "5", "6"])
3-element Dictionaries.Dictionary{Symbol, String}
 :b │ "4"
 :c │ "5"
 :d │ "6"

julia> dict1 ⊕ dict2
4-element Dictionaries.Dictionary{Symbol, String}
 :a │ "1"
 :b │ "24"
 :c │ "35"
 :d │ "6"
```
"""
function TypeClasses.combine(d1::AbstractDictionary, d2::AbstractDictionary)
    d1_combined = map(pairs(d1)) do (key, value)
        if key in keys(d2)
            value ⊕ d2[key]
        else
            value
        end
    end
    remaining_keys = setdiff(keys(d2), keys(d1))
    merge(d1_combined, getindices(d2, remaining_keys))
end



# generic orelse/⊘ for Dict
"""
    orelse(d1::Dict, d2::Dict) -> Dict

Following the orelse semantics on Option values, the first value is retained, and the second is dropped.
Hence this is the flipped version of `Base.merge`.
"""
TypeClasses.orelse(d1::AbstractDictionary, d2::AbstractDictionary) = merge(d2, d1)



# Functor / Applicative / Monad
# =============================

# adapted from the Scala Cats implementation https://github.com/typelevel/cats/blob/main/core/src/main/scala/cats/instances/map.scala

# map/foreach are already defined

# there is no TypeClasses.pure implementation because we cannot come up with an arbitrary key

"""
```jldoctest
julia> using TypeClasses, Dictionaries

julia> dict1 = Dictionary(["a", "b", "c"], [1, 2, 3])
3-element Dictionaries.Dictionary{String, Int64}
 "a" │ 1
 "b" │ 2
 "c" │ 3

julia> dict2 = Dictionary(["b", "c", "d"], [2, 3, 4])
3-element Dictionaries.Dictionary{String, Int64}
 "b" │ 2
 "c" │ 3
 "d" │ 4

mapn(+, dict1, dict2)
2-element Dictionaries.Dictionary{String, Int64}
 "b" │ 4
 "c" │ 6
```
"""
# TypeClasses.ap(f::AbstractDictionary, d::AbstractDictionary) = TypeClasses.default_ap_having_map_flatmap(f, d)

"""
```jldoctest
julia> using TypeClasses, Dictionaries

julia> dict = Dictionary(["a", "b", "c"], [1, 2, 3])
3-element Dictionaries.Dictionary{String, Int64}
 "a" │ 1
 "b" │ 2
 "c" │ 3

julia> f(x) = Dictionary(["b", "c", "d"], [10x, 20x, 30x])
f (generic function with 1 method)

julia> flatmap(f, dict)
2-element Dictionaries.Dictionary{String, Int64}
 "b" │ 20
 "c" │ 60
```
"""
function TypeClasses.flatmap(f, d::AbstractDictionary)
    returntype = Core.Compiler.return_type(f, Tuple{eltype(d)})
    result = similar(d, eltype(returntype))
    isused = fill(false, d)

    for (key, value) in pairs(d)
        subdict = f(value)
        # only add the key if key appears in both Dictionaries
        if key in keys(subdict)
            result[key] = subdict[key]
            isused[key] = true
        end
    end
    # finally we may have lost a couple of keys
    getindices(result, findall(isused))
end


# FlipTypes
# =========

"""
```jldoctest
julia> using TypeClasses, Dictionaries

julia> d1 = dictionary([:a => Option(1), :b => Option(2)])
2-element Dictionaries.Dictionary{Symbol, Identity{Int64}}
 :a │ Identity(1)
 :b │ Identity(2)

julia> flip_types(d1)
Identity({:a = 1, :b = 2})

julia> d2 = dictionary([:a => Option(1), :b => Option()])
2-element Dictionaries.Dictionary{Symbol, Option{Int64}}
 :a │ Identity(1)
 :b │ Const(nothing)

julia> flip_types(d2)
Const(nothing)
```
"""
function TypeClasses.flip_types(a::A) where A <: AbstractDictionary
    iter = pairs(a)
    first = iterate(iter)
    constructdict(key, c) = fill(c, getindices(a, Indices([key])))  # using fill to create the correct type automatically
      
    if first === nothing
      # only in this case we actually need `pure(eltype(A))` and `neutral(A)`
      # for non-empty sequences everything works for Types without both
      pure(eltype(A), neutral(Base.typename(A).wrapper))
    else
      (key, b), state = first
      start = map(c -> constructdict(key, c), b)  # we can only combine on ABC
      Base.foldl(Iterators.rest(iter, state); init = start) do acc, (key, b)
        mapn(acc, b) do acc′, c  # working in applicative context B
          acc′ ⊕ constructdict(key, c)  # combining on AC
        end
      end
    end
end
