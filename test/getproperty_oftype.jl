@testsnippet setup_oftype begin
    using BasicTypes
    using BasicTypes: fieldname_oftype, field_oftype, NotFound
    using InteractiveUtils
    using TestAllocations
    using Test
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

    struct FieldGetter{S} end
    FieldGetter(s::Symbol) = FieldGetter{s}()
    function (::FieldGetter{S})(obj) where S 
        return hasfield(typeof(obj), S) ? Base.getfield(obj, S) : NotFound()
    end
    # This basically checks that the output of @code_typed with field_oftype is equivalent to just accessing the field
    function test_noruntime(obj, fname::Symbol, comparison; check_values = true)
        ci1, _ = @code_typed field_oftype(obj, comparison)
        ci2, _ = @code_typed FieldGetter(fname)(obj)
        @test ci1.code == ci2.code
        # We test that the function does not allocate
        @test @nallocs(field_oftype(obj, comparison)) == 0
        @test @nallocs(field_oftype(typeof(obj), comparison)) == 0
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
    @test @nallocs(getproperty_oftype(long, String)) == 0
    @test @nallocs(getproperty_oftype(long, T -> T == Real)) == 0

    @test getproperty_oftype(long, NTuple{3}, Returns(3.0)) === 3.0
    @test @nallocs(getproperty_oftype(long, NTuple{3}, Returns(3.0))) == 0
end