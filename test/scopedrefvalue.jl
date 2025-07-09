@testitem "ScopedRefValue" begin
    using Base.ScopedValues: ScopedValues, ScopedValue

    # Test constructors
    @test ScopedRefValue{Float64}() isa ScopedRefValue{Float64}
    @test ScopedRefValue{Float64}(3.0) isa ScopedRefValue{Float64}
    @test valuetype(ScopedRefValue(3.0)) === Float64

    # Test isassigned 
    @test !isassigned(ScopedRefValue{Function}())

    sv = ScopedRefValue{Float64}(3.0)

    ScopedValues.with(sv => 1.0) do
        @test sv[] === 1.0
    end
    BasicTypes.with(sv => 1.0) do
        @test sv[] === 1.0
    end

    sc = ScopedValue{Float64}(4.0)
    BasicTypes.with(sc => 1.0, sv => 2.0) do
        @test sc[] === 1.0
        @test sv[] === 2.0
    end
end