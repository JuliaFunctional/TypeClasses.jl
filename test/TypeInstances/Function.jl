g = x -> x*2
f = x -> x*x
# just function composition
fg = fmap(g) do x2
  f(x2)
end
@test fg(3) == f(g(3))

fPLUSg = mapn(f, g) do x1, x2
  x1 + x2
end

@test fPLUSg(3) == f(3) + g(3)



fPRODg = @syntax_fflatmap begin
  x1 = f
  x2 = g
  @pure x1 * x2
end

@test fPRODg(3) == f(3) * g(3)

# TODO Sequence
