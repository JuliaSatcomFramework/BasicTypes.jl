# Derived Dimensions
const AreaDimension = Unitful.𝐋^2
const VolumeDimension = Unitful.𝐋^3
const SpeedDimension = Unitful.𝐋 * Unitful.𝐓^-1
const AccelerationDimension = Unitful.𝐋 * Unitful.𝐓^-2
const FrequencyDimension = Unitful.𝐓^-1
const ForceDimension = Unitful.𝐌 * Unitful.𝐋 * Unitful.𝐓^-2
const PowerDimension = Unitful.𝐌 * Unitful.𝐋^2 * Unitful.𝐓^-3
const EnergyDimension = Unitful.𝐌 * Unitful.𝐋^2 * Unitful.𝐓^-2

# Quantities
const DimensionQuantity{D, T} = Union{Quantity{T, D}, Real}
const Distance{T} = DimensionQuantity{Unitful.𝐋, T}
const Speed{T} = DimensionQuantity{SpeedDimension, T}
const Mass{T} = DimensionQuantity{Unitful.𝐌, T}
const Duration{T} = Union{DimensionQuantity{Unitful.𝐓, T}, Dates.FixedPeriod}
const Angle{T} = Union{Quantity{T,NoDims,typeof(Unitful.°)}, Quantity{T,NoDims,typeof(Unitful.rad)}, Real}
const AngularRate{T} = DimensionQuantity{Unitful.𝐓^-1, T} # Since angles are no-dims, we can't restrict much better
const Temperature{T} = DimensionQuantity{Unitful.𝚯, T}
const Frequency{T} = DimensionQuantity{FrequencyDimension, T}
const Power{T} = DimensionQuantity{PowerDimension, T}

# Quantity Aliases
const Meter{T} = Quantity{T,u"𝐋",typeof(Unitful.m)}
const Degree{T} = Quantity{T,NoDims,typeof(Unitful.°)}
const Radian{T} = Quantity{T,NoDims,typeof(Unitful.rad)}

"""
    base_unit(unit::Unitful.Units)
    base_unit(quantity::Unitful.Quantity)
    
Returns the SI base unit for the dimension of the provided unit or quantity.
In case of angles, the `base_unit` returns `u"rad"` when the input is either `u"°"` or `u"rad"`.
"""
base_unit(quantity::Unitful.Quantity) = base_unit(unit(quantity))
base_unit(::Unitful.Units{<:Any, Unitful.𝐍, <:Any}) = Unitful.mol
base_unit(::Unitful.Units{<:Any, Unitful.𝐈, <:Any}) = Unitful.A
base_unit(::Unitful.Units{<:Any, Unitful.𝐋, <:Any}) = Unitful.m
base_unit(::Unitful.Units{<:Any, Unitful.𝐉, <:Any}) = Unitful.cd
base_unit(::Unitful.Units{<:Any, Unitful.𝐌, <:Any}) = Unitful.kg
base_unit(::Unitful.Units{<:Any, Unitful.𝚯, <:Any}) = Unitful.K
base_unit(::Unitful.Units{<:Any, Unitful.𝐓, <:Any}) = Unitful.s
# Derived units
base_unit(::Unitful.Units{<:Any, AreaDimension, <:Any}) = Unitful.m^2
base_unit(::Unitful.Units{<:Any, VolumeDimension, <:Any}) = Unitful.m^3
base_unit(::Unitful.Units{<:Any, EnergyDimension, <:Any}) = Unitful.J
base_unit(::Unitful.Units{<:Any, PowerDimension, <:Any}) = Unitful.W
base_unit(::Unitful.Units{<:Any, ForceDimension, <:Any}) = Unitful.N
base_unit(::Unitful.Units{<:Any, FrequencyDimension, <:Any}) = Unitful.Hz
base_unit(::Unitful.Units{<:Any, SpeedDimension, <:Any}) = Unitful.m / Unitful.s
base_unit(::Unitful.Units{<:Any, AccelerationDimension, <:Any}) = Unitful.m / Unitful.s^2
# Dimensionless units
base_unit(::Union{typeof(u"°"), typeof(u"rad")}) = u"rad"
base_unit(::Union{typeof(Unitful.percent), typeof(Unitful.permille), typeof(Unitful.pertenthousand)}) = Unitful.percent
base_unit(::Union{typeof(Unitful.pcm), typeof(Unitful.ppm), typeof(Unitful.ppb), typeof(Unitful.ppt)}) = Unitful.percent
# Keeping interop with Dates.FixedPeriods
base_unit(::Dates.FixedPeriod) = Unitful.s

