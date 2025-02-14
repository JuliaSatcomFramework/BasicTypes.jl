# Changelog

This file contains the changelog for the BasicTypes.jl package. It follows the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.

## [Unreleased]

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
