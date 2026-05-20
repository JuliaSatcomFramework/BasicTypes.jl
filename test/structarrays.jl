@testitem "sa_type" begin
    using StructArrays
    using BasicTypes
    using Test

    @testset "Tuple input type" begin
        DT = Tuple{Int,Complex{Int}}
        sa_unwrapped = StructArray((1, Complex(i, j)) for i = 1:3, j = 2:4; unwrap=T -> !(T <: Real))
        sa_wrapped = StructArray((1, Complex(i, j)) for i = 1:3, j = 2:4)

        @test typeof(sa_unwrapped) == sa_type(DT, 2; unwrap=T -> !(T <: Real))
        @test typeof(sa_wrapped) == sa_type(DT, 2)
    end

    @test_throws ArgumentError sa_type(Complex, 2)

    @kwdef struct InnerField
        a::Float64 = rand()
        b::Complex{Float64} = rand(ComplexF64)
    end

    @kwdef struct CompositeStruct
        inner::InnerField = InnerField()
        int::Int = rand(1:10)
    end

    struct SAField{N}
        sa::sa_type(CompositeStruct, N)
    end

    struct SAFieldUW{N}
        sa::sa_type(CompositeStruct, N; unwrap=T -> (T <: InnerField))
    end
    @testset "Custom Composite type" begin
        sa_unwrapped = StructArray([CompositeStruct() for i in 1:3, j in 1:2]; unwrap = T -> (T<:InnerField))

        sa_wrapped = StructArray([CompositeStruct() for i in 1:3, j in 1:2])

        @test SAFieldUW(sa_unwrapped) isa SAFieldUW{2}
        @test SAField(sa_wrapped) isa SAField{2}
    end

    @kwdef struct InnerInner
        a::Float64 = 0
    end
    @kwdef struct Inner
        inner::InnerInner = InnerInner()
    end

    @kwdef struct Outer
        inner::Inner = Inner()
    end

    @kwdef struct OuterUW
        el::Outer = Outer()
    end

    outv = [OuterUW() for _ in 1:10]
    unwrap = T -> !(T <: Union{Real, Inner})
    sa = StructArray(outv; unwrap)
    @test typeof(sa) == sa_type(OuterUW, 1; unwrap)

    # Verify that sa_type still predicts the correct StructArray type
    # when a nested field contains a Union-typed value.
    @testset "Nested struct with Union field" begin
        @kwdef struct LeafA
            x::Float64 = rand()
        end
        @kwdef struct LeafB
            y::Int = rand(1:10)
        end
        @kwdef struct NestedUnionField
            val::Union{LeafA,LeafB} = rand() > 0.5 ? LeafA() : LeafB()
            count::Int = 0
        end
        @kwdef struct OuterNestedUnion
            inner::NestedUnionField = NestedUnionField()
            flag::Bool = false
        end

        # Unwrap both outer types, but leave Union{LeafA,LeafB} as a plain Array
        unwrap = T -> T <: Union{OuterNestedUnion,NestedUnionField}
        data = [OuterNestedUnion() for _ in 1:15]
        sa = StructArray(data; unwrap)

        # The Union field must be stored as a plain vector with Union eltype
        @test eltype(sa.inner.val) == Union{LeafA,LeafB}
        # sa_type must predict exactly the same type as what the constructor produced
        @test typeof(sa) == sa_type(OuterNestedUnion, 1; unwrap)
    end

    # This is a test that a custom struct with a custom staticschema is also properly handled by sa_type
    @testset "Custom staticschema (non-standard layout)" begin
        # Mirror the MyType example from the StructArrays advanced docs:
        # https://juliaarrays.github.io/StructArrays.jl/stable/advanced/#Structures-with-non-standard-data-layout
        struct MyType{T,NT<:NamedTuple}
            data::T
            rest::NT
        end
        MyType(x; kwargs...) = MyType(x, values(kwargs))

        # Flatten `data` and all keyword fields of `rest` into a single schema
        function StructArrays.staticschema(::Type{MyType{T,NamedTuple{names,types}}}) where {T,names,types}
            return NamedTuple{(:data, names...),Base.tuple_type_cons(T, types)}
        end
        function StructArrays.component(m::MyType, key::Symbol)
            return key === :data ? getfield(m, 1) : getfield(getfield(m, 2), key)
        end
        function StructArrays.createinstance(::Type{MyType{T,NT}}, x, args...) where {T,NT}
            return MyType(x, NT(args))
        end

        ET = MyType{Float64,@NamedTuple{a::Int64,b::Int64}}
        s = [MyType(i / 5, a=6 - i, b=2) for i in 1:5]
        sa = StructArray(s)

        @test typeof(sa) == sa_type(ET, 1)
        # Spot-check that the flattened fields are directly accessible
        @test sa.data == [i / 5 for i in 1:5]
        @test sa.a == [5, 4, 3, 2, 1]
        @test sa.b == fill(2, 5)
    end
end