#region enforce_unit and enforce_unitless

"""
    enforce_unit(reference, value::Unitful.Quantity)
    enforce_unit(reference)
    
Takes the provided value quantity and converts it to the unit provided as `reference`.

!!! note
    The provided `reference` must represent a unit compatible with the unit expected from `value`.

In case only `reference` is provided (second signature above), this function simply returns `Base.Fix1(enforce_unit, reference)`.

# Arguments
- `reference`: The unit to convert `value` to. It can be an instance from one of the following types:
  - `Unitful.Units`: e.g. u"m".
  - `Type{<:Quantity}`: e.g. typeof(1u"°").
  - `Quantity`: e.g. 2f0 * u"m/s".
- `value`: The quantity to convert.

# Examples
```jldoctest
julia> using BasicTypes

julia> enforce_unit(u"m", 2f0 * u"km/h") # Throws as units are not compatible
ERROR: DimensionError:

julia> enforce_unit(typeof(1f0u"m"), 1km) # Also converts to Float32 as the provided reference is a Float32 quantity
1000.0f0 m

julia> enforce_unit(1f0u"rad", 10°) # Also converts to Float32 as the provided reference is a Float32 quantity
0.17453292f0 rad

julia> enforce_unit(1u"km", 3u"m") # Providing a quantity directly also tries to enforce the precision
ERROR: InexactError:

julia> enforce_unit(u"km", 3u"m") # This will not enforce precision
3//1000 km

julia> 1km |> enforce_unit(u"m") ∘ float # Test the method returning a function
1000.0 m
```

See also: [`enforce_unitless`](@ref)
"""
enforce_unit(reference::Unitful.Units, value::Unitful.Quantity) = uconvert(reference, value)
enforce_unit(reference::Unitful.Units, value::Dates.FixedPeriod) = uconvert(reference, value)
enforce_unit(reference::Type{<:Unitful.Quantity}, value::Unitful.Quantity) = convert(reference, value)
enforce_unit(reference::Unitful.Quantity, value::Unitful.Quantity) = enforce_unit(typeof(reference), value)
enforce_unit(reference, value) = enforce_unit(unit(reference), value)

"""
    enforce_unit(reference, value::Real, [interpret_as::Unitful.Units])

Takes the provided unitless `value` and converts it to the unit specified by `reference`.
The number is interpreted as the unit specified by `interpret_as` (if provided) or as the preferred base unit of `reference` otherwise.

If `reference` is a Quantity, the same data type is used for the returned Quantity.

```jldoctest
julia> using BasicTypes

julia> enforce_unit(u"km", 3) # Lengths are interpreted as meters by default
3//1000 km

julia> enforce_unit(1.0u"mg", 2) # Weights use kg by default
2.0e6 mg

julia> enforce_unit(u"°", 1*pi) # Angles are interpreted as radians
180.0°
```

See also: [`enforce_unit(reference, value::Unitful.Quantity)`](@ref)
"""
enforce_unit(reference, value::Real, interpret_as::Unitful.Units) = enforce_unit(reference, value * interpret_as)
enforce_unit(reference, value::Real) = enforce_unit(reference, value, base_unit(reference))

# Function creating a function to enforce a specific unit
enforce_unit(reference) = Base.Fix1(enforce_unit, reference)

