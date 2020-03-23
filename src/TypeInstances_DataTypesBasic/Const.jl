TypeClasses.foreach(f, c::Const) = nothing
TypeClasses.map(f, c::Const) = Base.map(f, c)

TypeClasses.eltype(::Type{<:Const{E}}) where E = E
TypeClasses.eltype(::Type{<:Const}) = Any
TypeClasses.change_eltype(c::Type{<:Const{E1}}, E2) where E1 = Const{E2}
TypeClasses.change_eltype(c::Type{<:Const{E1, C}}, E2) where {E1, C} = Const{E2, C}
