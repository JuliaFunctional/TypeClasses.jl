TypeClasses.fforeach(::Traitsof, f, c::Const) = nothing
TypeClasses.fmap(::Traitsof, f, c::Const) = c

TypeClasses.feltype(::Traitsof, ::Type{<:Const}) = Any
TypeClasses.change_feltype(::Traitsof, c::Type{<:Const}, A) = c
