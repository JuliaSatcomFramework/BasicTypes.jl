using TestItemRunner

@testitem "Aqua" begin
    using Aqua
    Aqua.test_all(BasicTypes) 
    # Aqua.test_ambiguities(BasicTypes)
end

@testitem "EmptyIterator" begin
    @test_nowarn for i in NotSimulated()
        error("ASD")
    end

    @test collect(NotProvided()) == Union{}[]

    @test length(NotSimulated()) == 0
    @test eachindex(NotSimulated()) == Base.OneTo(0)
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