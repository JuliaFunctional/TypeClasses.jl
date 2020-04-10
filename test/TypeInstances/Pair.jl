# MonoidAlternative
# =================

a = "a" => [1]
b = "b" => [2,3,4]

@test a ⊕ b == ("ab" => [1,2,3,4])
