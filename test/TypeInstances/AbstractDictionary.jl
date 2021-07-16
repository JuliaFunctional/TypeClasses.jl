using Test
using TypeClasses
using Dictionaries


# MonoidAlternative
# =================

@test neutral(Dictionary) == Dictionary()
@test neutral(Dictionary{String, Int}) == Dictionary{String, Int}()


# we can combine any Dict where elements can be combined 
d1 = dictionary([:a => "3", :b => "1"])
d2 = dictionary([:a => "5", :b => "9", :c => "15"])

@test d1 ⊕ d2 == dictionary([:a => "35", :b => "19", :c => "15"])

@test d1 ⊘ d2 == dictionary([:a => "3", :b => "1", :c => "15"])



dict1 = Dictionary([:a, :b, :c], ["1", "2", "3"])
dict2 = Dictionary([:b, :c, :d], ["4", "5", "6"])
@test dict1 ⊕ dict2 == Dictionary([:a, :b, :c, :d], ["1", "24", "35", "6"])

dict1 = Dictionary(["a", "b", "c"], [1, 2, 3])
dict2 = Dictionary(["b", "c", "d"], [2, 3, 4])
@test mapn(+, dict1, dict2) == Dictionary(["b", "c"], [4, 6])


dict = Dictionary(["a", "b", "c"], [1, 2, 3])
create_dictionary(x) = Dictionary(["b", "c", "d"], [10x, 20x, 30x])

@test flatmap(create_dictionary, dict) == Dictionary(["b", "c"], [20, 60])

d1 = dictionary([:a => Option(1), :b => Option(2)])
@test flip_types(d1) == Identity(Dictionary([:a, :b], [1, 2]))

d2 = dictionary([:a => Option(1), :b => Option()])
@test flip_types(d2) == Const(nothing)


@test flip_types(dictionary((:a => [1,2], :b => [3, 4]))) == [
    dictionary([:a => 1, :b => 3]),
    dictionary([:a => 1, :b => 4]),
    dictionary([:a => 2, :b => 3]),
    dictionary([:a => 2, :b => 4]),
]
@test flip_types([
    dictionary((:a => 1, :b => 2)),
    dictionary((:a => 10, :b => 20)),
    dictionary((:b => 200, :c => 300))
]) == dictionary([:b => [2, 20, 200]])
