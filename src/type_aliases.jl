const Optional{T} = Union{T, NotProvided, NotSimulated}

# helper type alias, taken from CoordRefSystems.jl
const Len{T} = Quantity{T,u"𝐋"}
const Met{T} = Quantity{T,u"𝐋",typeof(m)}
const Deg{T} = Quantity{T,NoDims,typeof(°)}
const Rad{T} = Quantity{T,NoDims,typeof(rad)}

## Angle Types
const UnitfulAngleQuantity = Union{Deg, Rad}
const ValidAngle = Union{UnitfulAngleQuantity, Real}
const ValidDistance = Union{Len, Real}

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
