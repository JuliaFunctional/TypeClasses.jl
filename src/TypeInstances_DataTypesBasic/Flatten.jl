using DataTypesBasic
DataTypesBasic.@overwrite_Base

# Option, Try, Either
# ===================

function TypeClasses.flatten(v::Some{<:Union{Either, Try}})
  TypeClasses.flatten(TypeClasses.map(getOption, v))
end

function TypeClasses.flatten(v::Right{<:Any, <:Union{Option, Try}})
  TypeClasses.flatten(TypeClasses.map(getEither, v))
end


# Vector, Iterable
# ================


"""
When defining `TypeClasses.flatten` for interactions between Types,
we define them such that their ``TypeClasses.foreach`` definitions are matching

I.e. using @syntax_flatmap should be similar to using @syntax_foreach.

For the interaction with Vector and Iterable this means to treat all Option, Either, Try as mere filters.
"""


const FilterTypes = Union{Option, Try, Either}
keep(v::Option) = issomething(v)
keep(v::Try) = issuccess(v)
keep(v::Either) = isright(v)

function TypeClasses.flatten(v::Vector{<:FilterTypes})
  [a.value for a ∈ v if keep(a)]
end

function TypeClasses.flatten(v::Iterable{<:FilterTypes})
  Iterable(a.value for a ∈ v if keep(a))
end



# ContextManager
# ==============

# A contextmanager capsulates extra computation for a single value and hence can be silently resolved almost everywhere

#=
use case for this relaxed definition: The following works intuitively
```
@syntax_flatmap begin
  i = [1,2,3]
  c = cm(i)
  @pure c + 2
end
# [3,4,5], plus some side-effects of cm()
```
=#

# ContextManager can be regarded as a mere singleton, hence we can flatten it out as a sub-Functor of any other Functor
# Multiple Dispatch however needs us to define the flattening separately for each Functor


FunctorsWithPure = [
  Some,
  (Right_{R} = Right{<:Any, R}; Right_),
  Success,
  Iterable,
  Vector,
]

FunctorsWithoutPure = [
  (Writer_{T} = Writer{<:Any, T}; Writer_),
]

for F in FunctorsWithPure
  @eval function TypeClasses.flatten(a::$(F{<:ContextManager}))
    extramonad(x::DataTypesBasic.FlattenMe) = x.value
    extramonad(x) = pure(typeof(a), x)  # dummy monad to be flattened out again directly
    flatmap(cm -> extramonad(cm(x -> x)), a)
  end
end

for F in FunctorsWithoutPure
  @eval function TypeClasses.flatten(a::$(F{<:ContextManager}))
    # we need a fix_type, because second_flatten assumes correct type-inference
    second_flatten_contextmanager(fix_type(map(cm -> cm(x -> x), a)))
  end
  @eval function second_flatten_contextmanager(a::$(F{<:DataTypesBasic.FlattenMe}))
    flatten(map(x -> x.value, a))
  end
end
second_flatten_contextmanager(no_flattenme) = no_flattenme
