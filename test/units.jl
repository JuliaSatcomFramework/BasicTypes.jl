@testitem "to_unit functions" begin
    using BasicTypes.Unitful: rad, m
    # Test vector version of default units
    @test to_radians(1000°) ≈ 1000°
    @test 6.5π * rad |> ustrip ∘ to_radians(RoundNearest) ≈ π/2
    @test to_radians(400, RoundDown) ≈ 40°
    @test to_radians(RoundToZero)(-400°) ≈ -40°
    @test to_radians(6.5π * rad, RoundDown) ≈ 90°
    @test to_radians(-6.5π * rad, RoundToZero) ≈ -90°
    
    @test to_degrees(1000, RoundNearest) ≈ -80°
    @test to_degrees(rad2deg(6.5π)) ≈ 360° * 3 + 90°
    @test to_degrees(400, RoundDown) ≈ 40°
    @test to_degrees(-400, RoundToZero) ≈ -40°
    @test to_degrees(RoundDown)(6.5π * rad) ≈ 90°
    @test to_degrees(-6.5π * rad, RoundToZero) ≈ -90°

    @test to_meters(10km) ≈ 10000m ≈ to_meters(1e4)
end

@testitem "asdeg and stripdeg" begin
    using BasicTypes: asdeg, stripdeg

    @test asdeg(π) ≈ 180.0°
    @test stripdeg(180.0°) ≈ π
end

@testitem "to_meters/to_length deprecation" begin
    using BasicTypes: to_meters, to_length

    @test_logs (:warn, r"deprecated") to_meters(10km)
    @test_logs (:warn, r"deprecated") to_length(u"m", 10km)
    @test_logs (:warn, r"deprecated") match_mode=:any to_length(u"m")(10km)
end

@testitem "enforce_unit" begin
    using BasicTypes: Deg
    @test enforce_unit(1u"m", 10km) ≈ 10000u"m"
    @test enforce_unit(1u"m", 10) ≈ 10u"m"

    # We test the error for non concrete quantities
    @test_throws ArgumentError enforce_unit(Deg, 10km)
    @test_throws ArgumentError enforce_unit(Deg{AbstractFloat}, 10)
end