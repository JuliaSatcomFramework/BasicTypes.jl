"""
    constructor_without_checks(T, args...)
Custom types `T` with inner constructors that do checks on inputs may want to
implement a method for this function where `T` is the specific type and
`args...` are just the fields of `T`.

This method must be defined inside the struct definition and should simply
return `new(args...)`, as a way to create an instance of the type without
running the potentially expensive checks.

This is especially useful for internal methods that might already know that the
inputs are valid and within bounds, so they can skip the checks.

# Example
```julia
struct MyType{T}
    x::T
    y::T
    #= 
    This is an unsafe constructor that skips all the input checks, we have this as our only inner constructor. 
    The `CoordinateSystemsBase` is important (even if explicitly imported in the
    parent module), or a local function with the same name will be created in
    the local scope of the struct definition body.
    =#
    BasicTypes.constructor_without_checks(::Type{MyType{T}}, x::T, y::T) where T = new{T}(x, y)
end
# We define the constructor with checks as an outer one, but we could have also done this inside the struct definition
function MyType{T}(x::T, y::T)
    # do some input checks...
    validated_x = check_x(x)
    validated_y = check_y(y)
    # Return the potentially modified inputs, if we had this as inner constructor this last line would be `new{T}(validated_x, validated_y)`
    BasicTypes.constructor_without_checks(MyType{T}, validated_x, validated_y)
end
```
"""
function constructor_without_checks end

"""
    to_radians(x::ValidAngle)
    to_radians(x::ValidAngle, rounding::RoundingMode)

Take one scalar value representing an angle and convert it to floating point Unitful quantities with radian (`rad`) units.

!!! note
    The input angles provided as unitless numbers are treated as degrees.

The 2-arg method can be used to also wrap (using `rem`) the angle provided as first argument using the rounding mode specified as second argument.

The last method taking a single `RoundingMode` argument is equivalent to `Base.Fix2(to_radians, rounding)`.

See also: [`to_degrees`](@ref), [`to_length`](@ref), [`to_meters`](@ref)
"""
to_radians(x::Real) = deg2rad(x) * rad
to_radians(x::UnitfulAngleQuantity) = uconvert(rad, float(x))

"""
    to_degrees(x::ValidAngle)
    to_degrees(x::ValidAngle, rounding::RoundingMode)
    to_degrees(rounding::RoundingMode)

Take one scalar valid angle and convert it to floating point Unitful quantities with degree (`°`) units.

!!! note
    The input angles provided as unitless numbers are treated as degrees.

The 2-arg method can be used to also wrap (using `rem`) the angle provided as first argument using the rounding mode specified as second argument.

The last method taking a single `RoundingMode` argument is equivalent to `Base.Fix2(to_degrees, rounding)`.

See also: [`to_radians`](@ref), [`to_length`](@ref), [`to_meters`](@ref)
"""
to_degrees(x::Real) = float(x) * °
to_degrees(x::UnitfulAngleQuantity) = uconvert(°, float(x))

# Do the common methods
for fname in (:to_radians, :to_degrees)
    # Function that does the rounding
    eval(:($fname(x::ValidAngle, rounding::RoundingMode) = rem($fname(x), $fname(360°), rounding)))
    # Function that takes the rounding-mode and returns a function that applies the specified rounding
    eval(:($fname(rounding::RoundingMode) = Base.Fix2($fname, rounding)))
end

## Lengths

"""
    to_length(unit::LengthUnit, x::ValidDistance)
    to_length(unit::LengthUnit)

Take one scalar value representing a length and convert it to floating point Unitful quantities with the specified `LengthUnit` `unit`.

The single-argument method taking a single `LengthUnit` argument is equivalent to `Base.Fix1(to_length, unit)`.

See also: [`to_meters`](@ref), [`to_radians`](@ref), [`to_degrees`](@ref)
"""
to_length(unit::LengthUnit, x::Len) = uconvert(unit, float(x))
to_length(unit::LengthUnit, x::Real) = to_length(unit, float(x) * u"m")
to_length(unit::LengthUnit) = Base.Fix1(to_length, unit)

