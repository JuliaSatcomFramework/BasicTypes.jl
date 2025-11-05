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

@testitem "not set values" begin
    using BasicTypes

    @test raw_angle(NotProvided()) == NotProvided()
    @test raw_distance(NotSimulated()) == NotSimulated()
    @test raw_duration(NotProvided()) == NotProvided()
    @test raw_mass(NotProvided()) == NotProvided()

    @test enforce_unit(1u"m", NotProvided()) == NotProvided()
    @test enforce_unit(1u"m", NotProvided(), u"m") == NotProvided()
    @test enforce_unitless(u"m", NotSimulated()) == NotSimulated()

    @test enforce_unit(u"m", nothing) === nothing
    @test enforce_unitless(u"m", nothing) === nothing
end

@testitem "Unitful compat" begin
    using BasicTypes
    using Unitful

    @test Unitful.unit(NotProvided()) == Unitful.NoUnits
    @test Unitful.dimension(NotProvided()) == Unitful.NoDims
    @test Unitful.ustrip(u"m", NotProvided()) == NotProvided()
    @test Unitful.uconvert(u"m", NotProvided()) == NotProvided()
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