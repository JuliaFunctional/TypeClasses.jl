# Vector
# ======

@test fflatten([Maybe(3), Maybe(nothing), Maybe(4)]) == [3, 4]
@test fflatten([Try(4), (@Try error("hi")), Try(5)]) == [4, 5]
@test fflatten([Either{String}(4), either("left", false, 3), Either{Int, String}("right")]) == [4, "right"]

# Dict
# ====
m = Dict(
  :a => Maybe(4),
  :b => Maybe(6),
  :c => Maybe(nothing))

@test fflatten(m) == Dict(:a => 4, :b => 6)


# Multiple Combinations
# =====================

# starting with Maybe (nothing new)

h = @syntax_fflatmap begin
 a, b = [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)]
 iftrue(a % 2 == 0) do
   a + b
 end
end
@test h == [5, 9]

# adding ContextManager

const logging = []
cmlog(x) = @ContextManager function(cont)
  push!(logging, "before $x")
  r = cont(x*x)
  push!(logging, "after $x")
  r
end

#= DEBUGGING
  const array_tuple = [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)]

  t = fmap(array_tuple) do (a, b)
    fmap(iftrue(a % 2 == 0) do
      a + b
    end) do c
      fmap(cmlog(c)) do d
        d
      end
    end
  end
  fflattenrec(t)


  t = fmap(array_tuple) do (a, b)
    fmap(iftrue(a % 2 == 0) do
      a + b
    end) do c
      fmap(cmlog(c)) do d
        d
      end
    end
  end

  @code_warntype fmap(((a, b),) -> begin
    fflatmap(c -> begin
      fmap(d -> begin
        d
      end, cmlog(c))
    end, iftrue(() -> a + b, a % 2 == 0))
  end, array_tuple)


  const func = ((a, b),) -> begin
    fflatmap(c -> begin
      fmap(d -> begin
        d
      end, cmlog(c))
    end, iftrue(() -> a + b, a % 2 == 0))
  end

  eltype(Base.Generator(func,array_tuple))
  Base.IteratorEltype(Base.Generator(func,array_tuple)))
  map(func, array_tuple)

  const func2 = ((a, b),) -> begin
    fmap(c -> begin
      fmap(d -> begin
        d
      end, cmlog(c))
    end, iftrue(() -> a + b, a % 2 == 0))
  end

  eltype(Base.Generator(func2,array_tuple))
  Base.IteratorEltype(Base.Generator(func2,array_tuple))
  Base.IteratorSize(Base.Generator(func2,array_tuple))
  map(func2, array_tuple)


  @code_warntype @syntax_fflatmap begin
    a = array_tuple2
    @pure b = a*a
    c = iftrue(a % 2 == 0) do
      a + b
    end
    d = cmlog(c)
    @pure d # (a, b, c, d)
  end
=#



# unfortunately this does not work, as the typeinference does not work
# and hence an Array of Any is constructed instead of an Array of ContextManager


# the version without the Array component works like a charm

empty!(logging)
h = @syntax_fflatmap begin
  a, b = [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)]
  c = iftrue(a % 2 == 0) do
    a + b
  end
  d = cmlog(c)
  @pure d # (a, b, c, d)
end
@test h == [25, 81]
@test logging == ["before 5", "after 5", "before 9", "after 9"]

empty!(logging)
h = @syntax_fmap_fflattenrec begin
  a, b = [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)]
  c = iftrue(a % 2 == 0) do
    a + b
  end
  d = cmlog(c)
  @pure d # (a, b, c, d)
end
@test h == [25, 81]
@test logging == ["before 5", "after 5", "before 9", "after 9"]


# Try
# ---

mytry(x) = x == 4 ? error("error") : x

@syntax_fflatmap begin
  (a, b) = [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)]
  c = iftrue(a % 2 == 0) do
    a + b
  end
  d = cmlog(c)
  e = @Try mytry(d / a)
end

empty!(logging)
h = @syntax_fflatmap begin
  @pure (a, b) = (2, 3)
  c = iftrue(a % 2 == 0) do
    a + b
  end
  d = cmlog(c)
  e = @Try mytry(d / a)
  @pure e + 1
end
@test h == Try(13.5)
@test logging == ["before 5", "after 5"]



# Either
# ------

empty!(logging)
h = @syntax_fflatmap begin
  @pure (a, b) = (2, 3)
  c = iftrue(a % 2 == 0) do
    a + b
  end
  d = cmlog(c)
  e = @Try mytry(d / a)
  f = either("left", e > 13, :right)
  @pure Symbol(f, ":)")
end
@test h == Either{String, Symbol}("left")
@test logging == ["before 5", "after 5"]
