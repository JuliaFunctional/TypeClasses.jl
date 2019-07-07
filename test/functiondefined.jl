# advanced functiondefined test
# Problem: we had run into Stackoverflow problems with tiny code changes on the definition of `functiondefined`
# unfortunately that only appeared in this more complex TypeClasses scenario so we at least include the test here
# TODO but ideally of course it would be nice to have a test of similar power in Traits itself

using Traits.BasicTraits
@test traitsof(String) == Union{Iterate, ConcreteType, Mutable, NoBitsType, Combine, Neutral}