"""
    to_meters(x::ValidDistance)

Take one scalar value representing a length and convert it to floating point Unitful quantities with the `m` unit.

See also: [`to_length`](@ref), [`to_radians`](@ref), [`to_degrees`](@ref)
"""
to_meters(x::ValidDistance) = to_length(u"m")(x)

# Logger
"""
    terminal_logger()

Returns the global `TerminalLogger` to be used for logging progress bars via `ProgressLogging.jl` in the REPL.
"""
function terminal_logger()
    isassigned(TERMINAL_LOGGER) || (TERMINAL_LOGGER[] = TerminalLogger())
    return TERMINAL_LOGGER[]
end

tee_logger() = TeeLogger(terminal_logger(), current_logger())

"""
    progress_logger()

Returns the logger to use for progress monitoring via ProgressLogging.jl. 

When called from the REPL (checking the `isinteractive` function), it will return a TeeLogger (from LoggingExtras.jl) containing the current logger and a `TerminalLogger` (from TerminalLoggers.jl). 
This is because the `@progress` macro from ProgressLogging.jl does not print the
progress bar in the REPL without `TerminalLogger`.

Outside of interactive sessions, it will simply return the current logger.
"""
progress_logger() = isinteractive() ? tee_logger() : current_logger()

# This function shall create the non-parametrzed subtype, used for simplifying adding methods to `StructArrays.similar_type`. The solution is taken from https://discourse.julialang.org/t/deparametrising-types/41939/4
"""
    basetype(t)

Returns the type of `t`, removing type parameters if for parametric types (thus
returning the more generic UnionAll type for `typeof(t)`)

```julia
basetype(rand(Complex{Float64})) === Complex
```
"""
basetype(t::DataType) = t.name.wrapper
basetype(t::UnionAll) = basetype(t.body)
basetype(::T) where T = basetype(T)

"""
    asdeg(x::Real)

Convert the provided value assumed to be in radians to Unitful degrees.

The [`stripdeg`](@ref) function performs the inverse operation.

```julia
asdeg(π) ≈ 180.0°
```
"""
asdeg(x::Real) = rad2deg(x) * °

"""
    stripdeg(x::Deg)

Strip the units from the provided `Deg` field and convert it to radians.

The [`asdeg`](@ref) function performs the inverse operation.

```julia
stripdeg(180.0°) ≈ π
```
"""
stripdeg(x::Deg) = x |> ustrip |> deg2rad


"""
    isnotset(x)

Return `true` if `x` is not set to a value. 
(That is, `x` is either `NotProvided` or `NotSimulated`)
"""
isnotset(x) = x isa NotSet

"""
    fallback(x...)

Return the first value in the arguments which is set, i.e. is not equal to `NotProvided` or `NotSimulated`.
If no value is found, an `ArgumentError` is thrown.

# Examples
```
julia> x = NotProvided()
julia> y = NotSimulated()
julia> z = 1.0
julia> fallback(x, y, z)
1.0
```
"""
function fallback end

fallback() = throw(ArgumentError("No value arguments present"))
fallback(x::NotSet, y...) = fallback(y...)
fallback(x::Any, y...) = x


