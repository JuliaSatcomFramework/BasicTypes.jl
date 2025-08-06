@testsnippet setup_oftype begin
    using BasicTypes
    using BasicTypes: fieldname_oftype, field_oftype, NotFound
    using InteractiveUtils
    using TestAllocations
    using Test

    ##### Functions copied from MacroTools.jl ####
    walk(x, inner, outer) = outer(x)
    walk(x::Expr, inner, outer) = outer(Expr(x.head, map(inner, x.args)...))
    prewalk(f, x)  = walk(f(x), x -> prewalk(f, x), identity)
    ##### End of MacroTools.jl functions ####

    function codeinfo(func, args...)
        ci, _ = @code_typed func(args...)
        # When doing test with coverage, the code typed output is littered with Expr(:code_coverage_effect). So we remove those. We also skip comparing the last return statement as the actual slot number being returned will be different depending on the line of coverage considered
        is_coverage_expr(x) = x == Expr(:code_coverage_effect)
        isvalid(x) = !is_coverage_expr(x) && !(x isa Core.ReturnNode) && !(x isa Nothing)
        # Remove invalid expressions
        filter!(isvalid, ci.code)
        # We now go do some processing of the expression to normalize it
        for i in eachindex(ci.code)
            ci.code[i] = prewalk(ci.code[i]) do ex
                if ex isa GlobalRef
                    return ex.mod === BasicTypes ? ex.name : ex
                elseif ex isa Core.Argument
                    return ci.slotnames[ex.n]
                else
                    return ex
                end
            end
        end
        return ci.code
    end
end

@testitem "getproperty_oftype" begin
    @kwdef struct MyType
        a::Int
        b::Float64
        c::Optional{String} = NotProvided()
    end

    @test getproperty_oftype(MyType(1, 2.0, "test"), String) === "test"
    @test getproperty_oftype(MyType(1, 2.0, "test"), Int) === 1
    @test getproperty_oftype(MyType(1, 2.0, "test"), Float64) === 2.0
    @test getproperty_oftype(MyType(1, 2.0, "test"), ComplexF64, Returns(nothing), nothing) === nothing

    @test_throws ArgumentError getproperty_oftype(MyType(1, 2.0, "test"), NotSet)
    @test_throws ArgumentError getproperty_oftype(MyType(1, 2.0, "test"), NotSimulated)
    @test_throws ArgumentError getproperty_oftype(MyType(1, 2.0, "test"), NotProvided)
    @test_throws ArgumentError getproperty_oftype(MyType(1, 2.0, "test"), Nothing)

    @test_throws "OPS" getproperty_oftype((; a = 1), String; exception = ArgumentError("OPS"))

    @kwdef struct ASD
        a::Float64 = 1.0 # Matched with <: Real
        b = 2 # Matched with Any
        c::Real = 3.0 # Matched with === Real
    end

    @test getproperty_oftype(ASD(), T -> T === Any) === 2
    @test getproperty_oftype(ASD(), Real) === 1.0
    @test getproperty_oftype(ASD(), T -> T === Real) === 3.0

    # Test passing the default as a no-arg function as a function
    @test_throws "Magic" getproperty_oftype(ASD(), ExtraOutput, Returns(nothing), () -> ArgumentError("Magic"))
end

@testitem "Runtime Cost" setup = [setup_oftype] begin
    struct LOL
        a::Int
        b::String
    end
    # We define a complicated Structure with many fields
    @kwdef struct LONG
        a1::Int = 0
        a2::Float32 = 0f0
        a3::Float64 = 0.0
        a4::Complex{Float32} = 0.0im
        a5::Complex{Int} = 0im
        a6::Int32 = 2
        a7::LOL = LOL(1,"lol")
        a8::ExtraOutput = ExtraOutput()
        a9::String = "MAH"
        optional::Optional{NTuple{2, Float64}} = (2.0, 3.0)
        abstract::Real = 5.0
    end

    long = LONG()

    # This basically checks that the output of @code_typed with field_oftype is equivalent to just accessing the field
    function test_noruntime(obj, fname::Symbol, comparison; check_values = true, check_allocs = VERSION > v"1.11.99")
        cinfo = codeinfo(field_oftype, obj, comparison)
        if length(cinfo) > 0 # If we don't have any output is because we had a fully constant folded code just returning an value/expression.
            # Here we check 
            ex = :(getfield(obj, $(QuoteNode(fname))))
            @test only(cinfo) == ex
        end
        # We test that the function does not allocate
        if check_allocs
            # We don't check on 1.11 as the @nallocs can't properly do constant propagation/folding
            @test @nallocs(field_oftype(obj, comparison)) == 0
            @test @nallocs(field_oftype(typeof(obj), comparison)) == 0
        end
        if check_values
            # We also test that the code is actually also giving the correct output
            @test field_oftype(obj, comparison) === getfield(long, fname)
            @test field_oftype(typeof(obj), comparison) === fieldtype(typeof(obj), fname)
        end
    end
# This we just use to have a consistent output of `@code_typed`
    for i in 1:9
        fname = fieldname(LONG, i)
        ftype = fieldtype(LONG, i)
        test_noruntime(long, fname, ftype)
    end
    # We test that by default with Real we simply get the first field subtyping Real
    test_noruntime(long, :a1, Real)
    # We can use a custom function to explicitly target equality
    test_noruntime(long, :abstract, T -> T == Real)

    # We test that optional is Unwrapped
    test_noruntime(long, :optional, NTuple)

    # We finally test the output being NotFound if the type can't be found
    test_noruntime(long, :nofield, NTuple{3}; check_values = false)
    @test field_oftype(long, NTuple{3}) === NotFound()
    @test field_oftype(LONG, NTuple{3}) === NotFound()

    # We now test directly getproperty_oftype
    @test @nallocs(getproperty_oftype(long, $String)) == 0
    @test @nallocs(getproperty_oftype(long, T -> T == Real)) == 0

    @test getproperty_oftype(long, NTuple{3}, Returns(3.0)) === 3.0
    @test @nallocs(getproperty_oftype(long, $(NTuple{3}), Returns(3.0))) == 0
end