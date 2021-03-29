using Test
using TypeClasses

# MonoidAlternative
# =================

# we can combine any Dict
d1 = Dict(:a => 3, :b => 1)
d2 = Dict(:a => 5, :b => 9, :c => 15)
@test d1 ⊕ d2 == Dict(:a => 5, :b => 9, :c => 15)
