# Units Helper Functions
_validtype(t, A::Union{DataType, Union}) = eltype(t) <: A || length(t) > 1 && all(x -> _validtype(x, A), t)

function _check_angle_func(limit = π) 
	f(x::ValidAngle) = abs(x) <= limit
end
function _check_angle(x; limit = π, msg::String = "Angles directly provided as numbers must be expressed in radians and satisfy -$limit ≤ x ≤ $limit
Consider using `°` from Unitful.jl if you want to pass numbers in degrees, by doing `x * °`." )  
	@assert all(_check_angle_func(limit), x) msg
end

"""
	to_radians(x::Real; rounding::RoundingMode = RoundNearest)

Takes a real number (assumed to represent an angle in radians) and normalizes it
using `rem2pi(x, rounding)` to wrap the angle.

See also: [`to_degrees`](@ref), [`to_meters`](@ref)
"""
to_radians(x::Real; rounding::RoundingMode = RoundNearest) = abs(x) <= π ? float(x) : rem2pi(x, rounding)

"""
	to_radians(x::UnitfulAngleQuantity; rounding::RoundingMode = RoundNearest)

Takes a Unitful Angular Quantity, transforms it to radians and wraps the angle.
This function basically does the following:\\
`to_radians(ustrip(uconvert(u"rad", x)); rounding)`
"""
to_radians(x::UnitfulAngleQuantity; kwargs...) = to_radians(ustrip(uconvert(u"rad", x)); kwargs...)
function to_radians(x; kwargs...)
	if _validtype(x, ValidAngle)
		return map(x) do angAny
			to_radians(angAny; kwargs...)
		end
	else
		error("You can only call `to_radians` with scalar angle values or iterables containing angle values (from Unitful)")
	end
end

"""
	to_degrees(x::Real; rounding::RoundingMode = RoundNearest)

Takes a real number (assumed to represent an angle in degrees) and normalizes it
using `rem(x, 360, rounding)` to wrap the angle.

See also: [`to_radians`](@ref), [`to_meters`](@ref)
"""
to_degrees(x::Real; rounding::RoundingMode = RoundNearest) = abs(x) <= 180 ? float(x) : rem(x, 360.0, rounding)
"""
	to_degrees(x::UnitfulAngleQuantity; rounding::RoundingMode = RoundNearest)

Takes a Unitful Angular Quantity, transforms it to degrees and wraps the angle.
This function basically does the following:\\
`to_radians(ustrip(uconvert(u"deg", x)); rounding)`
"""
to_degrees(x::UnitfulAngleQuantity; kwargs...) = to_degrees(ustrip(uconvert(u"°", x)); kwargs...)
function to_degrees(x; kwargs...)
	if _validtype(x, ValidAngle)
		return map(x) do angAny
			to_degrees(angAny; kwargs...)
		end
	else
		error("You can only call `to_degrees` with scalar angle values or iterables containing angle values (from Unitful)")
	end
end

"""
	to_meters(x::UnitfulLengthQuantity)

Takes a Unitful Length Quantity, transforms it to meters and strips the unit.
This function basically does the following:\\
`ustrip(uconvert(u"m", x))`

See also: [`to_radians`](@ref), [`to_degrees`](@ref)
"""
to_meters(x::Len) = uconvert(u"m", x) |> ustrip
"""
	to_meters(x::Real)
Simply returns `x`. Just provided for consistency with the other method
"""
to_meters(x::Real) = x
function to_meters(x)
	if _validtype(x, ValidDistance)
		return map(to_meters, x)
	else
		error("You can only call `to_meters` with scalar length or iterables containing distance values (from Unitful)")
	end
end

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