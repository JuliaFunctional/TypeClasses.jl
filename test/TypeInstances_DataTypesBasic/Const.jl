using DataTypesBasic

@test map(string, Const(4)) isa Const{Int}
@test map(string, Const(4)).value == 4
@test eltype(Const(4)) == Any
