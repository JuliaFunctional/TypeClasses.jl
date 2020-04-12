using TypeClasses
using Traits
using Test
using IsDef
using Suppressor
using DataTypesBasic
TypeClasses.@overwrite_Some
splitln(str) = split(strip(str), "\n")

load(x) = ContextManager(function (yield)
  println("preparation $x")
  result = yield(x)
  println("cleanup $x")
  result
end)



# Vector
# ======

@test flatten([Option(3), Option(nothing), Option(4)]) == [3, 4]
@test flatten([Try(4), (@Try error("hi")), Try(5)]) == [4, 5]
@test flatten([Either{String}(4), either("left", false, 3), Either{Int, String}("right")]) == [4, "right"]


# Multiple Combinations
# =====================

# starting with Maybe (nothing new)

h1 = @syntax_flatmap begin
 a, b = [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)]
 iftrue(a % 2 == 0) do
   a + b
 end
end
@test h1 == [5, 9]

# adding ContextManager

cmlog(x) = @ContextManager function(cont)
  println("before $x")
  r = cont(x*x)
  println("after $x")
  r
end

# unfortunately this does not work, as the typeinference does not work
# and hence an Array of Any is constructed instead of an Array of ContextManager


# the version without the Array component works like a charm

h2() = @syntax_flatmap begin
  (a, b) = [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)]
  c = iftrue(a % 2 == 0) do
    a + b
  end
  d = cmlog(c) # c*c
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
  d = cmlog(c)  # c*c
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
  d = cmlog(c) # c*c
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
  l = load(i)
  Writer(" $l yes", l+i)
end

@test @suppress(writer_cm()) == Writer("hi 4 yes", 4+4)
@test splitln(@capture_out writer_cm()) == [
  "preparation 4",
  "cleanup 4"
]
