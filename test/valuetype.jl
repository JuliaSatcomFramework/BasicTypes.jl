@testitem "valuetype" begin
    using StaticArrays, Unitful
    using BasicTypes: valuetype, change_valuetype, common_valuetype, promote_valuetype

    # Tests for valuetype
    @test valuetype(1) == Int
    @test valuetype(Float64) == Float64
    @test valuetype(1.0) == Float64
    @test valuetype(Vector{Int}) == Int
    @test valuetype([1, 2, 3]) == Int
    @test valuetype(Array{Float64, 2}) == Float64
    @test valuetype(1.0u"m") == Float64
    @test_throws ErrorException valuetype("string")

    # Tests for change_valuetype
    @test change_valuetype(Float64, 1) == 1.0
    @test change_valuetype(Int, 1.0) == 1
    @test typeof(change_valuetype(Float64, 1)) == Float64
    @test typeof(change_valuetype(Int, 1.0)) == Int
    
    # Tests for SVector
    v = SVector{3, Int}(1, 2, 3)
    v_float = change_valuetype(Float64, v)
    @test typeof(v_float) <: SVector{3, Float64}
    @test v_float == SVector{3, Float64}(1.0, 2.0, 3.0)

    # Tests for common_valuetype
    @test common_valuetype(Real, Float64, 1, 2.0) == Float64
    @test common_valuetype(Integer, Int64, 1, 2) == Int64
    @test common_valuetype(Integer, Int64, 1, 2.0) == Int64  # Fallback to Int64
    @test common_valuetype(Real, Float64, [1, 2], [3.0, 4.0]) == Float64

    # Tests for promote_valuetype
    a, b = promote_valuetype(Real, Float64, 1, 2.0)
    @test typeof(a) == Float64 && typeof(b) == Float64
    @test a == 1.0 && b == 2.0
    
    a, b = promote_valuetype(Integer, Int64, 1, 2.0)
    @test typeof(a) == Int64 && typeof(b) == Int64
    @test a == 1 && b == 2
    
end