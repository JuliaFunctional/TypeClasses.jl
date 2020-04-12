TypeClasses.change_eltype(c::Type{<:Const{E1}}, E2) where E1 = Const{E2}
TypeClasses.change_eltype(c::Type{<:Const{E1, C}}, E2) where {E1, C} = Const{E2, C}
