@testitem "enforce_unit" begin
    using BasicTypes
    @test enforce_unit(1u"m", 10km) ≈ 10000u"m"
    @test enforce_unit(1u"m", 10) ≈ 10u"m"
end

@testitem "raw values" begin
    using BasicTypes

    @test raw_angle(90°) ≈ π/2
    @test raw_angle(450°, RoundDown) ≈ π/2
    @test raw_distance(1km) ≈ 1000.0
    @test raw_time(1u"d") ≈ 24 * 3600.0
end