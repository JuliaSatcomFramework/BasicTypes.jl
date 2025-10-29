@testitem "enforce_unit" begin
    using BasicTypes
    @test enforce_unit(1u"m", 10km) ≈ 10000u"m"
    @test enforce_unit(1u"m", 10) ≈ 10u"m"
    @test enforce_unitless(u"km", 100, u"cm") ≈ 0.001
end

@testitem "raw values" begin
    using BasicTypes

    @test raw_angle(90°) ≈ π/2
    @test raw_angle(450°, RoundDown) ≈ π/2
    @test raw_distance(1km) ≈ 1000.0
    @test raw_time(1u"d") ≈ 24 * 3600.0
end

@testitem "angle_limit" begin
    using BasicTypes

    @test assert_angle_limit(90°) == nothing
    @test_throws AssertionError assert_angle_limit(450°)
    @test_throws AssertionError assert_angle_limit(5pi)
    @test assert_angle_limit(2pi, limit=2pi) == nothing
    @test assert_angle_limit(-2pi, limit=2pi) == nothing
    @test assert_angle_limit(-2pi, limit_min=-2pi) == nothing
    @test_throws AssertionError assert_angle_limit(-3pi, limit_max=2pi)
end