using TypeClasses
using Test

@test fetch(pure(Task, 4)) == 4

t = @async begin
  sleep(0.3)
  4
end
tt = map(t) do x
  x*x
end
@test fetch(tt) == 16


t11 = @async begin
  sleep(0.5)
  11
end
t12 = @async begin
  sleep(0.5)
  12
end
@test typeof(mapn(+, t11, t12)) === Task
@test fetch(mapn(+, t11, t12)) == 11+12

t2 = @syntax_flatmap begin
  a = @async begin sleep(0.5); 5 end
  b = @async begin sleep(a); a + 3 end
  @pure a, b
end
@test fetch(t2) == (5, 5+3)
