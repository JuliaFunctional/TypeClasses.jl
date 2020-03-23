using TypeClasses
using Traits
using Test
using IsDef
using DataTypesBasic
using Suppressor

DataTypesBasic.@overwrite_Base
TypeClasses.@overwrite_Base
splitln(str) = split(strip(str), "\n")

@testset "TypeClasses" begin
  @testset "MonoidAlternative" begin
    include("TypeClasses/MonoidAlternative.jl")
  end
  @testset "FunctorApplicativeMonad" begin
    include("TypeClasses/FunctorApplicativeMonad.jl")
  end
  @testset "FlipTypes" begin
    include("TypeClasses/FlipTypes.jl")
  end
end

@testset "TypeInstances" begin
  @testset "Dict" begin
    include("TypeInstances/Dict.jl")
  end
  @testset "FunctorDict" begin
    include("TypeInstances/FunctorDict.jl")
  end
  @testset "Function" begin
    include("TypeInstances/Callable.jl")
  end
  @testset "Pair" begin
    include("TypeInstances/Pair.jl")
  end
  @testset "Iterable" begin
    include("TypeInstances/Iterable.jl")
  end
  @testset "Tuple" begin
    include("TypeInstances/Tuple.jl")
  end
  @testset "Vector" begin
    include("TypeInstances/Vector.jl")
  end
end

@testset "TypeInstances_DataTypesBasic" begin
  @testset "Const" begin
    include("TypeInstances_DataTypesBasic/Const.jl")
  end
  @testset "Identity" begin
    include("TypeInstances_DataTypesBasic/Identity.jl")
  end
  @testset "Either" begin
    include("TypeInstances_DataTypesBasic/Either.jl")
  end
  @testset "Option" begin
    include("TypeInstances_DataTypesBasic/Option.jl")
  end
  @testset "Try" begin
    include("TypeInstances_DataTypesBasic/Try.jl")
  end
  @testset "ContextManager" begin
    include("TypeInstances_DataTypesBasic/ContextManager.jl")
  end

  # cross tests:
  @testset "Flatten" begin
    include("TypeInstances_DataTypesBasic/Flatten.jl")
  end
  @testset "FlipTypes" begin
    include("TypeInstances_DataTypesBasic/FlipTypes.jl")
  end
end
