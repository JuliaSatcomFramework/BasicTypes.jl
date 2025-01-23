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

    @test to_meters(10km) ≈ 10000m
end