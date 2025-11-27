@testitem "bypass_bottom" begin
    using BasicTypes: BasicTypes, bypass_bottom

    @test bypass_bottom(Int, Float64) === Int
    @test bypass_bottom(Union{}, Float64) === Float64
    @test_throws ArgumentError bypass_bottom(Union{}, Union{})
end
