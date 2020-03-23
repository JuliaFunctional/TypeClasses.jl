# MonoidAlternative
# =================

# combine Exceptions
@test neutral(Exception) == MultipleExceptions()
@test ErrorException("hi") ⊕ ErrorException("ho") == MultipleExceptions(ErrorException("hi"), ErrorException("ho"))

# orelse Try
@test Try(3) ⊛ Try(4) == Try(3)  # take the first non-ErrorException("error")
@test Try{Int}(ErrorException("error")) ⊛ Try(4) == Try(4)  # take the first non-ErrorException("error")
@test Try(ErrorException("error")) ⊛ Try(4) == Try(4)  # take the first non-ErrorException("error")
@test (@Try error("error")) ⊛ Try(4) == Try(4)  # take the first non-ErrorException("error")

# combine Try
@test Try("hi") ⊕ Try("ho") == Try("hiho")
@test Try{Int}(ErrorException("error")) ⊕ Try(4) == Try{Int}(ErrorException("error"))
@test Try{Int}(ErrorException("error")) ⊕ Try{Int}(ErrorException("exception")) == Try{Int}(MultipleExceptions(ErrorException("error"), ErrorException("exception")))


# FunctorApplicativeMonad
# =======================

@test eltype(Try{Int}) == Int
@test eltype(Success{Int}) == Int
@test eltype(Failure{Int}) == Int
@test change_eltype(Success{Int}, Bool) == Success{Bool}
@test change_eltype(Try{Int}, Bool) == Try{Bool}

@test map(Try(3)) do x
  x*x
end == Try(9)

@test map(Try(ErrorException("error"))) do x
  x*x
end == Try(ErrorException("error"))

@test mapn(Try(3), Try("hi")) do x, y
  "$x, $y"
end == Try("3, hi")

@test mapn(Try(3), Try(ErrorException("error"))) do x, y
  "$x, $y"
end == Try(ErrorException("error"))

h = @syntax_flatmap begin
  a = Try(3)
  b = Try("hi")
  @pure "$a, $b"
end
@test h == Try("3, hi")

h = @syntax_flatmap begin
  a = Try(3)
  b = Try(ErrorException("error"))
  @pure "$a, $b"
end
@test h == Try{String}(ErrorException("error"))

@test pure(Try, 4) == Try(4)


# FlipTypes
# =========

# TODO
