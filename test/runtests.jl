using Test
using TypeClasses
using Traits
using IsDef
using DataTypesBasic
using Suppressor

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
  @testset "Callable" begin
    include("TypeInstances/Callable.jl")
  end
  @testset "State" begin
    include("TypeInstances/State.jl")
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
  @testset "Writer" begin
    include("TypeInstances/Writer.jl")
  end
  @testset "Task" begin
    include("TypeInstances/Task.jl")
  end
  @testset "Future" begin
    include("TypeInstances/Future.jl")
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
end