"""
    enforce_unitless(reference, value)
    enforce_unitless(reference, value::Real, interpret_as::Unitful.Units)
    enforce_unitless(reference)

Takes the provided `value` (supposed to represent a quantity tied to a specific unit), converts it to the unit represented by `reference` and then strips the units.
This will simply call `ustrip(enforce_unit(reference, value))`.

If only `reference` is provided (second signature above), this function simply returns `Base.Fix1(enforce_unitless, reference)`.

See [`enforce_unit`](@ref) for more details on the supported argument types.

# Examples

```jldoctest
julia> using BasicTypes

julia> enforce_unitless(1f0u"m", 1km)
1000.0f0

julia> enforce_unitless(u"m", 1)
1

julia> 1km |> enforce_unitless(u"m") ∘ float # Test the method returning a function
1000.0
```
"""
enforce_unitless(reference, value::Real, interpret_as::Unitful.Units) = ustrip(enforce_unit(reference, value, interpret_as))
enforce_unitless(reference, value) = ustrip(enforce_unit(reference, value))
enforce_unitless(reference) = Base.Fix1(enforce_unitless, reference)

#endregion

#region Raw unitless values

"""
    raw_angle(x::Angle, [rounding::RoundingMode])

Returns the angle in radians as a unitless number.
The optional `rounding` argument can be used to wrap the returned value within `[0, 2π)` using the specified rounding mode.
```

"""
raw_angle(x::Angle) = ustrip(enforce_unit(base_unit(u"rad"), x))
raw_angle(x::Angle, rounding::RoundingMode) = rem(raw_angle(x), raw_angle(360°), rounding)
raw_angle(x::NotSet) = x
raw_angle(x::Nothing) = x

"""
    raw_distance(x::Distance)

Returns the distance in meters as a unitless number.
"""
raw_distance(x::Distance) = ustrip(enforce_unit(base_unit(u"m"), x))
raw_distance(x::NotSet) = x
raw_distance(x::Nothing) = x

"""
    raw_mass(x::Mass)

Returns the mass in kilograms as a unitless number.
"""
raw_mass(x::Mass) = ustrip(enforce_unit(base_unit(u"kg"), x))
raw_mass(x::NotSet) = x
raw_mass(x::Nothing) = x

"""
    raw_duration(x::Duration)

Returns the duration in seconds as a unitless number.
"""
raw_duration(x::Duration) = ustrip(enforce_unit(base_unit(u"s"), x))
raw_duration(x::NotSet) = x
raw_duration(x::Nothing) = x

#endregion

"""
    assert_angle_limit(x::Angle; name::String = "Angle", limit = π, limit_min = -limit, limit_max = limit, msg::String = "<name> must satisfy <limit_min> ≤ x ≤ <limit_max>")

Asserts that the provided angle `x` is within the specified limits.
By default, the limits are set to `-π` and `π`.
"""
function assert_angle_limit(x::Angle; name::String = "Angle", limit = π, limit_min = -limit, limit_max = limit, msg::String = "$name must satisfy $limit_min ≤ x ≤ $limit_max
Consider using `°` from Unitful (also re-exported by BasicTypes) if you want to pass numbers in degrees, by doing `x * °`." )  
	@assert (limit_min <= x <= limit_max) msg
end

# Compatibility with NotSet type and Nothing
enforce_unit(reference, value::NotSet, interpret_as::Unitful.Units) = value
enforce_unit(reference, value::NotSet) = value
enforce_unit(reference, value::Nothing, interpret_as::Unitful.Units) = value
enforce_unit(reference, value::Nothing) = value
enforce_unitless(reference, value::NotSet) = value
enforce_unitless(reference, value::Nothing) = value

# External compat with NotSet type
Unitful.ustrip(quantity::NotSet) = quantity
Unitful.ustrip(u::Unitful.Units, quantity::NotSet) = quantity
Unitful.uconvert(u::Unitful.Units, quantity::NotSet) = quantity
Unitful.unit(quantity::NotSet) = Unitful.NoUnits
Unitful.dimension(quantity::NotSet) = Unitful.NoDims