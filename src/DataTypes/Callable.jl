import FunctionWrappers: FunctionWrapper
"""
wrapper to clearly indicate that something should be treated as a Callable
"""
struct Callable{F}
  f::F
end

(callable::Callable)(args...; kwargs...) = callable.f(args...;kwargs...)

# there is no general definition for eltype, as this depends on the argument parameters
# but for FunctionWrapper it is possible
Base.eltype(T::Type{Callable{FunctionWrapper{Return, Args}}}) where {Return, Args} = Return

# there is no definition for Base.foreach, as a callable is not runnable without knowing the arguments
Base.map(f, g::Callable) = Callable((args...; kwargs...) -> f(g(args...; kwargs...)))
