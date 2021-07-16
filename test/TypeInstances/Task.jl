using TypeClasses
using Test


wait_a_little(f::Function, seconds=0.3) = @async begin
  sleep(seconds)
  f()
end
wait_a_little(x, seconds=0.3) = wait_a_little(() -> x, seconds)


# Functor, Applicative, Monad
# ===========================

squared = map(wait_a_little(4)) do x
  x*x
end;  # returns a Task

@test fetch(squared) == 16

@test typeof(mapn(+, wait_a_little(11), wait_a_little(12))) === Task
@test fetch(mapn(+, wait_a_little(11), wait_a_little(12))) == 23

monadic = @syntax_flatmap begin
  a = wait_a_little(5)
  b = wait_a_little(a + 3)
  @pure a, b
end;  # returns a Task

@test fetch(monadic) == (5, 8)

@test fetch(pure(Task, 4)) == 4


# Monoid, Alternative
# ===================

@test fetch(wait_a_little("hello.") ⊕ wait_a_little("world.")) == "hello.world."
@test fetch(wait_a_little(:a, 1.0) ⊘ wait_a_little(:b, 2.0)) == :a
@test fetch(wait_a_little(:a, 3.0) ⊘ wait_a_little(:b, 2.0)) == :b

@test fetch(wait_a_little(() -> error("fails"), 0.1) ⊘ wait_a_little(:succeeds, 0.3)) == :succeeds

@test fetch(wait_a_little(:succeeds, 0.3) ⊘ wait_a_little(() -> error("fails"), 0.1)) == :succeeds


@test_throws TaskFailedException fetch(wait_a_little(() -> error("fails1")) ⊘ wait_a_little(() -> error("fails2")) ⊘ wait_a_little(() -> error("fails3")) ⊘ wait_a_little(() -> error("fails4")))
