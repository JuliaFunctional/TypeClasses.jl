# Define and test Monoid instance for Int
# ---------------------------------------

TypeClasses.combine(a::Int, b::Int) = a + b
TypeClasses.neutral(::Type{Int}) = 0
traitsof_refixate()
traitsof(Int)
@test reduce([1,2,3,1]) == 7
@test foldl([1,2,3,4]) == 10
@test foldr([1,2,3,100]) == 106


# Test default Semigroup instance for String
# ------------------------------------------

@test reduce(["hi"," ","du"]; init = "!") == "!hi du"


# Define and Test neutral for functions
# -------------------------------------

myfunction(a, b) = a * b
TypeClasses.neutral(::Traitsof, ::typeof(myfunction)) = ones
traitsof_refixate()

@test reduce(myfunction, [1,2,3,4]) == 1*2*3*4