"""
    sa_type(DT::DataType, N::Union{Int, TypeVar}; unwrap = T -> false)

This is a helper function that simplifies creating concrete `StructArray` types for types within struct definitions.

## Arguments
- `DT::DataType`: The type of the struct to create the `StructArray` for.
- `N::Union{Int, TypeVar}`: Specifies the dimensions of the array stored within the resulting `StructArray` type

# Examples
```julia
struct ASD{G}
    a::sa_type(Complex{G}, 3)
end
```
is equivalent to
```julia
struct ASD{G}
    a::StructArray{Complex{G}, 3, @NamedTuple{re::Array{G, 3}, im::Array{G, 3}}, Int64}
end
```

!!! note
    This function is defined inside an extension and is thus available only conditionally to the `StructArrays` package being explicitly imported

# Extended Help

The function supports unwrapping like in the `StructArray` constructor by providing the appropriate function as the `unwrap` keyword argument.

It also supports a `TypeVar` as second argument instead of simply an `Int`. This is useful for creating complex composite types like in the example below.

```julia
@kwdef struct InnerField
    a::Float64 = rand()
    b::Complex{Float64} = rand(ComplexF64)
end

@kwdef struct CompositeStruct
    inner::InnerField = InnerField()
    int::Int = rand(1:10)
end

struct SAField{N}
    sa::sa_type(CompositeStruct, N; unwrap=T -> (T <: InnerField))
end

saf = SAField(StructArray([CompositeStruct() for i in 1:3, j in 1:2]; unwrap = T -> (T <: InnerField)))
```

where the `SAField` type has a fully concrete type for it's field `sa` which would be quite complex to specify manually
"""
sa_type(U::UnionAll, args...; kwargs...) = throw(ArgumentError("The provided eltype `$U` is not fully parametrized and would result in an abstract `StructArray` type"))

"""
    isprovided(x) -> Bool

Check if the value `x` is not of type `NotProvided`.
Returns `true` if `x` is provided, otherwise `false`.
"""
isprovided(x) = typeof(x) != NotProvided

"""
    issimulated(x) -> Bool

Check if `x` is simulated by verifying its type is not `NotSimulated`.
Returns `true` if `x` is simulated, `false` otherwise.
"""
issimulated(x) = typeof(x) != NotSimulated

"""
    unwrap_optional(::Type)

Function used to unwrap the type `T` from `Optional{T}`.
If the provided type is not of the form `Optional{T}`, it simply returns it unchanged.

!!! note
    When calling this function with simply `Optional` as input, the function throws an error.

```jldoctest
julia> using BasicTypes: BasicTypes, unwrap_optional, Optional

julia> unwrap_optional(Optional{Float32})
Float32

julia> unwrap_optional(Float64)
Float64
```
"""
unwrap_optional(T::Type) = T
unwrap_optional(::Type{Optional{T}}) where {T} = T
unwrap_optional(::Type{Optional}) = throw(ArgumentError("You can't call `unwrap_optional` with `Optional` (without a type parameter) as input"))


"""
    getfield_oftype(container, target_type::Type)

Returns the first field of `container` which satisfy `field isa target_type`.

If no field satisfying the condition is found, returns `nothing`.

!!! note
    This function can not be called with a `target_type === Optional` or `target_type <: Union{Nothing, NotSet}`.

# Example

```jldoctest
julia> using BasicTypes

julia> @kwdef struct MyType
           a::Int
           b::Float64
           c::Optional{String} = NotProvided()
       end
MyType

julia> getfield_oftype(MyType(1, 2.0, "test"), Int)
1

julia> getfield_oftype(MyType(1, 2.0, "test"), AbstractFloat)
2.0

julia> getfield_oftype(MyType(1, 2.0, "test"), String)
"test"

julia> getfield_oftype(MyType(; a = 1, b = 2.0), String)
NotProvided()

julia> getfield_oftype(MyType(; a = 1, b = 2.0), ComplexF64)

```
"""
@generated function getfield_oftype(object, target::Type{T}) where T
    (T <: Union{Nothing,NotSet} || T === Optional) && return :(throw(ArgumentError("You can't call this function with a target type `T <: Union{Nothing, NotSet}` or `T === Optional`, and `$target` was provided as target type")))
    nms = fieldnames(object)
    tps = fieldtypes(object)
    for i in eachindex(nms, tps)
        nm = nms[i]
        tp = tps[i] |> unwrap_optional
        (tp <: T) && return :(getfield(object, $(QuoteNode(nm))))
    end
    return :(nothing)
end