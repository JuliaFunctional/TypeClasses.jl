using Test

left = flip_types([
  Option(1),
  Option(:b)])
right = Option([1, :b])

@test left == right
