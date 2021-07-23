# Define and test Monoid instance for Int
# ---------------------------------------

TypeClasses.combine(a::Int, b::Int) = a + b

@test reduce_monoid([1,2,3,1]) == 7
@test foldl_monoid([1,2,3,4]) == 10
@test foldr_monoid([1,2,3,100], init=3000) == 3106


# Test default Semigroup instance for String
# ------------------------------------------

@test reduce_monoid(["hi"," ","du"], init="!") == "!hi du"


# Test `neutral` singleton value
# ------------------------------

@test combine(neutral, :anything) == :anything
@test combine("anything", neutral) == "anything"
@test combine(neutral, neutral) == neutral