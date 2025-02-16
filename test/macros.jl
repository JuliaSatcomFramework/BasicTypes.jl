@testitem "macros" begin
    @test !isdefined(@__MODULE__, :DEFAULT_KWARGS)

    @define_kwargs_defaults begin
        boresight = NotProvided()
        check_blocking = false
    end

    @test isdefined(@__MODULE__, :DEFAULT_KWARGS)

    @add_kwargs_defaults f(::T; boresight, check_blocking::Bool) where T = return boresight, check_blocking

    boresight, check_blocking = f(3)
    @test boresight == NotProvided()
    @test check_blocking == false

    @test !isdefined(@__MODULE__, :ALTERNATIVE_KWARGS)

    @define_kwargs_defaults ALTERNATIVE_KWARGS begin
        boresight = 3
        check_blocking = true
    end

    @test isdefined(@__MODULE__, :ALTERNATIVE_KWARGS)

    @add_kwargs_defaults ALTERNATIVE_KWARGS g(; boresight, check_blocking) = return boresight, check_blocking

    boresight, check_blocking = g()
    @test boresight == 3
    @test check_blocking == true

    # We need macroexpand here as the @info message is sent before @test_logs actually tests
    @test_logs (:warn, r"The provided function definition was not modified by the `@add_kwargs_defaults` macro") @macroexpand @add_kwargs_defaults h(; boresight = 1, check_blocking = 2) = return boresight, check_blocking

    @test_throws "was not found" @add_kwargs_defaults WRONG_NAME l(; boresight = 1, check_blocking = 2) = return boresight, check_blocking
end