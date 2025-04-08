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
