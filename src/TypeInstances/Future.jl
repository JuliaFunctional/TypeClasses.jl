import Distributed: Future, @spawnat, RemoteChannel, RemoteException

# Monoid instances
# ================

# this is standard Applicative combine implementation
# there is no other sensible definition for combine and hence if this does fail, it fails correctly
TypeClasses.combine(a::Future, b::Future) = mapn(combine, a, b)


"""
    orelse(future1, future2, ...)
    future1 ⊘ future2

Runs both in parallel and collects which ever result is first. Then interrupts all other futures and returns the found result.
"""
TypeClasses.orelse(a::Future, b::Future, more::Future...) = @spawnat :any begin
  n = length(more) + 2
  c = Channel(n)  # all tasks should in principle be able to send there result without waiting
  futures = (a, b, more...)
  futures′ = map(futures) do future
    @spawnat :any begin
    # fetch returns an RemoteException in case something failed, it does not throw an error
      put!(c, fetch(future))
    end    
  end
  
  exceptions = Vector{Exception}(undef, n)
  for i in 1:n
    result = take!(c)

    if isa(result, RemoteException)  # all exceptions are Thrown{TaskFailedException}
      exceptions[i] = if isa(result.captured.ex, MultipleExceptions)
        # extract MultipleExceptions for better readability
        result.captured.ex
      else
        result
      end
      # we found an error, hence need to wait for another result
      continue
    end

    # no error, i.e. we found the one result we wanted to find
    close(c)  # we only need one result
    for t in (futures′..., futures...)
      # all tasks can be interrupted now that we have the first result
      @spawnat :any Base.throwto(t, InterruptException())
    end
    return result  # break for loop
  end
  # only if all n tasks failed
  return throw(MultipleExceptions(exceptions...))
end


# FunctorApplicativeMonad
# =======================

function TypeClasses.foreach(f, x::Future)
  f(fetch(x))
  nothing
end

TypeClasses.map(f, x::Future) = @spawnat :any f(fetch(x))
TypeClasses.pure(::Type{<:Future}, x) = @spawnat :any x

# we use the default implementation of ap which follows from flatten
# TypeClasses.ap
TypeClasses.ap(f::Future, x::Future) = @spawnat :any fetch(f)(fetch(x))
# we don't use convert for typesafety, as fetch is more flexible and also enables typechecks
# e.g. this works seamlessly to combine a Task into a Future
TypeClasses.flatmap(f, x::Future) = @spawnat :any fetch(f(fetch(x)))



# FlipTypes
# =========

# does not make much sense as this would need to execute the Future, and map over its returned value,
# creating a bunch dummy Futures within.
