using Traits
using TypeClasses
using Test

@traitsof_init(TypeClasses.traitsof)
TypeClasses.@traitsof_linkall

@testset "functiondefined" begin
  include("functiondefined.jl")
end

@testset "TypeClasses" begin
  @testset "Monoid" begin
    include("TypeClasses/Monoid.jl")
  end
  @testset "FunctorApplicativeMonad" begin
    include("TypeClasses/FunctorApplicativeMonad.jl")
  end
  @testset "Sequence" begin
    include("TypeClasses/Sequence.jl")
  end
end

@testset "TypeInstances" begin
  @testset "Dict" begin
    include("TypeInstances/Dict.jl")
  end
  @testset "Function" begin
    include("TypeInstances/Function.jl")
  end
  @testset "Pair" begin
    include("TypeInstances/Pair.jl")
  end
  @testset "Iterable" begin
    include("TypeInstances/Iterable.jl")
  end
  @testset "Vector" begin
    include("TypeInstances/Vector.jl")
  end
end
