using TestItemRunner

@testitem "Aqua" begin
    using Aqua
    Aqua.test_all(BasicTypes) 
    # Aqua.test_ambiguities(BasicTypes)
end
@testitem "to_unit functions" begin
    using BasicTypes.Unitful: rad, ustrip, m
    # Test vector version of default units
    @test all(to_radians([π/4, .2, .4rad, 18°]) .≈ [π/4, .2, .4, π/10 ])
    @test_throws "You can only call" to_radians(1im)
    @test all(to_degrees(Any[10, (π/2)*rad, .1, 18°]) .≈ [10, 90, .1, 18]) # Any is needed because the Vector is automatically converted to Vector{Float} (in radians)
    @test_throws "You can only call" to_degrees(1im)
    @test all(to_meters(Any[1, 2m, 3km]) .≈ [1, 2, 3000])
    @test_throws "You can only call" to_meters([1, 2m, 3km]) # The vector without specifying Any is transformed in Unitful.Quantity (which is not a valid length)

    @test to_radians(1000°) ≈ deg2rad(-80)
    @test to_radians(6.5π) ≈ π/2
    @test to_radians(400°; rounding=RoundDown) ≈ deg2rad(40)
    @test to_radians(-400°; rounding=RoundToZero) ≈ deg2rad(-40)
    @test to_radians(6.5π; rounding=RoundDown) ≈ deg2rad(90)
    @test to_radians(-6.5π; rounding=RoundToZero) ≈ deg2rad(-90)
    
    @test to_degrees(1000) ≈ -80
    @test to_degrees(rad2deg(6.5π)) ≈ 90
    @test to_degrees(400; rounding=RoundDown) ≈ 40
    @test to_degrees(-400; rounding=RoundToZero) ≈ -40
    @test to_degrees(6.5π*rad; rounding=RoundDown) ≈ 90
    @test to_degrees(-6.5π*rad; rounding=RoundToZero) ≈ -90
end

@testitem "EmptyIterator" begin
    @test_nowarn for i in NotSimulated()
        error("ASD")
    end

    @test collect(NotProvided()) == Union{}[]

    @test length(NotSimulated()) == 0
    @test eachindex(NotSimulated()) == Base.OneTo(0)
end

@testitem "Check Angle" begin
    using BasicTypes: _check_angle_func, _check_angle
    @test _check_angle_func(deg2rad(23))(-23°)
    @test !_check_angle_func(deg2rad(23))(-23.1°)
    @test _check_angle_func(deg2rad(23))(deg2rad(-23))
    @test !_check_angle_func(deg2rad(23))(deg2rad(-23.1))
    @test _check_angle_func(23°)(-23°)
    @test !_check_angle_func(23°)(-23.1°)
    @test _check_angle_func(23°)(deg2rad(-23))
    @test !_check_angle_func(23°)(deg2rad(-23.1))

    @test_throws "in radians" _check_angle(6π)
end

@testitem "Terminal Logger" begin
    using BasicTypes.TerminalLoggers: TerminalLogger
    using BasicTypes.LoggingExtras: TeeLogger
    using BasicTypes: tee_logger
    term_logger = terminal_logger()
    @test term_logger isa TerminalLogger
    @test progress_logger() === Base.current_logger() # We are in non-interactive mode in tests
    @test tee_logger() isa TeeLogger
end

@run_package_tests verbose=true