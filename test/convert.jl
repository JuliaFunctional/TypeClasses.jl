# Check the interactions of different Containers via `convert`

using TypeClasses
using Test
using Suppressor
using DataTypesBasic
splitln(str) = split(strip(str), "\n")

load_square(x, prefix="") = @ContextManager function (cont)
  println("$(prefix)before $x")
  result = cont(x*x)
  println("$(prefix)after $x")
  result
end



# Multiple Combinations
# =====================

# unfortunately this does not work, as the typeinference does not work
# and hence an Array of Any is constructed instead of an Array of ContextManager


# the version without the Array component works like a charm

h2() = @syntax_flatmap begin
  (a, b) = [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)]
  c = iftrue(a % 2 == 0) do
    a + b
  end
  d = load_square(c) # c*c
  @pure d
end

@test @suppress(h2()) == [25, 81]
@test splitln(@capture_out h2()) == ["before 5", "after 5", "before 9", "after 9"]


# Try
# ---

mytry(x) = x == 4 ? error("error") : x

h3() = @syntax_flatmap begin
  (a, b) = [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)]
  c = iftrue(a % 2 == 0) do
    a + b
  end
  d = load_square(c)  # c*c
  e = @Try mytry(d / a)
  @pure e + 1
end
@test @suppress(h3()) == [(2+3)^2/2 + 1, (4+5)^2/4 + 1]  # TODO not working because of bad type-inference
@test splitln(@capture_out h3()) == [
  "before 5",
  "after 5",
  "before 9",
  "after 9",
]


# Either
# ------

h4() = @syntax_flatmap begin
  (a, b) = [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)]
  c = iftrue(a % 2 == 0) do
    a + b
  end
  d = load_square(c) # c*c
  f = either("left", d > 4, :right)
  e = @Try "$a, $b, $c, $d, $f"
end
@test @suppress(h4()) == ["2, 3, 5, 25, right", "4, 5, 9, 81, right"]
@test splitln(@capture_out h4()) == [
  "before 5",
  "after 5",
  "before 9",
  "after 9",
]



# Writer + ContextManager
# ---------------------

writer_cm() = @syntax_flatmap begin
  i = Writer("hi", 4)
  l = load_square(i)
  Writer(" $l yes", l+i)
end

# importantly, writer does not work smoothly with other Contexts, but only by forgetting its accumulator
@test @suppress(writer_cm()) != Writer("hi 4 yes", 4*4+4)
@test @suppress(writer_cm()) == Writer("hi", 4*4+4)
@test splitln(@capture_out writer_cm()) == [
  "before 4",
  "after 4"
]


# combining ContextManager with other monads
# ------------------------------------------

# ContextManager as main Monad

cm2 = @syntax_flatmap begin
  i = load_square(4)
  v = [i, i+1, i+3]
  @pure v + 2
end
@test_throws MethodError @suppress(cm2(x -> x).value) == [6,7,9]
@test_throws MethodError splitln(@capture_out cm2(x -> x)) == ["before 4", "after 4"]


# ContextManager as sub monad

vector2() = @syntax_flatmap begin
  i = [1,2,3]
  c = load_square(i)
  @pure c + 2
end
@test @suppress(vector2()) == [1*1+2, 2*2+2, 3*3+2]
@test splitln(@capture_out vector2()) == [
  "before 1", "after 1", "before 2", "after 2", "before 3", "after 3"]


# alternating contextmanager and vector does not work, as there is no way to convert a vector to a contextmanager

multiplecm() = @syntax_flatmap begin
  i = [1,2,3]
  c = load_square(i, "i ")
  j = [c, c*c]
  c2 = load_square(j, "j ")
  @pure c + c2
end

@test_throws MethodError @suppress(multiplecm()) == [2, 2, 4, 6, 6, 12]
@test_throws MethodError splitln(@capture_out multiplecm()) == ["i before 1",
  "j before 1",
  "j after 1",
  "j before 1",
  "j after 1",
  "i after 1",
  "i before 2",
  "j before 2",
  "j after 2",
  "j before 4",
  "j after 4",
  "i after 2",
  "i before 3",
  "j before 3",
  "j after 3",
  "j before 9",
  "j after 9",
  "i after 3"]
