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