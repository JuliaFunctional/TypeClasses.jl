using TypeClasses
using Test
using Distributed: Future, @spawnat

@test fetch(pure(Future, 4)) == 4

t = @spawnat :any begin
  sleep(0.3)
  4
end
tt = map(t) do x
  x*x
end
@test fetch(tt) == 16


t11 = @spawnat :any begin
  sleep(0.5)
  11
end
t12 = @spawnat :any begin
  sleep(0.5)
  12
end
@test typeof(mapn(+, t11, t12)) === Future
@test fetch(mapn(+, t11, t12)) == 11+12

t2 = @syntax_flatmap begin
  a = @spawnat :any begin sleep(0.5); 5 end
  b = @spawnat :any begin sleep(a); a + 3 end
  @pure a, b
end
@test fetch(t2) == (5, 5+3)
