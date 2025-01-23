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