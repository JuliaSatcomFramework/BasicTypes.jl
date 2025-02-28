using TestItemRunner

@testitem "Aqua" begin
    using Aqua
    Aqua.test_all(BasicTypes) 
    # Aqua.test_ambiguities(BasicTypes)
end

@testitem "EmptyIterator" begin
    for T in (NotSimulated, NotProvided)
        @test_nowarn for i in T()
            error("ASD")
        end
        @test collect(T()) == Union{}[]
        @test length(T()) == 0
        @test eachindex(T()) == Base.OneTo(0)
    end

    using BasicTypes: SkipChecks
    SkipChecks()
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

@testitem "Basetype" begin
    using BasicTypes: basetype
    @test basetype(rand(Complex{Float64})) === Complex
    @test basetype(Complex) === Complex
    @test basetype(Union{Int, Float64}) === Union
    @test basetype(rand()) === Float64
end

@testitem "Optional" begin
    @test convert(Optional{Float64}, 1) === 1.0
    @test convert(Optional{Float64}, 30°) == deg2rad(30)
    @test convert(Optional{Float64}, NotProvided()) isa NotProvided
    @test convert(Optional{Float64}, NotSimulated()) isa NotSimulated
end

@run_package_tests verbose=true