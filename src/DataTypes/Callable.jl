"""
wrapper to clearly indicate that something should be treated as a Callable
"""
struct Callable{F}
  f::F
end

(callable::Callable)(args...; kwargs...) = callable.f(args...;kwargs...)
