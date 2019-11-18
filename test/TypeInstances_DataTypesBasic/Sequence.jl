# Maybe Dict
# ==========

m = Dict(
  :a => Maybe(4),
  :b => Maybe(6))

@test sequence(m) == Maybe(Dict(:a => 4, :b => 6))

m2 = Dict(
  :a => Maybe(4),
  :b => Maybe(nothing))
@test sequence(m2) == Maybe(nothing)

# Either Dict
# ===========

e = Dict(
  :a => Either{String}(4),
  :b => Either{String}(6))

@test sequence(e) == Either{String}(Dict(:a => 4, :b => 6))

e2 = Dict(
  :a => Either{String}(4),
  :b => Either{String, Int}("hi"))
@test sequence(e2) == Either{Left}("hi")


e3 = Dict(
  :a => Either{String, Int}("a"),
  :b => Either{String, Int}("b"))

@test sequence(e3) == Either{Left}("a")


# Try Dict
# ==========

t = Dict(
  :a => @Try(4),
  :b => @Try(6))

@test sequence(t) == Try(Dict(:a => 4, :b => 6))

t2 = Dict(
  :a => Try(4),
  :b => @Try(error("hi")))
@test sequence(t2) == @Try(error("hi"))


t3 = Dict(
  :a => @Try(error("a")),
  :b => @Try(error("b")))

@test sequence(t3) == @Try(error("a"))
