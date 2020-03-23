using Test

left = flip_types([
  FunctorDict(:a => 1, :b => 2),
  FunctorDict(:b => 1, :c => 2)])
right = FunctorDict(:a => [1], :b => [2,1], :c => [2])

@test left == right
