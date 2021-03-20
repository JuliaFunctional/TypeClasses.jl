using TypeClasses


# MonoidAlternative
# =================

function create_tuple_monoid_definitions(n)
  # unary and type arguments, for both `neutral` and `absorbing`
  unary_typevars = Symbol.(:A, 1:n)
  unary_args = [:(a::Type{Tuple{$(unary_typevars...)}})]
  unary_return(unary) = :(tuple($(unary.(unary_typevars)...)))

  # binary and value arguments, for both `combine` and `orelse`
  binary_typevars_1 = Symbol.(:A, 1:n)
  binary_typevars_2 = Symbol.(:B, 1:n)
  binary_args = [:(a::Tuple{$(binary_typevars_1...)}), :(b::Tuple{$(binary_typevars_2...)})]
  binary_return(binary) = :(tuple($(binary.([:(getfield(a, $i)) for i in 1:n], [:(getfield(b, $i)) for i in 1:n])...)))
  quote
    function TypeClasses.neutral($(unary_args...)) where {$(unary_typevars...)}
      $(unary_return(A -> :(neutral($A))))
    end
    function TypeClasses.combine($(binary_args...)) where {$(binary_typevars_1...), $(binary_typevars_2...)}
      $(binary_return((a, b) -> :($a ⊕ $b)))
    end
    function TypeClasses.absorbing($(unary_args...)) where {$(unary_typevars...)}
      $(unary_return(A -> :(absorbing($A))))
    end
    function TypeClasses.orelse($(binary_args...)) where {$(binary_typevars_1...), $(binary_typevars_2...)}
      $(binary_return((a, b) -> :($a ⊗ $b)))
    end
  end
end

for n in 1:20  # 20 is an arbitrary number
  eval(create_tuple_monoid_definitions(n))
end
