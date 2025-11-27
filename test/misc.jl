@testitem "bypass_bottom" begin
    using BasicTypes: BasicTypes, bypass_bottom

    @test bypass_bottom(Int, Float64) === Int
    @test bypass_bottom(Union{}, Float64) === Float64
    @test_throws ArgumentError bypass_bottom(Union{}, Union{})
end

@testitem "dblin and f2λ" begin
    @test lin2db(1.0) ≈ 0.0
    @test lin2db(10.0) ≈ 10.0

    @test db2lin(0.0) ≈ 1.0
    @test db2lin(10.0) ≈ 10.0

    @test f2λ(29.9792458e9) ≈ 0.01
    @test 0.1 |> λ2f |> f2λ ≈ 0.1
end