using TypeClasses


# MonoidAlternative
# =================

function create_tuple_monoid_definitions(n)
  # unary and type arguments for `neutral`
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

    # we don't implement orelse, as it is commonly meant on container level, but there is no obvious failure semantics here
  end
end

macro create_tuple_monoid_definitions(n::Int)
  esc(Expr(:block, [create_tuple_monoid_definitions(i) for i ∈ 1:n]...))
end

@create_tuple_monoid_definitions 20  # 20 is an arbitrary number