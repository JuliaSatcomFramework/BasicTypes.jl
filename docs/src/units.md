# Units

BasicTypes uses Unitful but extends it with some commonly used conventions and functions. First and foremost, it is assumed that SI units are used for all dimensions as the canonical unit.

Type aliases are provided for commonly used quantities. These aliases accept both quantities of the respective dimensions, as well as unitless real numbers. That is, they are unions of specific quantities and real values. These are intended to be used with the methods below.

The following aliases are provided: `Distance`, `Mass`, `Time`, `Angle`, `Temperature`, `Frequency`, `Power`.

To enforce specific units on both unitful and unitless values, `enforce_unit` can be used. This enables code like the following

```julia
function orbital_velocity(altitude::Distance, planet_mass::Mass)
    h = enforce_unit(u"m", altitude)
    M = enforce_unit(u"kg", planet_mass)
    R = 6.371e6u"m" + h
    G = 6.67430e-11u"N*m^2/kg^2"  # gravitational constant
    v = sqrt(G * M / R)
    return v
end

orbital_velocity(500u"km", 5972e24)
```

```@docs
enforce_unit
```

A convenience function is also provided to perform unit enforcement, but returning a raw value instead of a Unitful value.

```@docs
enforce_unitless
```

For angles, distances, mass, and time, the following functions are also provided for convenience:

```@docs
raw_angle
raw_distance
raw_mass
raw_time
```

To obtain the canonical unit for a `Unitful.Quantity` or `Unitful.Units`, call

```@docs
base_unit
```