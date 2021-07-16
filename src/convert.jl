
# We support some convenient converts for interaction between Containers


# converting Writer to other Containers
# -------------------------------------
# we just forget the acc
# this is destructive, hence we throw a warning

function Base.convert(::Type{<:Identity}, x::Writer)
  @warn "Forgetting Writter.acc = $(x.acc) where Writer.value = $(x.value)."
  Identity(x.value)
end
function Base.convert(T::Type{<:AbstractArray}, x::Writer)
  @warn "Forgetting Writter.acc = $(x.acc) where Writer.value = $(x.value)."
  convert(Base.typename(T).wrapper, [x.value])
end
function Base.convert(::Type{<:ContextManager}, x::Writer)
  @warn "Forgetting Writter.acc = $(x.acc) where Writer.value = $(x.value)."
  @ContextManager cont -> cont(x.value)
end


# Converting other Containers to Writer
# -------------------------------------
# construct acc via neutral

function Base.convert(::Type{<:Writer{Acc}}, x::ContextManager) where Acc
  Writer(neutral(Acc), x(identity))
end

function Base.convert(::Type{<:Writer{Acc}}, x::Identity) where Acc
  Writer(neutral(Acc), x.value)
end


# AbstractArray
# -------------

# we cannot support Array/Vector, as there is no way to get several values in to the one Writer.value
# we also do not need to support conversion to Iterable because the flatmap of Iterable just expects the Base.iterate interface, which exists for Vector 

# Iterables
# ---------

# conversion methods for convenience
function Base.convert(T::Type{<:AbstractArray}, iter::Iterable)
  @assert(Base.IteratorSize(iter) isa Union{Base.HasLength, Base.HasShape}, "Cannot convert possibly infinite Iterable to Vector")
  convert(Base.typename(T).wrapper, collect(iter))
end

# we don't need to convert anything to Iterable for interoperability, as Iterables use `iterate` for flatmap
# hence everything which defines `iterate` automatically works
