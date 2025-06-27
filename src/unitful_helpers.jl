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