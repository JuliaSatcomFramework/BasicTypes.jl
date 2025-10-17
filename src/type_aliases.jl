# Type alias for valid point subtypes
const PS = Union{Real, Quantity{<:Real}}

# Generic Point
"""
	Point{N,T} = Union{Tuple{Vararg{T, N}},SVector{N,<:T}}
	Point2D = Point{2, Union{Real, Unitful.Quantity{<:Real}}}
	Point3D = Point{3, Union{Real, Unitful.Quantity{<:Real}}}
"""
const Point{N, T} = Union{Tuple{Vararg{T, N}},SVector{N,<:T}}
const Point2D = Point{2, PS}
const Point3D = Point{3, PS}
