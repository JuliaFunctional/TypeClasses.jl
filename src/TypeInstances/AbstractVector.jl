
using TypeClasses

"""
considerations: because `Base.typename(Vector).wrapper == Array`, we dispatch everything on AbstractArray to support AbstractVector.

If later on the AbstractArray should be separated from AbstractVector, someone needs to think about a neat way to circumvent this problem. 
As of now this seems to be a great solution.
"""

# MonoidAlternative
# =================

TypeClasses.neutral(T::Type{<:AbstractArray}) = convert(T, [])
TypeClasses.combine(v1::AbstractArray, v2::AbstractArray) = [v1; v2]  # general syntax which is overloaded by concrete AbstractVector types

# FunctorApplicativeMonad
# =======================

TypeClasses.pure(T::Type{<:AbstractArray}, a) = convert(Base.typename(T).wrapper, [a]) 
TypeClasses.ap(fs::AbstractArray, v::AbstractArray) = vcat((map(f, v) for f in fs)...)

# for flattening we solve type-safety by converting to Vector elementwise
# this also gives well-understandable error messages if something goes wrong
function TypeClasses.flatmap(f, v::AbstractArray)
    type = Base.typename(typeof(v)).wrapper
    vcat((convert(type, f(x)) for x in v)...)
end


# FlipTypes
# =========

# we define flip_types for all Vector despite it only works if the underlying element defines `ap`
# as there is no other sensible definition for Iterable, an error that the element does not implement `ap`
# is actually the correct error
flip_types(v::AbstractArray) = default_flip_types_having_pure_combine_apEltype(v)
