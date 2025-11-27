@testitem "telecom utils functions" begin
    @test lin2db(1.0) ≈ 0.0
    @test lin2db(10.0) ≈ 10.0

    @test db2lin(0.0) ≈ 1.0
    @test db2lin(10.0) ≈ 10.0

    @test f2λ(29.9792458e9) ≈ 0.01
    @test 0.1 |> λ2f |> f2λ ≈ 0.1
end