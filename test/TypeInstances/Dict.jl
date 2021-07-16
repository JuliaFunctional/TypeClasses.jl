using Test
using TypeClasses

# MonoidAlternative
# =================

@test neutral(Dict) == Dict()
@test neutral(Dict{String, Int}) == Dict{String, Int}()


# we can combine any Dict where elements can be combined 
d1 = Dict(:a => "3", :b => "1")
d2 = Dict(:a => "5", :b => "9", :c => "15")

@test d1 ⊕ d2 == Dict(:a => "35", :b => "19", :c => "15")

@test d1 ⊘ d2 == Dict(:a => "3", :b => "1", :c => "15")


# FlipTypes
# =========

@test flip_types(Dict(:a => [1,2], :b => [3, 4])) == [
    Dict(:a => 1, :b => 3),
    Dict(:a => 1, :b => 4),
    Dict(:a => 2, :b => 3),
    Dict(:a => 2, :b => 4),
]

# the other way arround does not work, as Dict does not implement Functor/Applicative/Monad interfaces
# this is not a MethodError, but a special exception thrown intentionally by Base
@test_throws ErrorException flip_types([d1, d2])