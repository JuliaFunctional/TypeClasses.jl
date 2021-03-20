
# We support some convenient converts for interaction between Containers


# converting Writer to other Containers
# -------------------------------------
# we just forget the acc
# this is destructive, hence we throw a warning

function Base.convert(::Type{<:Identity}, x::Writer)
  @warn "Forgetting Writter.acc = $(x.acc) where Writer.value = $(x.value)."
  Identity(x.value)
end
function Base.convert(::Type{<:Vector}, x::Writer)
  @warn "Forgetting Writter.acc = $(x.acc) where Writer.value = $(x.value)."
  [x.value]
end
function Base.convert(::Type{<:ContextManager}, x::Writer)
  @warn "Forgetting Writter.acc = $(x.acc) where Writer.value = $(x.value)."
  @ContextManager cont -> cont(x.value)
end


# Converting other Containers to Writer
# -------------------------------------
# construct acc via neutral

function Base.convert(::Type{<:Writer{Acc}}, x::ContextManager) where Acc
  @assert(isNeutral(Acc), "Tried to convert ContextManager to Writer{Acc}, however `Acc = $Acc` is not Neutral, and hence we cannot come up with an initial element for the Writer aggregation.")
  Writer(neutral(Acc), x(identity))
end

function Base.convert(::Type{<:Writer{Acc}}, x::Identity) where Acc
  @assert(isNeutral(Acc), "Tried to convert Identity to Writer{Acc}, however `Acc = $Acc` is not Neutral, and hence we cannot come up with an initial element for the Writer aggregation.")
  Writer(neutral(Acc), x.value)
end

# we cannot support Vector, as there is no way to get several values in to the one Writer.value


# Iterables
# ---------

# conversion methods for convenience
function Base.convert(::Type{<:Vector}, iter::Iterable)
  @assert(Base.IteratorSize(iter) isa Union{Base.HasLength, Base.HasShape}, "Cannot convert possibly infinite Iterable to Vector")
  collect(iter)
end

# we don't need to convert anything to Iterable for interoperability, as Iterables use `iterate` for flatmap
# hence everything which defines `iterate` automatically works
