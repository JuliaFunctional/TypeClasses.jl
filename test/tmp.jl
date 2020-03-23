using Traits

a = []
push!(a, 3)
push!(a, 4.0)
push!(a, true)
push!(a, "hi")

function vector_elemtype_union(a::Vector{Any})
  types = typeof.(a)
  newtype = Union{types...}  # never generates Any as no concrete types is of type Any
  convert(Vector{newtype}, a)
end

function vector_elemtype_union2(a::Vector{Any})
  types = typeof.(a)
  newtype = typejoin(types...)  # generates Any quickly
  convert(Vector{newtype}, a)
end

vector_elemtype_union(a)
vector_elemtype_union2(a)
