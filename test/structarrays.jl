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
end