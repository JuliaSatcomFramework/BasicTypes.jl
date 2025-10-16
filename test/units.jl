@testitem "enforce_unit" begin
    using BasicTypes: Deg
    @test enforce_unit(1u"m", 10km) ≈ 10000u"m"
    @test enforce_unit(1u"m", 10) ≈ 10u"m"

    # We test the error for non concrete quantities
    @test_throws ArgumentError enforce_unit(Deg, 10km)
    @test_throws ArgumentError enforce_unit(Deg{AbstractFloat}, 10)
end

@testitem "raw values" begin
    using BasicTypes

    @test raw_angle(90°) ≈ π/2
    @test raw_angle(450°, RoundDown) ≈ π/2
    @test raw_distance(1km) ≈ 1000.0
    @test raw_time(1u"h") ≈ 3600.0
end