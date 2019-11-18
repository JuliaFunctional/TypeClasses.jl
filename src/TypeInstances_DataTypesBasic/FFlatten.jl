"""
we define FFlatten definitions for all singleton datatypes
  according to their fforeach definition

I.e. using @syntax_fflatmap should be similar to using @syntax_fforeach
which forces to treat all Maybe, Either, Try as mere filters
"""


# Dict
# ----

function TypeClasses.fflatten(::Traitsof, d::Dict{K,<:Maybe}) where K
  Dict(k => v.value for (k, v) ∈ d if issomething(v))
end

function TypeClasses.fflatten(::Traitsof, d::Dict{K,<:Try}) where K
  Dict(k => v.value for (k, v) ∈ d if issuccess(v))
end

function TypeClasses.fflatten(::Traitsof, d::Dict{K,<:Either}) where K
  Dict(k => v.value for (k, v) ∈ d if isright(v))
end


# Vector
# ------

function TypeClasses.fflatten(::Traitsof, v::Vector{<:Maybe})
  [a.value for a ∈ v if issomething(a)]
end

function TypeClasses.fflatten(::Traitsof, v::Vector{<:Try})
  [a.value for a ∈ v if issuccess(a)]
end

function TypeClasses.fflatten(::Traitsof, v::Vector{<:Either})
  [a.value for a ∈ v if isright(a)]
end
