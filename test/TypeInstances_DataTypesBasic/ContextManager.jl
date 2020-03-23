using Suppressor
using TypeClasses
using Test
using DataTypesBasic

state = Ref(0)
mycontext = @ContextManager cont -> begin
  state[] += 1
  returnvalue = cont(state[])
  returnvalue
end

three_times = mapn(mycontext, mycontext, mycontext) do x, y, z
  (x, y, z)
end

@test three_times(x -> x) == (1,2,3)
@test three_times(x -> x) == (4,5,6)
@test state[] == 6


cm(i=4, prefix="") = @ContextManager function(cont)
  println("$(prefix)before $i")
  r = cont(i)
  println("$(prefix)after $i")
  r
end

cm2 = flatten(map(x -> cm(x*x), cm(4)))
@test @suppress(cm2(x -> x)) == 16
@test splitln(@capture_out cm2(x -> x)) == [
  "before 4",
  "before 16",
  "after 16",
  "after 4"
]

nestedcm = @syntax_flatmap begin
  c1 = cm(1, "c1_")
  c2 = cm(c1 + 10, "c2_")
  @pure h = c1 + c2
  c3 = cm(h + 100, "c3_")
  @pure (c1, c2, c3)
end
@test @suppress(nestedcm(x -> x)) == (1, 11, 112)
@test splitln(@capture_out nestedcm(x -> x)) == [
  "c1_before 1",
  "c2_before 11",
  "c3_before 112",
  "c3_after 112",
  "c2_after 11",
  "c1_after 1"
]


@test pure(ContextManager, 3)(x -> x) == 3



# combining ContextManager with other monads
# ------------------------------------------

# ContextManager as main Monad

cm2 = @syntax_flatmap begin
  i = cm(4)
  v = [i, i+1, i+3]
  @pure v + 2
end
@test @suppress(cm2(x -> x).value) == [6,7,9]
@test splitln(@capture_out cm2(x -> x)) == ["before 4", "after 4"]


# ContextManager as sub monad

vector() = @syntax_flatmap begin
  i = [1,2,3]
  c = cm(i)
  @pure c + 2
end
@test @suppress(vector()) == [3, 4, 5]
@test splitln(@capture_out vector()) == [
  "before 1", "after 1", "before 2", "after 2", "before 3", "after 3"]


# contextmanager at several places

multiplecm() = @syntax_flatmap begin
  i = [1,2,3]
  c = cm(i, "i ")
  j = [c, c*c]
  c2 = cm(j, "j ")
  @pure c + c2
end

@test @suppress(multiplecm()) == [2, 2, 4, 6, 6, 12]
@test splitln(@capture_out multiplecm()) == ["i before 1",
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
