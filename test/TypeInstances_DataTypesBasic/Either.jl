
# MonoidAlternative
# =================

# orelse
@test Either{String, Int}("hi") ⊛ Either{String, Int}(1) == Either{String, Int}(1)
@test Either{String, Int}("hi") ⊛ Either{String, Int}("ho") == Either{String, Int}("ho")

# combine
@test Either{Int, String}("hi") ⊕ Either{Int, String}("ho") == Either{Int, String}("hiho")
@test Either{String, Int}("hi") ⊕ Either{String, Int}("ho") == Either{String, Int}("hiho")


# FunctorApplicativeMonad
# =======================

@test change_eltype(Identity{String}, Bool) == Identity{Bool}
@test change_eltype(Either{Int, String}, Bool) == Either{Int, Bool}

@test map(Either{String}(3)) do x
  x * x
end == Either{String}(9)

@test map(Either{String, Int}("hi")) do x
  x * x
end == Either{String, Int}("hi")

@test mapn(Either{String, Int}(2), Either{String, Int}("ho")) do x, y
  x + y
end == Const{String}("ho")
# TODO we loose type information here, however it is tough to infer through the generic curry function constructed by mapn

@test mapn(Either{String, Int}("hi"), Either{String, Int}(3)) do x, y
  x + y
end == Const{String}("hi")

@test mapn(Either{String, Int}("hi"), Either{String, Int}("ho")) do x, y
  x + y
end == Const{String}("hi")


he = @syntax_flatmap begin
  a = Either{String, Int}(2)
  b = Either{String, Int}(4)
  @pure a + b
end
@test he == Either{String}(6)


h = @syntax_flatmap begin
  a = Either{String, Int}("hi")
  b = Either{String, Int}(4)
  @pure a + b
end
@test h == Either{String, Int}("hi")


h = @syntax_flatmap begin
  a = Either{String, Int}(2)
  b = Either{String, Int}("ho")
  @pure a + b
end
@test h == Either{String, Int}("ho")


@test pure(Either{String}, 3) == Identity(3)
@test pure(Either, 3) == Identity(3)


# FlipTypes
# =========

@test flip_types(Const([1,2,3])) == Const.([1,2,3])
@test flip_types(Identity([1,2,3])) == Identity.([1,2,3])
