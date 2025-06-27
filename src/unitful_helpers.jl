"""
    enforce_unit(reference, value)
    enforce_unit(reference)
    
Takes the provided `value` (supposed to represent a quantity tied to a specific unit) and converts it so that it to the unit provided as `reference`.

!!! note Unit
    The provided `reference` must be a unit compatible with the unit expected from `value`.

In case only `reference` is provided (second signature above), this function simply returns `Base.Fix1(enforce_unit, reference)`.

# Arguments
- `reference`: The unit to convert `value` to. It can be an instance from one of the following types:
  - `Unitful.Units`: e.g. u"m".
  - `Type{<:Quantity}`: e.g. typeof(1u"°").
  - `Quantity`: e.g. 2f0 * u"m/s".

- `value`: The value to convert. It can be an instance from one of the following types:
  - `Quantity`: e.g. 2f0 * u"m/s".
  - `Number`: A unitless number. **NOTE: In this case, the number is simply assumed to already have the right scale and simply returned as a `Quantity` with the provided  `reference` unit.**

# Examples
```jldoctest
julia> using BasicTypes

julia> enforce_unit(u"m", 2f0 * u"km/h") # Throws are units are not compatible
ERROR: DimensionError: m and km J^-1 s^-1 are not dimensionally compatible.

julia> enforce_unit(typeof(1f0u"m"), 1km) # Also converts to Float32 as the provided reference is a Float32 quantity
1000.0f0 m

julia> enforce_unit(1f0u"rad", 10°) # Also converts to Float32 as the provided reference is a Float32 quantity
0.17453292f0 rad

julia> enforce_unit(1u"km", 3u"m") # Providing a quantity directly also tries to enforce the precision
ERROR: InexactError: Int64(3//1000)

julia> enforce_unit(u"km", 3u"m") # This will not enforce precision
3//1000 km

julia> enforce_unit(u"km", 3) # This will simply apply the desired unit to the provided value
3 km
```

See also: [`enforce_unitless`](@ref)
"""
enforce_unit(reference::Units, value::Quantity) = uconvert(reference, value)
enforce_unit(reference::Type{<:Quantity}, value::Quantity) = convert(reference, value)

# Version that takes a unitless number and returns it 
enforce_unit(reference::Type{<:Quantity}, value::Number) = reference(value) # Create the instance directly
enforce_unit(reference::Units, value::Number) = reference * value

# This is a fallback if one provides a quantity instance directly as reference
enforce_unit(reference::Quantity, value::Number) = enforce_unit(typeof(reference), value)

# Function creating a function to enforce a specific unit
enforce_unit(reference) = Base.Fix1(enforce_unit, reference)


# For the unitless version, we first apply the desired unit and then strip the units
"""
    enforce_unitless(reference, value)
    enforce_unitless(reference)

Takes the provided `value` (supposed to represent a quantity tied to a specific unit), converts it to the unit represented by `reference` and then strips the units.
This will simply call `ustrip(enforce_unit(reference, value))`.

If only `reference` is provided (second signature above), this function simply returns `Base.Fix1(enforce_unitless, reference)`.

See [`enforce_unit`](@ref) for more details on the supported argument types and examples
"""
enforce_unitless(reference, value) = ustrip(enforce_unit(reference, value))
enforce_unitless(reference) = Base.Fix1(enforce_unitless, reference)


#### Helpers specifically for angles ####
"""
    asdeg(x::Real)

Convert the provided value assumed to be in radians to Unitful degrees.

The [`stripdeg`](@ref) function performs the inverse operation.

```jldoctest
julia> using BasicTypes

julia> asdeg(π)
180.0°
```
"""
asdeg(x::Real) = rad2deg(x) * °

"""
    stripdeg(x::Deg)

Strip the units from the provided value (expected to be a `Unitful.Quantity` in degrees) and convert it to radians.

The [`asdeg`](@ref) function performs the inverse operation.

```jldoctest
julia> using BasicTypes

julia> stripdeg(180.0°)
3.141592653589793
```
"""
stripdeg(x::Deg) = x |> ustrip |> deg2rad

"""
    to_radians(x::ValidAngle)
    to_radians(x::ValidAngle, rounding::RoundingMode)
    to_radians(rounding::RoundingMode)

Take one scalar value representing an angle and convert it to floating point Unitful quantities with radian (`rad`) units.

!!! note
    The input angles provided as unitless numbers are treated as degrees.

The 2-arg method can be used to also wrap (using `rem`) the angle provided as first argument using the rounding mode specified as second argument.

The last method taking a single `RoundingMode` argument is equivalent to `Base.Fix2(to_radians, rounding)`.

See also: [`to_degrees`](@ref), [`enforce_unit`](@ref)
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

See also: [`to_radians`](@ref), [`enforce_unit`](@ref)
"""
to_degrees(value::ValidAngle) = enforce_unit(°, float(value))

# Do the common methods
for fname in (:to_radians, :to_degrees)
    # Function that does the rounding
    eval(:($fname(x::ValidAngle, rounding::RoundingMode) = rem($fname(x), $fname(360°), rounding)))
    # Function that takes the rounding-mode and returns a function that applies the specified rounding
    eval(:($fname(rounding::RoundingMode) = Base.Fix2($fname, rounding)))
end


#### Deprecated length functions ####

"""
    to_length(unit::LengthUnit, x::ValidDistance)
    to_length(unit::LengthUnit)

!!! warn
    This function is deprecated now, consider using the more explicit form `enforce_unit(unit, float(x))` instead.


Take one scalar value representing a length and convert it to floating point Unitful quantities with the specified `LengthUnit` `unit`.

The single-argument method taking a single `LengthUnit` argument is equivalent to `Base.Fix1(to_length, unit)`.

See also: [`to_meters`](@ref), [`to_radians`](@ref), [`to_degrees`](@ref)
"""
function to_length(unit)
    @warn "`to_length(unit)` is deprecated, consider using the more explicit form `enforce_unit(unit) ∘ float` instead"
    return Base.Fix1(to_length, unit)
end
function to_length(unit, x::ValidDistance)
    @warn "`to_length(unit, x)` is deprecated, consider using the more explicit form `enforce_unit(unit, float(x))` instead"
    return enforce_unit(unit, float(x))
end

"""
    to_meters(x::ValidDistance)

!!! warn
    This function is deprecated now, use directly the new signature `enforce_unit(u"m", x)` instead.

Take one scalar value representing a length and convert it to floating point Unitful quantities with the `m` unit.

See also: [`to_length`](@ref), [`to_radians`](@ref), [`to_degrees`](@ref)
"""
function to_meters(x::ValidDistance)
    @warn "to_meters is deprecated, use the new and more generic `enforce_unit(u\"m\", x)` instead"
    return enforce_unit(u"m", x)
end