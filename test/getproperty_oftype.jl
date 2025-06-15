@testitem "getproperty_oftype" begin
    @kwdef struct MyType
        a::Int
        b::Float64
        c::Optional{String} = NotProvided()
    end

    @test getproperty_oftype(MyType(1, 2.0, "test"), String) === "test"
    @test getproperty_oftype(MyType(1, 2.0, "test"), Int) === 1
    @test getproperty_oftype(MyType(1, 2.0, "test"), Float64) === 2.0
    @test getproperty_oftype(MyType(1, 2.0, "test"), ComplexF64, Returns(nothing), nothing) === nothing

    @test_throws ArgumentError getproperty_oftype(MyType(1, 2.0, "test"), NotSet)
    @test_throws ArgumentError getproperty_oftype(MyType(1, 2.0, "test"), NotSimulated)
    @test_throws ArgumentError getproperty_oftype(MyType(1, 2.0, "test"), NotProvided)
    @test_throws ArgumentError getproperty_oftype(MyType(1, 2.0, "test"), Nothing)

    @test_throws "OPS" getproperty_oftype((; a = 1), String; exception = ArgumentError("OPS"))

    @kwdef struct ASD
        a::Float64 = 1.0 # Matched with <: Real
        b = 2 # Matched with Any
        c::Real = 3.0 # Matched with === Real
    end

    @test getproperty_oftype(ASD(), ===, Any) === 2
    @test getproperty_oftype(ASD(), Real) === 1.0
    @test getproperty_oftype(ASD(), ===, Real) === 3.0
end