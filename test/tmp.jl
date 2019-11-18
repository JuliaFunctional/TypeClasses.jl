using Traits

function g end
h(::Traitsof) = g
f(::Traitsof, g) = g

Traits.startswith_traitsof(f)

@macroexpand @traitsof_passthrough func(a) = f(h(g(a)))


function f(a, b)
  c = cont -> function i in 1:10
    cont(i)
  end
  Base.IteratorSize(::Type{typeof(c)}) = 
  Base.length(::typeof(c)) = 10
  Base.size(::typeof(c)) = (2, 5)
  Continuable(c; )
end

size