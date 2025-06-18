@testitem "optional" begin

    x = NotProvided()
    y = NotSimulated()
    z = 1.0
    a = "value"
    @test (@fallback x y z) === 1.0
    @test (@fallback x z a) === 1.0
    @test_throws ArgumentError @fallback x y

    @test fallback(z) === z
    @test fallback(x, y, z) === 1.0
    @test fallback(x, z, a) === 1.0
    @test_throws ArgumentError fallback(x, y)

    @test isnotset(x) === true
    @test isnotset(y) === true
    @test isnotset(z) === false

end

@testitem "isprovided tests" begin
    # Test with NotProvided type
    @test !isprovided(NotProvided())

    # Test with regular types
    @test isprovided(1)
    @test isprovided("test")
    @test isprovided(3.14)

    # Test with complex types
    @test isprovided(Complex(1, 2))
    @test isprovided([1, 2, 3])

    # Test with nothing and missing
    @test isprovided(nothing)
    @test isprovided(missing)
end

@testitem "issimulated tests" begin
    # Test with NotSimulated type
    @test !issimulated(NotSimulated())

    # Test with regular types
    @test issimulated(1)
    @test issimulated("test")
    @test issimulated(3.14)

    # Test with complex types
    @test issimulated(Complex(1, 2))
    @test issimulated([1, 2, 3])

    # Test with nothing and missing
    @test issimulated(nothing)
    @test issimulated(missing)
end

@testitem "unwrap_optional" begin
    using BasicTypes: BasicTypes, unwrap_optional, Optional

    @test unwrap_optional(Optional{Float32}) === Float32
    @test unwrap_optional(Any) === Any
    @test unwrap_optional(Float64) === Float64
    @test_throws ArgumentError unwrap_optional(Optional)
end
