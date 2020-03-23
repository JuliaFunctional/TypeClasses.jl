# Define and test Monoid instance for Int
# ---------------------------------------

TypeClasses.combine(a::Int, b::Int) = a + b
TypeClasses.neutral(::Type{Int}) = 0

@test reduce([1,2,3,1]) == 7
@test foldl([1,2,3,4]) == 10
@test foldr([1,2,3,100]) == 106


# Test default Semigroup instance for String
# ------------------------------------------

@test reduce("!", ["hi"," ","du"]) == "!hi du"


# Define and Test neutral for functions
# -------------------------------------

myfunction(a, b) = a * b
TypeClasses.neutral(::Type{typeof(myfunction)}) = one
@test isNeutral(myfunction)
@test isNeutral(typeof(myfunction))
@test reduce(myfunction, [1,2,3,4]) == 1*2*3*4


# TODO Test Alternative
