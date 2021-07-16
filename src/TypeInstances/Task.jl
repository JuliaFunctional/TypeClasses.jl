# Monoid instances
# ================

# this is standard Applicative combine implementation
# there is no other sensible definition for combine and hence if this does fail, it fails correctly
TypeClasses.combine(a::Task, b::Task) = mapn(combine, a, b)

"""
    orelse(task1, task2, ...)
    task1 ⊘ task2

Runs both in parallel and collects which ever result is first. Then interrupts all other tasks and returns the found result.
"""
TypeClasses.orelse(a::Task, b::Task, more::Task...) = @async begin
  n = length(more) + 2
  c = Channel(n)  # all tasks should in principle be able to send there result without waiting
  tasks = (a, b, more...)
  tasks′ = map(tasks) do task
    @async begin
      tried = @TryCatch TaskFailedException fetch(task)
      # we need to capture errors too, so that in case everything errors out, this is still ending
      put!(c, tried[])
    end    
  end
  
  exceptions = Vector{Exception}(undef, n)
  for i in 1:n
    result = take!(c)

    if isa(result, Thrown)  # all exceptions are Thrown{TaskFailedException}
      exceptions[i] = if isa(result.exception.task.exception, MultipleExceptions)
        # extract MultipleExceptions for better readability
        result.exception.task.exception
      else
        result
      end
      # we found an error, hence need to wait for another result
      continue
    end

    # no error, i.e. we found the one result we wanted to find
    close(c)  # we only need one result
    for t in (tasks′..., tasks...)
      # all tasks can be interrupted now that we have the first result
      @async Base.throwto(t, InterruptException())
    end
    return result  # break for loop
  end
  # only if all n tasks failed
  return throw(MultipleExceptions(exceptions...))
end


# FunctorApplicativeMonad
# =======================

function TypeClasses.foreach(f, x::Task)
  f(fetch(x))
  nothing
end

TypeClasses.map(f, x::Task) = @async f(fetch(x))
TypeClasses.pure(::Type{<:Task}, x) = @async x

# we use the default implementation of ap which follows from flatten
# TypeClasses.ap
TypeClasses.ap(f::Task, x::Task) = @async fetch(f)(fetch(x))
# we don't use convert for typesafety, as fetch is more flexible and also enables typechecks
# e.g. this works seamlessly to combine a Future into a Task
TypeClasses.flatmap(f, x::Task) = @async fetch(f(fetch(x)))



# FlipTypes
# =========

# does not make much sense as this would need to execute the Task, and map over its returned value,
# creating a bunch dummy Tasks within.
