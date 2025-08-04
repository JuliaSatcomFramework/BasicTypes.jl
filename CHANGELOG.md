# Changelog

This file contains the changelog for the BasicTypes.jl package. It follows the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.

## Unreleased

## [1.16.0] - 2025-08-04
### Changed
Change the internal of `getproperty_oftype`. The underlying generated function now simply extract the fieldname from the a type instead of already extracting the field from an instance.

## [1.15.0] - 2025-07-28
### Changed
- Changed the default method for `valuetype` to return `Union{}` instead of throwing an error. This allows more flexible use of `common_valuetype` 
  - It is not considered a breaking change as erroring was never documented as official behaviour.

### Added
- Added a new public but non-exported function `bypass_bottom`. Used now internally in `common_valuetype` to fallback to the default type in case first returned type is `Union{}` (i.e. `Base.Bottom` hence the name)

### Fixed
- Change internal implementation of `basetype` to follow the one in `ConstructionsBase.jl` which has better type inference.

## [1.14.0] - 2025-07-09

### Added
- Added the `ScopedRefValue` type, which behaves like a `ScopedValue` but whose value can also be changed persistently outside of `with` calls.

## [1.13.0] - 2025-06-27

### Added
- Added a convenience method `change_valuetype(type) = Base.Fix1(change_valuetype, type)`.
- Added support for `valuetype` to `CoordRefSystems.CRS` instances via extension
- Added support for `valuetype` to the following types from `Meshes`:
  - `Point`
  - `Domain`
  - `Geometry`


## [1.12.0] - 2025-06-27

### Added
- Added two new generic function `enforce_unit` and `enforce_unitless` to converts between compatible units and ensure a return value that has either a unit or not in its type. See the docstrings for more details

### Deprecated
- The `to_length` and `to_meters` are now deprecated in favor of direct use of `enforce_unit`. The docstrings as well as their execution will not print a warning. These will be removed in a future breaking release.

## [1.11.1] - 2025-06-18

### Fixed
- Changed internals of `getproperty_oftype` to fix some errors, most notably that having structure with untyped field as input would throw an error.

### Added
- Added possibility of specifying whether to use `<:` or `===` to compare field types with `target_type` in `getproperty_oftype`. (still experimental, not documented)

## [1.11.0] - 2025-06-14

### Added
- Added the `getproperty_oftype` function which provides fast way to extract the first field of a struct whose type satisfies `fieldtype <: target_type`, and optionally accepts as input a fallback function to try calling for extracting the desired property from an object. Useful for custom extraction of items from complex structures
- Added a new singleton type `PropertyOrNothing{name}` whose instance acts as a functor and extracts property `name` from the `object` provided as input, or returns nothing if no property `name` is present in the provided object. This is mostly useful as a fallback for `getproperty_oftype`. 

### Fixed
- Fixed a method for `change_valuetype` which hardcoded `3` when modifying valuetype of a `StaticVector`

## [1.10.0] - 2025-06-01

### Added
- Added the `isprovided` and `issimulated` functions, which can be used to check the status of input variables.

## [1.9.0] - 2025-05-25

### Added
- Added the `sa_type` function, which can be used to create a `StructArray` type providing the eltype and the number of dimensions. This is mostly useful for simplifying creating types of fields which holds `StructArray` elements in struct definitions.

## [1.8.0] - 2025-05-22

### Added

- Add const NamedTuple `CONSTANTS` with useful physical constants.
  
## [1.7.1] - 2025-04-22

### Fixed
- Handle `NotSet` types in `valuetype`

## [1.7.0] - 2025-04-14

### Added
- Added the `valuetype(x)` function, returning the underlying type of an object.
- Added the `change_valuetype(::Type, x)` function, changing the underlying type of an object.
- Added the `common_valuetype(::Type, ::Type, args...)` function, determining a common types for arguments with a fallback.
- Added the `promote_valuetype(::Type, ::Type, args...)` function, converting argument to a common type with a fallback.

## [1.6.0] - 2025-04-08

### Added
- Added the `isnotset` function, checking whether a value is set. (Similar to `isnothing`)
- Added the `fallback(x...)` function, returning the first value that is set. (Similar to `something(x...)`)
- Added the `@fallback` macro, returning the first value that is set or throwing an error. (Similar to `@something`)

## [1.5.0] - 2025-04-08

### Added
- Added the `NotSet` type as `Union{NotProvided, NotSimulated}`

## [1.4.0] - 2025-02-16

### Added
- Added the `@add_kwargs_defaults` and `@define_kwargs_defaults` macros, which can be used to add default values to the keyword arguments of a function, especially useful when the same kwarg default is used in multiple functions.
- Added the `SkipChecks` type, which can be used for dispatch to implement version of functions skipping at least some of the checks.

### Changed
- `asdeg` and `stripdeg` are now exported.

## [1.3.0] - 2025-01-31

### Added
- Added the `asdeg` and `stripdeg` functions, which convert between unitless radians and Unitful degrees. Mostly useful for internal use as trigonometric function on degrees (which are also called when doing e.g. `cos(90°)`) are slower than the same operation on radians, and also slower than doing first a conversion to unitless radians and then calling the trigonometric function.

## [1.2.0] - 2025-01-30

### Added
- Added the `basetype` function, which returns the base type (without type parameters) of a given type.

## [1.1.0] - 2025-01-28

### Added
- Added the `NoTrait` type, which can be used to indicate the absence of a trait in type-based trait implementations.
- Added the `constructor_without_checks` function, which can be used to define an inner constructor for which skips all checks and simply calls `new` inside. See the docstring for more details.


## [1.0.0] - 2025-01-23
Initial release of the BasicTypes.jl package.

### Added
- Added the `Optional{T}` type alias, which is a union of `T`, `NotProvided`, and `NotSimulated`. This supersedes the `Maybe{T}` originally used in SatelliteSimulationToolkit.jl
- A function `to_length` is now defined and export to convert and `ValidDistance` value into a `Unitful.Quantity` with the specified unit. `to_meters` is internally using `to_length` fixing `u"m"` as unit.

### Changed
- Compared to v0.1.0 of ReferenceViews.jl, the `to_degrees`, `to_radians` and `to_meters` functions now return Unitful quantitites (floating point) rather than unitless numbers.
  - The `to_radians` and `to_degrees` functions now accept a `RoundingMode` as second argument (instead of as a kwarg). When called with a single argument, the function simply convert the input number without performing angular wrapping.

### Removed
- Compared to v0.1.0 of ReferenceViews.jl, `to_degrees`, `to_radians` and `to_meters` no longer have methods that accept non-scalar values as input.
