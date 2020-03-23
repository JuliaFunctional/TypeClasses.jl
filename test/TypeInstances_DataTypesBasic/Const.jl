using DataTypesBasic

@test map(string, Const(4)) isa Const{AbstractString, Int}
@test map(string, Const(4)).value == 4
@test eltype(Const{AbstractFloat}(4)) == AbstractFloat
